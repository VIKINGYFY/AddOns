---@class env
local env = select(2, ...)
local CallbackRegistry = env.C.CallbackRegistry.Script

--------------------------------

env.C.Frame.ContextMenu = {}
local NS = env.C.Frame.ContextMenu; env.C.Frame.ContextMenu = NS

--------------------------------

function NS:Load()
	local function Variables()
		NS.Variables:Load()
	end

	local function Modules()
		NS.Elements:Load()
		NS.Script:Load()
	end

	local function Prefabs()
		NS.Prefabs:Load()
	end

	--------------------------------

	Variables()
	Prefabs()
	Modules()
end
