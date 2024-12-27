#!/bin/bash -e

FILE_DATA="step1/v6-data.txt"
FILE_COUNTRY="step1/v6-country.txt"

cd "$(dirname "$0")" || exit 1

mkdir -p step1

echo "Generating IPv4 list"
grep -h '|ipv6|' raw/*.txt | grep -v -E "\|\||\|\*\|" | sort > "$FILE_DATA"

echo "Generating country list"
cut -d'|' -f2 "$FILE_DATA" | sort -u > "$FILE_COUNTRY"

echo -n "Check country list... "
while IFS= read -r line; do
	if ! [[ $line =~ ^[A-Z]{2}$ ]]; then
		echo "Error"
		>&2 echo "Line '${line}' does not match pattern [A-Z]{2}"
		exit 1
	fi
done < "$FILE_COUNTRY"
echo "OK"

mkdir -p step-v6

while IFS= read -r C; do
	echo -n "$C "
	grep "|${C}|" "$FILE_DATA" | awk -F'|' '/\|ipv6\|/ { print $4 "/" $5 }' \
		> "step-v6/${C,,}.txt"
done < "$FILE_COUNTRY"
echo
