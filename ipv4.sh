#!/bin/bash -e

FILE_DATA="step1/v4-data.txt"
FILE_COUNTRY="step1/v4-country.txt"

cd "$(dirname "$0")" || exit 1

mkdir -p step1

echo "Generating IPv4 list"
grep -h '|ipv4|' raw/*.txt | grep -v -E "\|\||\|\*\|" > "$FILE_DATA"

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

mkdir -p step-v4

while IFS= read -r C; do
	echo -n "$C "
	grep "|${C}|" "$FILE_DATA" | awk -F\| '{ printf("%s/%d\n", $4, 32-log($5)/log(2)) }' \
		> "step-v4/${C,,}.txt"
done < "$FILE_COUNTRY"
