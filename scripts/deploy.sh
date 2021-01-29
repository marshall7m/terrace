function usage {
    cat << EOF
Runs Terragrunt or Terraform commands with associated directory

usage: terrace deploy [FLAGS]

[FLAGS]:
-h, --help                Show this help message
-b, --binary              Binary to run command with (terragrunt|terraform)
-v, --version             Binary version to install/use
-p, --path                Relative path to target directory (defaults to cwd)
-c, --command             Command to run with binary (include additional command flags)

Example use:

    Run Terraform with specified version:
        'terrace deploy --binary terraform --version 0.14.4 --command plan --path terraform_dir/
    Run Terragrunt without defining the binary (must):
        'terrace deploy --command plan --path terraform_dir/
EOF
exit 0
}

function main {
    parser $@
 
    local -r path="${path:-$(PWD)}"

    if [ -z "$binary" ]; then
        binary=$(infer_binary $path) || exit
    fi

    cd $path
    if [$binary == "terraform"]; then
        if [ -z "$version" ]; then
            tfenv use min-required || tfenv install min-required && tfenv use min-required
        else
            tfenv use $version || tfenv install $version && tfenv use $version
        fi
    fi

    $binary $command
    cd - 1>/dev/null
}

function parser {
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
}

function infer_binary {
    local -r 

    if ls ${path}/*.hcl &>/dev/null; then
        echo "terragrunt"
    elif ls ${path}/*.tf &>/dev/null; then
        echo "terraform"
    else
        extensions=()
        for file in $(ls $path); do
            filename=$(basename -- "$file")
            extensions+=" ${filename##*.}"
        done

        distinct_extensions=$(echo "${extensions[@]}" | tr " " "\n" | sort -u | tr "\n" " ")
        echo "Could not infer binary from $path" >&2
        echo "Path only contains the following extensions:" >&2
        echo $distinct_extensions >&2
        exit 1
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi