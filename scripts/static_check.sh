function usage {
    echo hello
}

function run {
    echo foo
}

function check_deps {
    if [ -f "$PWD/.pre-commit-config.yaml" ]; then
        echo "Found: pre-commit-config.yaml"
    else
        echo "No pre-commit-config.yaml was found"
    fi
    
    echo "Checking if pre-commit hooks are installed"
    pre-commit install
}