#!/bin/bash

# Pull names list from faculty_names.sh
. ./faculty_names.sh

# Loops through each name in names list
declare -n name_ref
for name_ref in "${names[@]}"; do
	username=${name_ref[first]}"."${name_ref[last]} # Creates username (firstname.lastname)
	password=${name_ref[first]}${name_ref[last]}HALBERD # Creates password (firstnamelastnameHALBERD)
	sudo useradd -p $password $username # Creates new user with provided username and password (requires user auth for initial creation)
done

echo "Created ${#names[@]} users."
