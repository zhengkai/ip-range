#!/bin/bash

cd "$(dirname "$0")" || exit 1

mkdir -p raw

wget "https://ftp.apnic.net/stats/apnic/delegated-apnic-latest" \
	-O raw/apnic.txt

wget "https://ftp.afrinic.net/pub/stats/afrinic/delegated-afrinic-latest" \
	-O raw/afrinic.txt

wget "https://ftp.arin.net/pub/stats/arin/delegated-arin-extended-latest" \
	-O raw/arin.txt

wget "https://ftp.lacnic.net/pub/stats/lacnic/delegated-lacnic-latest" \
	-O raw/lacnic.txt

wget "https://ftp.ripe.net/pub/stats/ripencc/delegated-ripencc-latest" \
	-O raw/ripencc.txt
