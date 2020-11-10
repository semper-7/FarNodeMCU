--FTP server
s=net.createServer(net.TCP, 30)
s:listen(21,function(c)
 c:on("receive",function(c,l)
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
     c:send("250 OK")
    elseif l:sub(1,3)=="PWD" then
     c:send('257 "/" - is only directory\n')
    elseif l:sub(1,4)=="PASV" then
     c:send("227 Entering Passive Mode \("..string.gsub(wifi.sta.getip(),"%p+",",")..",21,179\)\n")
     p=net.createServer(net.TCP, 30)
      p:listen(5555,function(c)
      c:send("FTP data server\n")
      d=c
      end)
    elseif l:sub(1,4)=="LIST" then
     if d then
      c:send("150 Filelist started\n")
      d:send("Filename\tSize\n")
      for f,s in pairs(file.list()) do d:send(f.."   \t"..s.."\n") end
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
