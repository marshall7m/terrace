function usage {
  cat << EOF

Runs Pytest for given files
usage: terrace test [TARGET_PATHS] [FLAGS]

[TARGET_PATHS]:                  Space separated list of directories or files to run pytest on

[FLAGS]:    
-h, --help                Show this help message 
--ci-filter               Run test on the git root's child directories that have difference between 
                          the --base-ref and --source-ref branches
--ci-filter               Run test on the git root's child directories that have modified/untracked 
                          test_xxxx.py, .hcl, and/or .tf files
--source-ref              Branch that the test will be runned on (default to current branch)
--base-ref                Branch that the --source-ref branch will be compared to. Used to indentify
                          which terraform module directories will be tested on. (default to remote 
                          master branch)

[EXTRA_ARGS]:             Any additional pytest flags (e.g --sw-skip, --fixtures-per-test)
EOF
  exit 0
}

function parser {
  if test $# -gt 0; then
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
              shift
              export SOURCE_REF="$1"
              shift
              ;;
            --base-ref)
              shift
              export BASE_REF="$1"
              shift
              ;;
          esac
        fi
        shift
        ;;
      --local-filter)
        shift
        export LOCAL_FILTER="$1"
        shift
        ;;
      *)
        pytest $@
        ;;
    esac
  else
    echo "Test arguments were not defined"
    exit 1
  fi
}

function get_target_tests {  
  # defaults to remote master
  local -r BASE_REF="${1:-refs/remotes/origin/master}"
  # defaults to cwb
  local -r SOURCE_REF="${2:-$(git rev-parse --abbrev-ref HEAD)}"

  if [ -n "$CI_FILTER" ]; then
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

  changed_files=$(git diff --name-only)
  changed_top_dirs=$(echo "$changed_files" | sed -E 's/\/.*$//g')

  untracked_files=$(git status -u --porcelain | sed -E 's/\?\? //g')
  untracked_top_dir=$(echo "$untracked_files" | egrep '\/test_.+\.py$|\/.+\.hcl$|\/.+\.tf$' | xargs -n 1 dirname | sed -E 's/\/.*$//g' | sed -E '/^\.\s?$/d')
  if [ "$LOCAL_FILTER" == "all" ]; then 
    echo "$(printf "$changed_top_dirs\n$untracked_top_dir" | sort | uniq)"
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
  parser $@
  
  target_tests=$(get_target_tests $BASE_REF $SOURCE_REF) || exit
  if [ -z "$target_tests" ]; then
    echo "No test were detected with filter"
    exit 1
  fi
  echo "target dirs:"
  echo "$target_tests"
  target_tests=$(echo $target_tests | sed -E 's/\n/ /g')
  PYTEST_CMD="pytest $target_tests"
  echo "Running: $PYTEST_CMD"
  $PYTEST_CMD
}
  
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi