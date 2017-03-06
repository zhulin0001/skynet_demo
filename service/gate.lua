local skynet = require "skynet"
local socket = require "socket"

local watchdog
local maxclient
local client_number = 0
local agent = {}
local loginserver

local CMD = {}

local function close_agent( fd )
	local a = agent[fd]
	agent[fd] = nil
	if a then
		skynet.send(a, "lua", "disconnect")
	end
end

function CMD.forward( fd )
end

function CMD.open(conf)
	local address = conf.address or "0.0.0.0"
	local port = assert(conf.port)
	maxclient = conf.maxclient or 1024
	local id = socket.listen(address, port)
	skynet.error(string.format("Listen on %s:%d", address, port))
	socket.start(id, function ( id, addr )
		agent[id] = skynet.newservice("agent")
		skynet.send(agent[id], "lua", "start", id)
		skynet.error(string.format("%s connected, open agent", addr))
	end)
end

function CMD.close( fd )
	print("Will close " .. fd)
	socket.close(fd)
	close_agent(fd)
end

skynet.start(function()
	skynet.dispatch("lua", function(session, source, cmd, ...)
		local f = CMD[cmd]
		skynet.ret(skynet.pack(f(...)))
	end)
	loginserver = skynet.newservice("loginserver")
end)
