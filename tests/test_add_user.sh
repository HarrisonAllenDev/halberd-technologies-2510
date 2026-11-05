#!/bin/bash
# Unit tests for add_user.sh. All account-management commands are mocked.
set -u

project_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd) || exit 1
source "$project_dir/add_user.sh"

# Creation mode requires root in add_user.sh. CI runs this test script
# with sudo, but the mocks below prevent system accounts from changing.
if [[ "$EUID" -ne 0 ]]; then
    echo 'Run these isolated tests with: sudo bash tests/test_add_user.sh' >&2
    exit 1
fi

scratch=$(mktemp -d) || exit 1
trap 'rm -rf "$scratch"' EXIT

# Bash functions override executable commands of the same name.
# Never call the real useradd, chpasswd, usermod or id in these tests.
id() {
    [[ "${MOCK_EXISTS:-false}" == true ]]
}
useradd() {
    printf '%s\n' "$*" >> "$scratch/useradd_calls"
    return "${MOCK_USERADD_STATUS:-0}"
}
chpasswd() {
    cat >> "$scratch/password_calls"
    return "${MOCK_CHPASSWD_STATUS:-0}"
}
usermod() {
    printf '%s\n' "$*" >> "$scratch/usermod_calls"
}

passed=0
fail() { printf 'FAIL: %s\n' "$1" >&2; exit 1; }
pass() { printf 'PASS: %s\n' "$1"; passed=$((passed + 1)); }
reset_mocks() {
    MOCK_EXISTS=false
    MOCK_USERADD_STATUS=0
    MOCK_CHPASSWD_STATUS=0
    : > "$scratch/useradd_calls"
    : > "$scratch/password_calls"
    : > "$scratch/usermod_calls"
}

# 1. Preview mode must never create a real or mocked account.
reset_mocks
CREATE_USERS=false
output=$(create_account 'John' 'Smith') || fail 'preview returned failure'
[[ "$output" == *'Would create: john.smith'* ]] || fail 'preview username'
[[ ! -s "$scratch/useradd_calls" && ! -s "$scratch/password_calls" ]] || fail 'preview modified an account'
pass 'preview mode'

# 2. Reject invalid names before calling useradd.
reset_mocks
if create_account 'John123' 'Smith' > /dev/null 2>&1; then
    fail 'invalid name accepted'
fi
[[ ! -s "$scratch/useradd_calls" ]] || fail 'invalid name created account'
pass 'invalid name rejected'

# 3. Do not create an already-existing username.
reset_mocks
MOCK_EXISTS=true
output=$(create_account 'John' 'Smith') || fail 'existing user returned failure'
[[ "$output" == *'Already exists: john.smith'* ]] || fail 'existing user message'
[[ ! -s "$scratch/useradd_calls" ]] || fail 'duplicate user was created'
pass 'duplicate account skipped'

# 4. Test both account creation and the exact assignment password.
reset_mocks
CREATE_USERS=true
output=$(create_account 'JoHn' 'SmITh') || fail 'creation returned failure'
[[ "$output" == *'Created: john.smith'* ]] || fail 'creation message'
grep -Fxq -- '-m -- john.smith' "$scratch/useradd_calls" || fail 'wrong useradd arguments'
grep -Fxq -- 'john.smith:johnsmithHALBERD' "$scratch/password_calls" || fail 'wrong username or password'
pass 'username and password creation'

# 5. Manual function reads two user-supplied names.
reset_mocks
CREATE_USERS=true
output=$(printf 'Alice\nBrown\n' | add_user) || fail 'manual input returned failure'
grep -Fxq -- '-m -- alice.brown' "$scratch/useradd_calls" || fail 'manual username'
grep -Fxq -- 'alice.brown:alicebrownHALBERD' "$scratch/password_calls" || fail 'manual password'
pass 'manual add_user input'

# 6. If password setup fails, the existing script must lock the account.
reset_mocks
CREATE_USERS=true
MOCK_CHPASSWD_STATUS=1
if create_account 'Jane' 'Doe' > /dev/null 2>&1; then
    fail 'password failure incorrectly reported success'
fi
grep -Fxq -- '-L -- jane.doe' "$scratch/usermod_calls" || fail 'failed account not locked'
pass 'password failure locks account'

printf '\nAll %d Add User tests passed. No real accounts were created.\n' "$passed"
