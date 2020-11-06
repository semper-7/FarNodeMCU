#!/bin/sh
if [ -z "$2" ]; then
 echo "Command line: tftp_lua IP_adress filename"
 echo "Press any key to exit"
 read -n 1 -s -r
 exit
fi
mkdir tmp
sed -e "/^$/d;s/^[ 	]*//;s/[ 	]*$//" "$2" > tmp/"$2"
cd tmp
tftp -p -l "$2" "$1"
cd ..
rm -r tmp
