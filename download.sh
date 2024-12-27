#!/bin/bash -ex

cd "$(dirname "$0")" || exit 1

mkdir -p raw

wget -q "https://ftp.apnic.net/stats/apnic/delegated-apnic-latest" \
	-O raw/apnic.txt

wget -q "https://ftp.afrinic.net/pub/stats/afrinic/delegated-afrinic-latest" \
	-O raw/afrinic.txt

wget -q "https://ftp.arin.net/pub/stats/arin/delegated-arin-extended-latest" \
	-O raw/arin.txt

wget -q "https://ftp.lacnic.net/pub/stats/lacnic/delegated-lacnic-latest" \
	-O raw/lacnic.txt

wget -q "https://ftp.ripe.net/pub/stats/ripencc/delegated-ripencc-latest" \
	-O raw/ripencc.txt
