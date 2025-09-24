---@class env
local env = select(2, ...)

--------------------------------

env.C.Initializer = {}
local NS = env.C.Initializer; env.C.Initializer = NS

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
