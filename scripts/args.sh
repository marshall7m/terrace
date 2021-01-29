#!/bin/bash
package=$0
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi

function usage {
  cat << EOF
$package - Runs pre-commit hooks, (Terraform|Terragrunt) commands, and Terratests
usage: $package [COMMAND] [FLAGS]

Global Flags: (can be used after binary or after [COMMAND])
-h, --help                shows help message

[COMMAND]:
static-check        Runs selected pre-commit hooks
test                Runs selected test (terratest/pytest)
deploy              Runs Terragrunt or Terraform commands
EOF
  exit 0
}


while test $# -gt 0; do
  case "$1" in
    ""|-h|--help)
      usage
      ;;
    static-check)
      shift
      . "$DIR/static_checks.sh"
      main "$@"
      ;;
    deploy)
      shift
      . "$DIR/deploy.sh"
      main "$@"
      ;;
    test)
      shift
      . "$DIR/test.sh"
      main "$@"
      exit 0
      ;;
    *)
      echo "Argument is invalid, run terrace --help for valid arguments"
      break
      ;;
  esac
done