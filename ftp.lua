--FTP server
s=net.createServer(net.TCP, 30)
s:listen(21,function(c)
 c:on("receive",function(c,l)
  uart.write(0,l)
  if l:sub(1,4)=="QUIT" then
   c:send("221 Goodbye\n")
   I=false
   if d then d:close(); d=nil end
   if p then p:close(); p=nil end
   tf=tmr.create()
   tf:alarm(300, tmr.ALARM_SINGLE, function() c:close() end)
  elseif l:sub(1,5)=="USER " then
   if l:match("%S+",6)=="lua" then
    c:send("331 Now the PASS\n")
   else
    c:send("530 User incorrect\n")
   end
  elseif l:sub(1,5)=="PASS " then
   if l:match("%S+",6)=="lua" then
    c:send("230 Login successful\n")
    I=true
   else
    c:send("530 Login incorrect\n")
   end
  else
   if I then
    if l:sub(1,5)=="DELE " then
     file.remove(l:match("%S+",6))
     c:send("250 OK\n")
    elseif l:sub(1,3)=="PWD" then
     c:send('257 "/" - only folder\n')
    elseif l:sub(1,3)=="CWD" then
     c:send("250 OK\n")
    elseif l:sub(1,4)=="SYST" then
     c:send("215 UNIX Type: L8\n")
    elseif l:sub(1,4)=="FEAT" then
     c:send("211-Features:\nPASV\nSIZE\n211 End\n")
    elseif l:sub(1,4)=="PASV" then
     c:send("227 Entering Passive Mode \("..string.gsub(wifi.sta.getip(),"%p+",",")..",21,179\)\n")
     p=net.createServer(net.TCP, 30)
     p:listen(5555,function(c) d=c end)
    elseif l:sub(1,4)=="TYPE" then
     c:send("200 OK\n")
    elseif l:sub(1,4)=="LIST" then
     if d then
      c:send("150 File listing started\n")
      for f,s in pairs(file.list()) do d:send("-rw-r--r-- 1 0 0 "..s.."	01 Jan 20 00:00 "..f.."\n") end
      c:send("226 Filelist sended\n")
     else
      c:send("550 Enter PASV and connect first\n")
     end
    else  
     c:send("550 Invalid command\n")
    end
   else
    c:send("530 Enter USER and PASS first\n")
   end
  end
 end)
 c:send("220 Welcome to NodeMCU FTP server\n")
end)

print(("FTP server started (%d mem free, %s)"):format(node.heap(), wifi.sta.getip()))
