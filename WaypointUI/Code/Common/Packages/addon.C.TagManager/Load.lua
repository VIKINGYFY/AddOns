---@class env
local env = select(2, ...)

--------------------------------

env.C.TagManager = {}
local NS = env.C.TagManager; env.C.TagManager = NS

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
