local skynet = require "skynet"
local socket = require "socket"

local CMD = {}
local client_fd

local function send_package(pack)
	local package = string.pack(">s2", pack)
	socket.write(client_fd, package)
end

local function make_header( mcmd, scmd, len )
	local header = nil
	return header
end

function CMD.runloop( fd )
	while(socket.block(fd)) do
		local len = socket.read(fd, 4)
		len = string.unpack(">I4", len)
		local str = socket.read(fd, len)
		print(string.format("[%d] Received: %s", fd, str))
	end
	print("end while")
	skynet.call("GATE", "lua", "close", fd)
end

function CMD.start(fd)
	client_fd = fd
	socket.start(fd)
	print("agent for fd " .. fd)
	skynet.send(skynet.self(), "lua", "runloop", fd)
end

function CMD.response( data )
	send_package(data)
end

function CMD.disconnect()
	-- todo: do something before exit
 	skynet.exit()
end

skynet.start(function()
 	skynet.dispatch("lua", function(_, source, command, ...)
		local f = CMD[command]
		f(...)
	end)
end)
