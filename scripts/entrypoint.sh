DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
bash "$DIR/args.sh" $COMMAND $FLAGS