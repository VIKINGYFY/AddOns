---@class env
local env = select(2, ...)

--------------------------------

env.C.CallbackRegistry = {}
local NS = env.C.CallbackRegistry; env.C.CallbackRegistry = NS

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
