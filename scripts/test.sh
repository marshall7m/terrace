function usage {
  cat << EOF
Runs Pytest for given files"
usage: terrace test [TARGET_PATHS] [FLAGS]

[TARGET_PATHS]:                  Space separated list of directories or files to run pytest on

[FLAGS]:    
-h, --help                Show this help message 

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
      *)
        pytest $@
        ;;
    esac
  else
    echo "Test arguments were not defined"
    exit 1
  fi
}

function main {
  parser $@

  #TODO: func for listing all cloud resources that are still running?
}
  
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi