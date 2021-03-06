# FarNodeMCU
Project for ESP8266 NodeMCU. First of all, we created an environment for developing and writing lua files based on FAR manager. The colorer plugin FAR supports LUA syntax.
To solve the problem, utilities for working with ESP were written in MASM32: lineterm.exe - mini console terminal, netterm.exe - TCP terminal is a simplified analog of nc in linux. Their size is only 3072 bytes.
Cmd and sh scripts are also created for writing lua scripts to ESP: lua_wr, net_wr and tftp_lua.
Telnet~.lua and tftp~.lua compatible servers were written accordingly.
Telnet server with support for simple linux commands: ls, cat, rm, mem, reboot and with the ability to run Lua scripts simply by typing their name in the command line, i.e. file.lua instead dofile("file.lua").
Tftp server support oktet mode only.
The "~" character in the file name was used to autorun files in ESP, implemented in init.lua.

## Command line formats
### Windows (more needed utils: lineterm.exe, netterm.exe, busybox.exe)
#### File forwarding
``` cmd
lua_wr.cmd file.lua
net_wr.cmd file.lua | busybox nc ip_address 23
tftp_lua.cmd ip_address file.lua
tftp -i ip_address PUT filename
tftp -i ip_address GET filename
```
#### Telnet
``` cmd
* netterm ip_address 23
* busybox nc ip_address 23
```
#### UART terminal
``` cmd
lineterm COM_port_number 115200
```
#### Clone and Build
``` cmd
git clone https://github.com/semper-7/FarNodeMCU
cd FarNodeMCU
lineterm.bat
netterm.bat
```
### Linux:
#### File forwarding:
``` sh
lua_wr.sh file.lua | /dev/ttyUSB0
lua_wr.sh file.lua | nc ip_address 23
tftp_lua.sh ip_address file.lua
tftp -p -l local_file -r remote_file ip_address
tftp -g -l local_file -r remote_file ip_address
```
#### Telnet:
``` sh
telnet ip_address
nc ip_address 23
```
#### UART terminal
``` sh
stty 115200 -F /dev/ttyUSB0 raw -echo
cat /dev/ttyUSB0 | tee term.log
```
## Links:
### Far manager official site
* https://www.farmanager.com
### Port for linux:
* https://github.com/elfmz/far2l
### MASM32 SDK official site
* https://www.masm32.com/
