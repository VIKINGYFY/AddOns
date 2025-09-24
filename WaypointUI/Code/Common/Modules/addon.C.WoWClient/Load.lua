---@class env
local env = select(2, ...)

--------------------------------

env.C.WoWClient = {}
local NS = env.C.WoWClient; env.C.WoWClient = NS

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
