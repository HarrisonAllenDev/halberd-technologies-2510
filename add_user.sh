#!/bin/bash
# Functions used by main.sh. Do not call add_user automatically here.

create_account() {
    local first="$1" last="$2"
    local username password

    first="${first,,}"
    last="${last,,}"

    if [[ ! "$first" =~ ^[a-z]+$ || ! "$last" =~ ^[a-z]+$ ]]; then
        printf 'Invalid name: %s %s (letters a-z only).\n' "$first" "$last" >&2
        return 1
    fi

    username="${first}.${last}"
    password="${first}${last}HALBERD"

    if id "$username" &>/dev/null; then
        printf 'Already exists: %s\n' "$username"
        return 0
    fi

    # Preview is the default, until main.sh explicitly enables creation.
    if [[ "${CREATE_USERS:-false}" != true ]]; then
        printf 'Would create: %s\n' "$username"
        return 0
    fi

    if [[ "$EUID" -ne 0 ]]; then
        echo 'Error: Run main.sh with sudo to create users.' >&2
        return 1
    fi

    if ! useradd -m -- "$username"; then
        printf 'Error creating %s\n' "$username" >&2
        return 1
    fi

    if ! printf '%s:%s\n' "$username" "$password" | chpasswd; then
        # Do not leave an accessible account with a partially configured password.
        usermod -L -- "$username" 2>/dev/null || true
        printf 'Error setting password for %s; account has been locked.\n' "$username" >&2
        return 1
    fi

    printf 'Created: %s\n' "$username"
}

add_user() {
    local first last

    read -r -p 'Enter first name: ' first || return 1
    read -r -p 'Enter last name: ' last || return 1
    create_account "$first" "$last"
}
