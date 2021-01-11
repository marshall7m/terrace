function install {
    local -r binary="$1"
    local -r version="$2"
    if [ -z $version ]; then
        echo "Version: Latest"
    fi
    terraenv $binary use $version || terraenv $binary install $version
}

function infer_binary {
    local -r path="$1"

    if ls ${path}/*.tf &>/dev/null; then
        binary="terraform"
        echo "Inferred binary: $binary"
        return $binary
    elif ls ${path}/*.hcl &>/dev/null; then
        binary="terragrunt"
        echo "Inferred binary: $binary"
        return $binary
    else
        extensions=()
        for file in $(ls $path); do
            filename=$(basename -- "$file")
            extensions+=" ${filename##*.}"
        done

        distinct_extensions=$(echo "${extensions[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')
        echo "Could not infer binary from $path"
        echo "Path only contains the following extensions:"
        echo $distinct_extensions
        exit 1
    fi
}

function run {
    local -r binary="$1"
    local -r version="$2"
    local -r path="$3"
    local -r command="$4"

    if [ -z "$binary" ]; then
      binary=$(infer_binary $path)
    else
        echo "Binary: $binary"
    fi
    
    install $binary $version
}

if [ $# -ne 2 ]; then
   usage
else
   run $@
fi