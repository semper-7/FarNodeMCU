@echo off
setlocal enabledelayedexpansion
if "%1"=="" echo Command line: %~n0 filename.lua ^| netterm.exe ip_address 23&pause&exit
call :delay 500
echo file.remove("%1"); file.open("%1","w+"); w = file.writeline
call :delay 1
for /f "tokens=*" %%X in (%1) do echo w([==[%%X]==])& call :delay 1
echo file.close(); collectgarbage()
call :delay 1
echo exit
exit

:delay
ping -n 1 -w 1 192.192.192.192> nul
exit /b