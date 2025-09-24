---@class env
local env = select(2, ...)
local CallbackRegistry = env.C.CallbackRegistry.Script
local PrefabRegistry = env.C.PrefabRegistry.Script
local TagManager = env.C.TagManager.Script
local L = env.C.AddonInfo.Locales

--------------------------------

env.Main = {}
local NS = env.Main; env.Main = NS

--------------------------------

function NS:Load()
	local function Modules()
		env.ContextIcon:Load()
		env.MapPin:Load()
		env.Query:Load()
        env.WaypointSystem:Load()
	end

	--------------------------------

	Modules()
end
