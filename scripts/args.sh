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
    echo "exec                      Execs into running container in new terminal"
    echo " "
    echo "Commands with arguments:"
    echo "static-check                 <ARGS>    Runs selected pre-commit hooks"
    echo "plan <ARGS>  Infers binary (terraform|terragrunt) given the input path and runs input command"
    echo "apply <ARGS>  Infers binary (terraform|terragrunt) given the input path and runs input command"
    exit 0
}

while test $# -gt 0; do
  case "$1" in
    -h|--help)
      usage
      ;;
    static-check)
      . "$DIR/static_check.sh"
      usage
      check_deps
      shift
      if test $# -gt 0; then
        case "$1" in 
          all)
            shift
            run 
            ${cmd[@]}
            ;;
        esac
      else
        echo "no hook is specified"
        exit 1
      fi
      ;;
    *)
      echo "Argument is invalid, run terrace --help for valid arguments"
      break
      ;;
  esac
done