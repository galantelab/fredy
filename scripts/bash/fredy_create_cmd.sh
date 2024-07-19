#!/usr/bin/env bash

usage() {
	echo "Usage: $0 <CMD>"
}

[[ $# == 0 ]] && { usage; exit; }

cmd="bin/fredy_${1}"

if [[ -f "$cmd" ]]; then
	echo "Command '$cmd' already exist" >&2
	exit 1
fi

mkdir -p bin
touch "$cmd"
chmod +x "$cmd"

cat << 'EOF' > "$cmd"
#!/usr/bin/env bash

# Bash pragmas
set -o errexit
set -o pipefail
set -o nounset

# Where I am
BIN_DIR="$(cd $(dirname $(readlink -f "${BASH_SOURCE[0]}")) && pwd)"

# Load common lib
source "$BIN_DIR/../lib/fredy_common"

# My name
SCRIPT_NAME="${0##*/}"

# Command name
CMD_NAME="${SCRIPT_NAME#${PROG_NAME}_}"

usage() {
	echo "$PROG_NAME $VERSION"
	echo "$PROG_NAME $CMD_NAME (aka $SCRIPT_NAME)"
	echo "Usage: $PROG_NAME $CMD_NAME [options]"
}

validate_opt() {
	echo "Validate options"
}

validate_dep() {
	echo "Validate dependencies from prev cmd"
}

# Options
prefix="out"
output_dir="."

[[ $# == 0 ]] && { usage; exit; }

while getopts ":ho:p:" OPTION; do
	case "$OPTION" in
		h)
			usage
			exit
			;;
		o)
			output_dir="$OPTARG"
			;;
		p)
			prefix="$OPTARG"
			;;
		?)
			error "No such option '-$OPTARG'\n$(try_help)"
			;;
	esac
done

# Check for errors
validate_opt
validate_dep

# MAIN
EOF
