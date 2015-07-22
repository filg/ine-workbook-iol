#!/bin/sh
# Shell script to convert INE RSv5 configs to IOL/IOLL2 format
# Changes interface names
# Adapted by Rob Fegley (rofegley)
# Original work by Daniel Dib @ http://reaper81.wordpress.com as generate_dynamips.sh

# Revised by rofegley, 2015-01-13:
### Change file extension on original INE configuration file from .txt to .INE
###	Modify the file encoding to UTF8 to remove NUL characters which will cause IOS
###		parser to reject the configs
###	  http://stackoverflow.com/questions/805418/how-to-find-encoding-of-a-file-in-unix-via-scripts
### Set *.INE to read-only files
### Remove Unicode Byte-Order Mark (BOM) from beginning of file
###   http://thegreyblog.blogspot.com/2010/09/shell-script-to-find-and-remove-bom.html
### Remove 'end' of configuration duplicates
### Remove all 'enable' and 'config t' commands
### Remove all lines with '(hostname)#' prompt
### Remove all lines listing current configuration size
### Remove extraneous space in Loopback interface naming
### MPLS.MP.BGP.VPNV4/R5.txt: configure 'mpls ip' on 'int Tunnel0' NOT 'int Tunnel'
### Correct 8 variations of 'interface range' commands to reference the proper interfaces
### Rename all Gig1 interfaces and Gig1.x subinterfaces to Eth0/0 and Eth0/0.x
### Rename FastE0/19 through 0/24 to proper IOL interfaces
### Rename FastE0/1 to Ethernet2/3, likely only on SW1
### Delete all configurations referencing interfaces FastE0/x
### Delete all configurations referencing interfaces GigE0/x, GigE2, and GigE3
### Delete stanza for virtual-service csr_mgmt
### Remove command 'platform console serial'
### Remove any 'license' commands
### Remove any reference to version in configurations
### Remove empty lines

BUV="`date +%Y-%m-%d_%H%M`"

#Check if configs exist

for config in R1 R2 R3 R4 R5 R6 R7 R8 R9 R10 R11 R12 R13 R14 R15 R16 R17 R18 R19 R20 SW1 SW2 SW3 SW4
do
  myfile="`ls -1 | egrep -i "$config.txt"`"
  
  if [ ! -r "$config.INE" ]; then
    if [ "$myfile" ]; then
	  myfileenc="`file -I "$config.txt" | awk '{print $3}' | sed 's/charset=//g'`"
	  if [ "$myfileenc" != "us-ascii" ]; then
		iconv -f "$myfileenc" -t UTF-8 "$myfile" > "$config.INE" 
	  else
		mv "$myfile" "$config.INE"
	  fi
	  
	  chmod 0444 "$config.INE"
	else
      echo "$config configuration is missing from current directory!"
	fi
  fi
  
  myfile=""
  myfileenc=""
  
  if [ -r "$config.INE" ]; then
    sed "
        1 s/\xEF\xBB\xBF//
        /^end$/d
		/^enable$/d
		/^enabl$/d
		/^enab$/d
		/^ena$/d
		/^en$/d
		/^conf t$/d
		/^configure t/d
    	/$config#.*/d
		/^Current configuration.*/d
		s/Loopback 10/Loopback10/g
		s/^interface Tunnel$/interface Tunnel0/g
		s/interface range FastEthernet0\/19 - 24/interface range Ethernet0\/0 - 3 , Ethernet1\/0 - 1/g
		s/interface range FastEthernet0\/19 - 20/interface range Ethernet0\/0 - 1/g
		s/interface range FastEthernet0\/20 - 23/interface range Ethernet0\/1 - 3 , Ethernet1\/0/g
		s/interface range FastEthernet0\/21 - 22/interface range Ethernet0\/2 - 3/g
		s/interface range FastEthernet0\/21 - 23/interface range Ethernet0\/2 - 3 , Ethernet1\/0/g
		s/interface range FastEthernet0\/23 - 24/interface range Ethernet1\/0 - 1/g
		s/interface range FastEthernet0\/24/interface range Ethernet1\/1/g
		s/interface range Fa0\/1 - 24/interface range Ethernet0\/0 - 3, Ethernet1\/0 - 1, Ethernet2\/3/g
		s/GigabitEthernet1/Ethernet0\/0/g
		s/FastEthernet0\/19/Ethernet0\/0/g
		s/FastEthernet0\/20/Ethernet0\/1/g
		s/FastEthernet0\/21/Ethernet0\/2/g
		s/FastEthernet0\/22/Ethernet0\/3/g
		s/FastEthernet0\/23/Ethernet1\/0/g
		s/FastEthernet0\/24/Ethernet1\/1/g
		s/FastEthernet0\/1$/Ethernet2\/3/g
		/^interface FastEthernet0/,/^\!/d
		/^interface GigabitEthernet0/,/^\!/d
		/^interface GigabitEthernet2/,/^\!/d
		/^interface GigabitEthernet3/,/^\!/d
		/^virtual-service csr_mgmt/,/^\!/d
		/^platform console serial/d
		/^license.*$/d
		/^version.*$/d
		/^$/d
	" "$config.INE" > "$config.txt"

	echo "end" >> "$config.txt"
	chmod 0666 "$config.txt"
    echo "$config configuration updated to $config.txt"
  fi
    
done

echo
echo
tar zcf "./configs-$BUV.tar.gz" *.txt

echo
echo
echo "All configurations in current working directory are backed up to configs-$BUV.tar.gz"

echo
echo
echo "Updates done...Use the *.txt configurations for your labs.  Keeping the INE originals as *.INE for reference."
