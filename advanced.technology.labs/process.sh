#!/bin/sh

for dir in *; do
	if test -d "$dir"; then
		cd "$dir"
		cp ../generate_iol_MACOS.sh ./
		sh ./generate_iol_MACOS.sh
		echo "$dir" > lab_title.txt
		rm generate_iol_MACOS.sh
		cd ..
		mv "$dir" INE_FIL-"$dir"
	fi
done
