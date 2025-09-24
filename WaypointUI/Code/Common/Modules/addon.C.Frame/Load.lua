---@class env
local env = select(2, ...)

--------------------------------

env.C.Frame = {}
local NS = env.C.Frame; env.C.Frame = NS

--------------------------------

function NS:Load()
	local function Variables()
		NS.Variables:Load()
	end

	local function Modules()
		NS.Elements:Load()
		NS.Script:Load()
	end

	local function Submodules()
		NS.GameTooltip:Load()
		NS.ContextMenu:Load()
	end

	--------------------------------

	Variables()
	Modules()
	C_Timer.After(.1, Submodules)
end
