---@class env
local env = select(2, ...)

--------------------------------

env.C.PrefabRegistry = {}
local NS = env.C.PrefabRegistry; env.C.PrefabRegistry = NS

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
