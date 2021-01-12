function usage {
    echo "Runs Terragrunt or Terraform commands with associated directory"
    echo "usage: terrace deploy [FLAGS]"
    echo " "
    echo "[FLAGS]:"         
    echo "-h, --help                Show this help message"    
    echo "-b, --binary              Binary to run command with (terragrunt|terraform)"
    echo "-v, --version             Binary version to install/use"
    echo "-p, --path                Relative path to target directory (defaults to cwd)"
    echo "-c, --command             Command to run with binary"
    exit 0
}

function install {
    local -r binary="$1"
    local -r version=${2:-"latest"}
    
    if [[ $version == "latest" ]]; then
        terraenv $binary install $version
    else
        terraenv $binary use $version || terraenv $binary install $version
    fi
}

function infer_binary {
    local -r path="${1:-$(PWD)}"

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

function run {
    local -r binary="$1"
    local -r path="$2"
    local -r command="$3"
    
    cd $path
    $binary $command
    cd -
}