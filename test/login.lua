package.cpath = "../luaclib/?.so;../skynet/luaclib/?.so;../3rd/pbc/binding/lua53/?.so"
package.path = "../lualib/?.lua;../3rd/pbc/binding/lua53/?.lua"

if _VERSION ~= "Lua 5.3" then
	error "Use lua 5.3"
end

local socket = require "clientsocket"

--parser.register("common.proto", ".")
--parser.register("errno.proto", ".")
--parser.register("cmd.proto", ".")

local fd = assert(socket.connect("127.0.0.1", 8888))

local function send_login()
	local name = "zhulin"
	local data = string.pack(">I4", string.len(name))
	socket.send(fd, data..name)
end

local function bin2hex(s)
    s=string.gsub(s,"(.)",function (x) return string.format("%02X ",string.byte(x)) end)
    return s
end

local function dispatch_package()
	local r = socket.recv(fd)
	if r then
		local len = string.unpack(">s4", r)
		if len then
			--r = socket.recv(fd, len)
			print(string.format("[%d] Received: %s %s", fd, len, bin2hex(r)))
		end
	end
end
send_login()
dispatch_package()
while true do
	local input = socket.readstdin()
	if input then
		if input=="r" then
			dispatch_package()
		elseif input == "q" then
			break
		else
			socket.send(fd, string.pack(">I4", string.len(input))..input)
		end
	end
	socket.usleep(100)
end
