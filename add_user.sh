#!/bin/bash

# Pull names list from faculty_names.sh
. ./faculty_names.sh

# Loops through each name in names list
declare -n name_ref
for name_ref in "${names[@]}"; do
	username=${name_ref[first]}"."${name_ref[last]} # Creates username (firstname.lastname)
	password=$(echo $RANDOM | md5sum | head -c 12) # Creates password by generating random string of 12 numbers and hashing them into 12 characters
	sudo useradd -p $password $username # Creates new user with provided username and password (requires user auth for initial creation)
	user=$username" "$password # Combines username and password to print to users.txt
	echo $user >> users.txt
done

echo "Created ${#names[@]} users."
