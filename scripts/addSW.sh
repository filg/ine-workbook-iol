#!/bin/sh

for dir in *; do
	if test -d "$dir"; then
		cd "$dir"
		cp ../INE_FIL-IP_ADDRESSING/SW45.txt .
		cp ../INE_FIL-IP_ADDRESSING/vlan.dat-00045 .
		cd ..
	fi
done
