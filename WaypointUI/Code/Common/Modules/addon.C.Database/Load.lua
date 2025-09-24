---@class env
local env = select(2, ...)
local CallbackRegistry = env.C.CallbackRegistry.Script
local PrefabRegistry = env.C.PrefabRegistry.Script
local TagManager = env.C.TagManager.Script
local L = env.C.AddonInfo.Locales

--------------------------------

env.C.Database = {}
local NS = env.C.Database; env.C.Database = NS

--------------------------------

function NS:Load()
	local function Variables()
		NS.Variables:Load()
	end

	local function Modules()
		NS.Script:Load()
	end

	local function Submodules()
		NS.Migration:Load()
	end

	--------------------------------

	Variables()
	Modules()
	C_Timer.After(.1, Submodules)
end
