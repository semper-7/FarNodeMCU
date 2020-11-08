# FarNodeMCU
Project for ESP8266 NodeMCU. First of all, we created an environment for developing and writing lua files based on FAR manager.
To solve the problem, utilities for working with ESP were written in MASM32: lineterm.exe - mini console terminal, netterm.exe - TCP terminal is a simplified analog of nc in linux. Their size is only 3072 bytes.
Cmd and sh scripts are also created for writing lua scripts to ESP: lua_wr, net_wr and tftp_lua.
Telnet~.lua and tftp~.lua compatible servers were written accordingly.
Telnet server with support for simple linux commands: ls, cat, rm, mem, reboot.
Tftp server support oktet mode only.
The "~" character in the file name was used to autorun files in ESP, implemented in init.lua.
Support for linux user: net_wr.sh and tftp_wr.sh. FAR manager for Linux: https://github.com/elfmz/far2l

## Command line formats (all files in one folder):
### Windows (more needed utils: lineterm.exe, netterm.exe, sed.exe, busybox.exe):
#### File forwarding:
* lua_wr.cmd filename.lua
* net_wr.cmd filename.lua | netterm.exe ip_address 23
* net_wr.cmd filename.lua | busybox.exe nc ip_address 23
* tftp_lua.cmd ip_address filename.lua
* tftp -i ip_address PUT filename
* tftp -i ip_address GET filename
#### Telnet:
* netterm.exe ip_address 23
* busybox.exe nc ip_address 23
#### UART terminal:
* lineterm.exe COM_port_number baudrate
### Linux (all the necessary utilities in busybox):
#### File forwarding:
* ./net_wr.sh filename.lua | nc ip_address 23
* ./tftp_lua.sh ip_address filename.lua
* tftp -p -l local_file -r remote_file ip_address
* tftp -g -l local_file -r remote_file ip_address
#### Telnet:
* telnet ip_address
* nc ip_address 23
