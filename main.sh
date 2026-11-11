#!/bin/bash

LOOP=0

echo "HALBERD TECHNOLOGIES PORTAL"
# Loop until user enters 3
while [ $LOOP -eq 0 ]
do
	# Menu for potential user inputs
	echo ""
	echo "Please choose options 1-3:"
	echo "1. Automatically create users from CS webpage (Default)"
	echo "2. Manually add a new user"
	echo "3. End program"
	read -p "Enter a value 1-3: " choice
	echo ""

	# Validate that input is a digit
	if [[ ! $choice =~ ^[0-9]+$ ]]
	then
		echo "Invalid input (please enter a number!). Remprompting..."
		continue
	fi

	# Validate that input is a number 1-3
	if [ $choice -eq 1 ]
	then
		bash ./scraper.sh # If 1, run scraper.sh
	elif [ $choice -eq 2 ]
	then
		bash ./manual_user.sh # If 2, run manual_user.sh
	elif [ $choice -eq 3 ]
	then
		echo "Goodbye!" # If 3, break from the loop
		LOOP=1
	else
		echo "Invalid input (please enter a value 1-3!). Reprompting..." # If not 1, 2, or 3, reprompt user
	fi
done
