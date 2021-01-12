#!/bin/bash
package=$0
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi

function usage {
    echo "$package - Runs pre-commit hooks, (Terraform|Terragrunt) commands, and Terratests"
    echo " "
    echo "usage: $package [COMMAND] [FLAGS]"
    echo " "
    echo "Global Flags: (can be used after binary or after [COMMAND])"
    echo "-h, --help                shows help message"
    echo " "
    echo "[COMMAND]:"
    echo "static-check        Runs selected pre-commit hooks"
    echo "test                Runs selected test (terratest/pytest)"
    echo "deploy              Runs Terragrunt or Terraform commands"
    exit 0
}

while test $# -gt 0; do
  case "$1" in
    -h|--help)
      usage
      ;;
    static-check)
      . "$DIR/static_check.sh"
      check_deps
      shift
      if test $# -gt 0; then
        case "$1" in 
          -h|--help)
            usage
            ;;
          all)
            shift
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