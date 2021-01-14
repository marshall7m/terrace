function usage {
  # static-check description credit: https://github.com/gruntwork-io/pre-commit/blob/v0.1.12/.pre-commit-hooks.yaml
  cat << EOF
Usage for command: static-check
usage: terrace static-check [FLAGS] [STATIC_CHECK] [EXTRA_ARGS]
 
[STATIC_CHECK]: 
all                          Runs all static-checks
terraform-fmt                Rewrites all Terraform configuration files to a canonical format       
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

function run {
  local -r static_check="$1"
  local -r extra_args="$2"
  
  pre-commit run $static_check $extra_args
  exit 0
}

function check_deps {
    pre-commit install
}