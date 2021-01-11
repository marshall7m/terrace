function usage {
    echo "Usage for command: static-check"
    echo "usage: terrace static-check [FLAGS] static-check [--<EXTRA_ARGS> ]"
    echo " "
    echo "Commands without arguments:"
    echo "-h, --help                        shows this help message"
    echo "Commands with arguments:"
    echo "<static-check> Options: (credit: https://github.com/gruntwork-io/pre-commit/blob/v0.1.12/.pre-commit-hooks.yaml)"
    printf "\t terraform-fmt                Rewrites all Terraform configuration files to a canonical format"         
    printf "\t terraform-validate           Validates all Terraform configuration files"
    printf "\t tflint                       Linter for Terraform source code"
    printf "\t shellcheck                   Rewrites all Terragrunt configuration files to a canonical format"
    printf "\t gofmt                        Gofmt formats Go programs"
    printf "\t goimports                    Goimports updates imports and formats in the same style as gofmt"
    printf "\t golint                       Golint is a linter for Go source code"
    printf "\t yapf                         yapf (Yet Another Python Formatter) is a python formatter from Google"
    printf "\t helmlint                     Run helm lint, a linter for helm charts"
    printf "\t markdown-link-check          Run markdown-link-check to check all the relative and absolute links in markdown docs."
    printf "\t check-terratest-skip-env     Check all go source files for any uncommented os.Setenv calls setting a terratest SKIP environment."
    echo "<static-check> Flags:"
    echo "--<EXTRA_ARGS>                    Any additional pre-commit flags to run with associated <static-check>"
    exit 0
}

function run {
  local -r check="$1"
  local -r additional_args="$2"
  
  pre-commit run $check $additional_args
  exit 0
}

function check_deps {
    pre-commit install
}