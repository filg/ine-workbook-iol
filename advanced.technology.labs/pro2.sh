#!/bin/sh

for dir in *; do
	if test -d "$dir"; then
		cd "$dir"
		cp ../INE_FIL-IP_ADDRESSING/NETMAP .
		cp ../INE_FIL-IP_ADDRESSING/INE_topology_Web-IOL.png .
		cd ..
	fi
done
