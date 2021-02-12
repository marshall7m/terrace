function usage {
  # static-check description credit: https://github.com/gruntwork-io/pre-commit/blob/v0.1.12/.pre-commit-hooks.yaml
  cat << EOF
Usage for command: static-check
usage: terrace static-check [FLAGS] [STATIC_CHECK] [EXTRA_ARGS]
 
[STATIC_CHECK]: 
all                          Runs all static-checks
terraform_fmt                Rewrites all Terraform configuration files to a canonical format       
terraform-validate           Validates all Terraform configuration files
tflint                       Linter for Terraform source code
shellcheck                   Rewrites all Terragrunt configuration files to a canonical format
gofmt                        Gofmt formats Go programs
goimports                    Goimports updates imports and formats in the same style as gofmt
golint                       Golint is a linter for Go source code
yapf                         yapf (Yet Another Python Formatter) is a python formatter from Google
helmlint                     Run helm lint, a linter for helm charts
markdown-link-check          Run markdown-link-check to check all the relative and absolute links in markdown docs.
check-terratest-skip-env     Check all go source files for any uncommented os.Setenv calls setting a terratest SKIP environment.

[FLAGS]:
-h, --help                   Shows this help message

[EXTRA_ARGS]:                Any additional `pre-commit run` flags (e.g --files, --all-files)
EOF
  exit 0
}

function main {
  parser $@
  pre-commit install
    
  PRE_COMMIT_CMD="pre-commit run $STATIC_CHECK $EXTRA_PRE_COMMIT_ARGS"
  echo "Running $PRE_COMMIT_CMD"
  $PRE_COMMIT_CMD
}

function parser {
  static_checks=()
  if test $# -gt 0; then
    while test $# -gt 0; do
      case "$1" in 
        -h|--help)
          usage
          ;;
        --)
          shift
          export EXTRA_PRE_COMMIT_ARGS=$@
          exit 0
          ;;
        *)
          checks=(all terraform_fmt terraform-validate tflint shellcheck gofmt goimports golint yapf helmlint markdown-link-check check-terratest-skip-env)

          if [[ ! " ${checks[@]} " =~ " $1 " ]]; then
            echo "Invalid static-check: $1"
            echo "Valid static-checks:"
            for check in ${checks[@]}; do 
              printf "\t$check\n" 
            done
            exit 1
          fi
          if [ "$1" != "all" ]; then
            export STATIC_CHECK="$1"
          fi
          shift
          ;;
      esac
    done
  else
    echo "Hook is not defined"
    exit 1
  fi
}
  
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi