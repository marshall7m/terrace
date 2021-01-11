#!/bin/bash
package=$0
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi

function usage {
    echo "$package - Runs pre-commit hooks, (Terraform|Terragrunt) commands, and Terratests"
    echo " "
    echo "usage: $package [FLAGS] [COMMAND] --  <EXTRA_ARGS>"
    echo " "
    echo "Commands without arguments:"
    echo "-h, --help                shows help message"
    echo " "
    echo "Commands with arguments:"
    echo "static-check        <ARGS>    Runs selected pre-commit hooks"
    echo "deploy              <ARGS>    Runs Terragrunt or Terraform commands"
    echo "--command   Runs the command with the inferred binary (terraform|terragrunt) and version"
    echo "--path        Relative path to target directory"
    echo "--"
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
            run "all" $2
            ;;
        esac
      else
        echo "no hook is specified"
        exit 1
      fi
      ;;
    deploy)
      . "$DIR/deploy.sh"
      shift
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
      run $binary $version $path $command
    fi
    ;;
    *)
      echo "Argument is invalid, run terrace --help for valid arguments"
      break
      ;;
  esac
done