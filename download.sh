#!/bin/bash

cd "$(dirname "$0")" || exit 1

mkdir -p raw

if [ ! -f raw/apnic.txt ]; then
wget "https://ftp.apnic.net/stats/apnic/delegated-apnic-latest" \
	-O raw/apnic.txt
fi

if [ ! -f raw/afrinic.txt ]; then
wget "https://ftp.afrinic.net/pub/stats/afrinic/delegated-afrinic-latest" \
	-O raw/afrinic.txt
fi

if [ ! -f raw/arin.txt ]; then
wget "https://ftp.arin.net/pub/stats/arin/delegated-arin-extended-latest" \
	-O raw/arin.txt
fi

if [ ! -f raw/lacnic.txt ]; then
wget "https://ftp.lacnic.net/pub/stats/lacnic/delegated-lacnic-latest" \
	-O raw/lacnic.txt
fi

if [ ! -f raw/ripencc.txt ]; then
wget "https://ftp.ripe.net/pub/stats/ripencc/delegated-ripencc-latest" \
	-O raw/ripencc.txt
fi
