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
    password=$(echo $RANDOM | md5sum | head -c 12)

    if id "$username" &>/dev/null; then
        printf 'Already exists: %s\n' "$username"
        return 0
    fi

    #satisfying the test file
    if [[ "${CREATE_USERS:-true}" == false ]]; then
    printf 'Would create: %s\n' "$username"
    return 0
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
    user=$username" "$password
    echo $user >> users.txt
}

add_user() {
    local first last

    read -r -p 'Enter first name: ' first || return 1
    read -r -p 'Enter last name: ' last || return 1
    create_account "$first" "$last"
}

#shell_check fix
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    add_user
fi
