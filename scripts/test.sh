function usage {
  cat << EOF

Runs Pytest for given files
usage: terrace test [TARGET_PATHS] [FLAGS]

[TARGET_PATHS]:                  Space separated list of directories or files to run pytest on

[FLAGS]:    
-h, --help                Show this help message 
--ci-filter               Run test on the git root's child directories that have difference between 
                          the --base-ref and --source-ref branches
--source-ref              Branch that the test will be runned on (default to current branch)
--base-ref                Branch that the --source-ref branch will be compared to. Used to indentify
                          which terraform module directories will be tested on. (default to remote 
                          master branch)
--local-filter            "all": Run test on the git root's child directories that have untracked/modified 
                            files
                          "terra": Run test on the git root's child directories that have untracked/modified 
                            .tf or .hcl files
                          "tests": Run test on the git root's child directories that have untracked/modified 
                            test_<foo>.py files
--                        [EXTRA_ARGS]: Any additional pytest flags (e.g --sw-skip, --fixtures-per-test). "--""
                            must be used before any additional args
EOF
  exit 0
}

function parser {
  if test $# -gt 0; then
    while test $# -gt 0; do
      case "$1" in 
        -h|--help)
          usage
          ;;
        -a|--all)
          export TEST_PATHS=ALL
          ;;
        --ci-filter)
          export CI_FILTER="true"
          shift
          if test $# -gt 0; then
            case "$1" in 
              --source-ref)
                shift 2
                export SOURCE_REF="$1"
                shift
                ;;
              --base-ref)
                shift 2
                export BASE_REF="$1"
                shift
                ;;
            esac
          fi
          shift
          ;;
        --local-filter)
          shift
          case "$1" in 
            all|terra|tests)
              export LOCAL_FILTER="$1"
              shift
              ;;
            --*)
              echo "--local-filter value was not defined. Options: [all|terra|tests]" 1>&2
              exit 1
              ;;
            *)
              echo "--local-filter is not valid. Options: [all|terra|tests]" 1>&2
              exit 1
              ;;
          esac
          ;;
        --plan-only)
          shift
          export PLAN_ONLY=true
          ;;
        --)
          shift
          export EXTRA_PYTEST_ARGS=$@
          return
          ;;
        *)
          echo "Invalid argument(s)"
          exit 1
          ;;
      esac
    done
  else
    echo "Test arguments were not defined" 1>&2
    exit 1
  fi
}

function get_target_tests {  
  # defaults to remote master
  local -r BASE_REF="${1:-refs/remotes/origin/master}"
  # defaults to cwb
  local -r SOURCE_REF="${2:-$(git rev-parse --abbrev-ref HEAD)}"

  if [ -n "$CI_FILTER" ]; then
    echo "Base Ref: $BASE_REF"
    echo "Source Ref: $SOURCE_REF"
    if [ -z "$(git show-ref refs/heads/$SOURCE_REF)" ]; then
        echo "$SOURCE_REF branch doesn't exists locally" 1>&2
        exit 1
    fi
    if [ -z "$(git show-ref $BASE_REF)" ]; then
        echo "$BASE_REF branch doesn't exists remotely" 1>&2
        exit 1
    fi
    if [ "$SOURCE_REF" != "$BASE_REF" ]; then 
      echo "$(git diff --name-only "$BASE_REF".."$SOURCE_REF" | egrep 'test_.+\.py$' | sed -E 's/\/.*$//g')"
      return
    else
      echo "--base-ref can not equal --source-ref" 1>&2
      exit 1
    fi
  fi

  changed_files=$(git diff --name-status | egrep '^M' | sed 's/^M.//g' | egrep '\/test_.+\.py$|\/.+\.tf$|.+\.hcl$')
  changed_top_dirs=$(echo "$changed_files" | sed -E 's/\/.*$//g')

  untracked_files=$(git status -u --porcelain | egrep '^ *?\?' | sed 's/^\?\?.//g')
  untracked_top_dir=$(echo "$untracked_files" | egrep '\/test_.+\.py$|\/.+\.hcl$|\/.+\.tf$' | xargs -n 1 dirname | sed -E 's/\/.*$//g' | sed -E '/^\.\s?$/d')
  if [ "$LOCAL_FILTER" == "all" ]; then 
    echo "$(printf "$changed_top_dirs\n$untracked_top_dir" | sort | uniq | sed '/^$/d')"
    return
  elif [ "$LOCAL_FILTER" == "terra" ]; then 
    echo "$(printf "$untracked_files\n$changed_files" | egrep '\/.+\.tf$|.+\.hcl$' | sed -E 's/\/.*$//g' | sort | uniq)"
    return
  elif [ "$LOCAL_FILTER" == "tests" ]; then 
    echo "$(printf "$changed_files\n$untracked_files" | egrep '\/test_.+\.py$')"
    return     
  fi
}


function main {
  #TODO: func for listing all cloud resources that are still running?
  parser $@ || exit
  target_tests=$(get_target_tests $BASE_REF $SOURCE_REF) || exit
  if [ -z "$target_tests" ]; then
    echo "No test were detected with filter"
    exit 1
  fi

  echo "target dirs:"
  echo "$target_tests"
  target_tests=$(echo $target_tests | sed -E 's/\n/ /g')
  PYTEST_CMD="pytest $target_tests $EXTRA_PYTEST_ARGS"
  if [ -n "$PLAN_ONLY" ]; then 
    echo "Command: $PYTEST_CMD"
    exit 0
  fi
  
  echo "Running: $PYTEST_CMD"
  $PYTEST_CMD
}
  
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi