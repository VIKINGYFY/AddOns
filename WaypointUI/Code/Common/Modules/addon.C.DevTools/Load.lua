---@class env
local env = select(2, ...)

--------------------------------

env.C.DevTools = {}
local NS = env.C.DevTools; env.C.DevTools = NS

--------------------------------

function NS:Load()
	local function Variables()
		NS.Variables:Load()
	end

	local function Modules()
		NS.Script:Load()
	end

	--------------------------------

	Variables()
	Modules()
end
