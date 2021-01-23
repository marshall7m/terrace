function usage {
    cat << EOF
Runs Terragrunt or Terraform commands with associated directory

usage: terrace deploy [FLAGS]

[FLAGS]:
-h, --help                Show this help message
-b, --binary              Binary to run command with (terragrunt|terraform)
-v, --version             Binary version to install/use
-p, --path                Relative path to target directory (defaults to cwd)
-c, --command             Command to run with binary

Example use:

    Run Terraform with specified version:
        'terrace deploy --binary terraform --version 0.14.4 --command plan --path terraform_dir/
    Run Terragrunt without defining the binary (must):
        'terrace deploy --command plan --path terraform_dir/
EOF
exit 0
}

function install {
    local -r binary="$1"
    local -r version=${2:-"latest"}
    
    terraenv $binary use $version || terraenv $binary install $version
}


function infer_version {
    local -r binary="$1"
    local -r path="${2:-$(PWD)}"
    export TG_PATH=$path
    if [ $binary == "terragrunt" ]; then
        abs_tf_path=$(python -c """
import ast
import subprocess
import os

if os.path.isdir(os.environ['TG_PATH']): 
    config = subprocess.check_output(
        'cd {}; terragrunt terragrunt-info'.format(os.environ['TG_PATH']), 
        shell=True
    )
    config = ast.literal_eval(config.decode('utf-8'))
    abs_tf_path = '~{}'.format(config['WorkingDir'])
    print(abs_tf_path)
else:
    print('Invalid relative Terragrunt path: {}'.format(os.environ['TG_PATH']))
""" )
    else
        abs_tf_path=$(cd $path; pwd)
    fi
    echo $(find_min_required "$abs_tf_path")
}

get_min_required() {
  local -r root="$1"
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
    cd - 1>/dev/null
}