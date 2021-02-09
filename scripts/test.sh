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
                          which terraform module directories will be tested on. (default to master branch)

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
              shift 2
              ;;
            --base-ref)
              export BASE_REF="$1"
              shift 2
              ;;
          esac
        fi
        shift
        ;;
      --head-test-filter)
        shift
        export HEAD_TEST_FILTER="$1"
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
  #root_git=$(git rev-parse --show-toplevel)

  # new_top_dir=$(git ls-files -o --directory --no-empty-directory --exclude-standard | xargs -n 1 dirname | sed -E '/\/.*$|^\.\s?$/d' | uniq)
  # new_all_dir=$(git ls-files -o --directory --no-empty-directory --exclude-standard | xargs -n 1 dirname | sed -E '^\.\s?$/d' | uniq)

  # local -r SOURCE_REF=$1
  local -r BASE_REF="${1:-master}"
  local -r SOURCE_REF="${2:-$(git rev-parse --abbrev-ref HEAD)}"

  if [ -n "$CI_FILTER" ]; then
    if [ "$SOURCE_REF" != "$BASE_REF" ]; then 
      test=$(git diff --name-only "$BASE_REF".."$SOURCE_REF" | sed -E 's/\/.*$//g')
      return
    else
      echo "--base-ref can not equal --source-ref" 1>&2
      exit 1
    fi
  fi

  if [ "$HEAD_TEST_FILTER" == "tests" ]; then 
    echo "$(git diff --name-only | egrep 'test_.+\.py$')"
    exit 0
  fi

  changed_files=$(git diff --name-only)
  changed_top_dirs=$(echo "$changed_files" | sed -E 's/\/.*$//g')

  untracked_files=$(git status -u --porcelain | sed -E 's/\?\? //g')
  untracked_top_dir=$(git status -u --porcelain | sed -E 's/\?\? //g' | xargs -n 1 dirname | sed -E 's/\/.*$//g' | sed -E '/^\.\s?$/d')
  if [ "$HEAD_TEST_FILTER" == "all" ]; then 
    echo "$(printf "$changed_top_dirs\n$untracked_top_dir" | sort | uniq)"
  elif [ "$HEAD_TEST_FILTER" == "terra" ]; then 
    echo "$(printf "$untracked_files\n$changed_files" | egrep '\/.+\.tf$|.+\.hcl$' | sed -E 's/\/.*$//g' | sort | uniq)"
  fi
}


function main {
  parser $@

  target_tests=$(get_target_tests) || exit
  #TODO: func for listing all cloud resources that are still running?
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