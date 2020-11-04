# FarNodeMCU
Project for ESP8266 NodeMCU. First of all, we created an environment for developing and writing lua files based on FAR manager.
To solve the problem, utilities for working with ESP were written in MASM32: lineterm.exe - mini console terminal, netterm.exe - TCP terminal is a simplified analog of nc in linux.
Cmd scripts are also created for writing lua scripts to ESP: lua_wr uses lineterm.exe, net_wr.cmd uses netterm.exe and a telnet server running in ESP, and tftp_lua is sed.exe and a tftp server.
Telnet~.lua and tftp~.lua compatible servers were written accordingly.
Telnet server with support for simple linux commands: ls, cat, rm, mem, reboot.
The " ~ " character in the file name was used to autorun files in ESP, implemented in init.lua.
