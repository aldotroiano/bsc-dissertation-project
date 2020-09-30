function check_internet_connection()
local socket = require("socket")
--PINGING GOOGLE TO CHECK INTERNET CONNECTIVITY
local check = socket.tcp()
check:settimeout(1000)
local available = check:connect("www.google.com", 80)
if available ~= 1 then
   print("Internet NOT OK")
    available = 0
end
check:close()
return available
end
