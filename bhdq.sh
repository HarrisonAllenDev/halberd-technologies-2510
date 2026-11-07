#!/bin/bash
#license file
LICENSE_FILE="/var/lib/halberd/license.dat"

# SHA256 hash of key
EXPECTED_HASH="edc0f4a1ae7be889e43f089ee8d13bef9558a5f41157162602b1aaf753dfb769"

#credit to https://stackoverflow.com/questions/18215973/
if [[ $EUID -ne 0 ]]; then
    echo "ERROR: This program must be run as root."
    echo "Run: sudo ./bhdq"
    exit 1
fi

# hashes key input
hash_value()
{
    printf "%s" "$1" | sha256sum | awk '{print $1}'
}


activate_license()
{
    echo "No license found. Activation required."

    read -rp "Enter license key: " key
    echo

    #validates the key size
    if [[ ! "$key" =~ ^[0-9]{16}$ ]]; then
        echo "Invalid key format."
        return 1
    fi

    key_hash=$(hash_value "$key")

    # compare the hashed key to our known hash
    if [[ "$key_hash" != "$EXPECTED_HASH" ]]; then
        echo "Invalid license key."
        return 1
    fi

    # creates license file
    mkdir -p "$(dirname "$LICENSE_FILE")" || return 1

    echo "$key_hash" > "$LICENSE_FILE" || return 1

    #protects the license file from snoopers
    chmod 600 "$LICENSE_FILE"

    echo "License activated."
    return 0
}


check_license()
{
    # no file means first launch
    if [[ ! -f "$LICENSE_FILE" ]]; then
        activate_license
        return $?
    fi

    # read stored license hash
    saved_hash=$(cat "$LICENSE_FILE") || return 1

    if [[ "$saved_hash" != "$EXPECTED_HASH" ]]; then
        echo "Invalid license."
        return 1
    fi

    echo "License verified."
    return 0
}
# checks th license
if ! check_license; then
    echo "License verification failed."
    exit 1
fi

#allows user through to the rest of the program, credit: https://stackoverflow.com/questions/59895
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
exec bash "$SCRIPT_DIR/main.sh"

#AI was used in the following ways: ChatGPT, a model from OpenAI was used to develop the key obfuscation technique and licensing method