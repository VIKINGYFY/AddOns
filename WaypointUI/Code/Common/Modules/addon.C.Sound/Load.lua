---@class env
local env = select(2, ...)

--------------------------------

env.C.Sound = {}
local NS = env.C.Sound; env.C.Sound = NS

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
