local skynet = require "skynet"
local socket = require "socket"

local CMD = {}
local client_fd

local function send_package(pack)
	local package = string.pack(">s2", pack)
	socket.write(client_fd, package)
end

function CMD.start(fd)
	client_fd = fd
	socket.start(fd)
	print("agent for " .. fd)
end

function CMD.disconnect()
	-- todo: do something before exit
	skynet.exit()
end

skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		local f = CMD[command]
		skynet.ret(skynet.pack(f(...)))
	end)
end)
