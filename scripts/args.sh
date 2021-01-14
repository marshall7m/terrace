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
    -h|--help)
      usage
      ;;
    static-check)
      . "$DIR/static_check.sh"
      shift
      if test $# -gt 0; then
        case "$1" in 
          -h|--help)
            usage
            ;;
          all)
            shift
            check_deps
            run $@
            ;;
        esac
      else
        echo "Hook is not defined"
        exit 1
      fi
      ;;
    deploy)
      . "$DIR/deploy.sh"
      shift
    while test $# -gt 0; do
      if test $# -gt 0; then
        case "$1" in 
          -h|--help)
            usage
            ;;
          -p|--path)
            shift
            export path=$1
            shift
            ;;
          -c|--command)
            shift
            export command=$1
            shift
            ;;
          -b|--binary)
            shift
            export binary=$1
            shift
            ;;
          -v|--version)
            shift
            export version=$1
            shift
            ;;
        esac
      fi
    done

    if [ -z "$binary" ]; then
      binary=$(infer_binary $path) || exit
    fi
    
    install $binary $version

    run $binary $path $command
    ;;
    *)
      echo "Argument is invalid, run terrace --help for valid arguments"
      break
      ;;
  esac
done