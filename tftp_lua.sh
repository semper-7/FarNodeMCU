#!/bin/sh
if [ -z "$2" ] echo "Command line: tftp_lua IP_adress filename"
mkdir tmp
sed -e "/^$/d;s/^[ 	]*//;s/[ 	]*$//" "$2" > tmp/"$2"
tftp -p -l tmp/"$2" "$1"
rm -r tmp
