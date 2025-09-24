---@class env
local env = select(2, ...)
local CallbackRegistry = env.C.CallbackRegistry.Script
local PrefabRegistry = env.C.PrefabRegistry.Script
local TagManager = env.C.TagManager.Script
local L = env.C.AddonInfo.Locales
local NS = env.C.Database; env.C.Database = NS

--------------------------------

NS.Variables = {}

--------------------------------

function NS.Variables:Load()
	--------------------------------
	-- VARIABLES
	--------------------------------

	do -- MAIN
		NS.Variables.DB_GLOBAL = nil
		NS.Variables.DB_LOCAL = nil
		NS.Variables.DB_GLOBAL_PERSISTENT = nil
		NS.Variables.DB_LOCAL_PERSISTENT = nil
	end

	do -- CONSTANTS

	end
end
