#!/bin/bash

url="https://www.tntech.edu/engineering/programs/csc/faculty-and-staff.php"

# download the page
curl -sL "$url" > faculty.html

# names are in the h4 tags, take out the html and the ph.d part
grep "<h4>" faculty.html | sed 's/<[^>]*>//g; s/&nbsp;/ /g; s/,.*//' > names.txt

count=0
list=""
echo "" > faculty_names.sh

# make a dictionary for each name
while read -r first last; do
    count=$((count+1))
    first="${first,,}"
    last="${last,,}"
    echo "declare -A name$count=([first]=\"$first\" [last]=\"$last\")" >> faculty_names.sh
    list="$list name$count"
done < names.txt

# list of all the dictionaries
echo "names=($list)" >> faculty_names.sh

# call adduser.sh to create users
./adduser.sh
