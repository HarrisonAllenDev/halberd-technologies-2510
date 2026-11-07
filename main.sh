#!/bin/bash
# Run with sudo ./main.sh --apply to allow account creation in a test VM.

set -o pipefail

project_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd) || exit 1
source "$project_dir/add_user.sh"

CREATE_USERS=false
case "${1:-}" in
    '') ;;
    --apply) CREATE_USERS=true ;;
    *) echo 'Usage: ./main.sh [--apply]' >&2; exit 1 ;;
esac

if [[ "$CREATE_USERS" == true && "$EUID" -ne 0 ]]; then
    echo 'Error: Use sudo ./main.sh --apply to create Ubuntu accounts.' >&2
    exit 1
fi

bulk_create() {
    local first last
    local failed=0
    local names_file="$project_dir/names.txt"

    # scraper.sh, downloads the HTML and generates names.txt.
    if ! ( cd "$project_dir" && bash ./scraper.sh ); then
        echo 'Error: Scraper failed.' >&2
        return 1
    fi

    if [[ ! -s "$names_file" ]]; then
        echo 'Error: names.txt is missing or empty.' >&2
        return 1
    fi

    echo 'Faculty names extracted:'
    cat "$names_file"

    # Avoid creating any accounts without the user's final approval.
    if [[ "$CREATE_USERS" == true ]]; then
        local confirmation
        read -r -p 'Create accounts for these names? Type YES: ' confirmation || return 1
        if [[ "$confirmation" != YES ]]; then
            echo 'Cancelled.'
            return 0
        fi
    fi

    while read -r first last; do
        [[ -z "$first" && -z "$last" ]] && continue
        create_account "$first" "$last" || failed=1
    done < "$names_file"

    return "$failed"
}

printf '\n===== hAlberd Technologies =====\n'
echo '1. Scrape faculty names and create accounts (default)'
echo '2. Add a user manually'
echo '3. Exit'
read -r -p 'Enter choice [1]: ' choice || exit 1
choice="${choice:-1}"

case "$choice" in
    1) bulk_create ;;
    2) add_user ;;
    3) echo 'Goodbye.' ;;
    *) echo 'Invalid choice.' >&2; exit 1 ;;
esac
