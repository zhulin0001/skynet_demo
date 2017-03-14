local skynet = require "skynet"
require "skynet.manager"
local snax = require "snax"

local CMD = {}
local gate

local function close_agent(fd)
	skynet.call(gate, "lua", "kick", fd)
end

function CMD.start(conf)
	skynet.register("watchdog")
	skynet.call(gate, "lua", "open" , conf)
end

function CMD.close(fd)
	close_agent(fd)
end

skynet.start(function()
	skynet.dispatch("lua", function(session, source, cmd, subcmd, ...)
		local f = assert(CMD[cmd])
		skynet.ret(skynet.pack(f(subcmd, ...)))
	end)
	gate = skynet.newservice("gate")
	skynet.name("GATE", gate)
	skynet.name("PHPPROXY", skynet.newservice("phpproxy"))
	skynet.name("PBC", skynet.newservice("pbc"))
	--local pbc = snax.newservice("pbc")
	--skynet.newservice("testping")
	--local pb = pbc.req.getObj()
	--print(pb.enum_id("network.com.PBMainCmd", "MCmd_Account"))
end)
