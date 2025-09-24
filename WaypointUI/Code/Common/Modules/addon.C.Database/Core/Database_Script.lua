---@class env
local env = select(2, ...)
local CallbackRegistry = env.C.CallbackRegistry.Script
local PrefabRegistry = env.C.PrefabRegistry.Script
local TagManager = env.C.TagManager.Script
local L = env.C.AddonInfo.Locales
local NS = env.C.Database; env.C.Database = NS
local AceDB = LibStub("AceDB-3.0")

--------------------------------

NS.Script = {}

--------------------------------

function NS.Script:Load()
	--------------------------------
	-- REFERENCES
	--------------------------------

	local Callback = NS.Script; NS.Script = Callback

	--------------------------------
	-- FUNCTIONS (MAIN)
	--------------------------------

	do
		function Callback:ResetCache()
			_G[env.C.AddonInfo.Variables.Database.GLOBAL_NAME] = nil
			_G[env.C.AddonInfo.Variables.Database.LOCAL_NAME] = nil
		end

		function Callback:ResetAll()
			Callback:ResetCache()

			--------------------------------

			_G[env.C.AddonInfo.Variables.Database.GLOBAL_PERSISTENT_NAME] = nil
			_G[env.C.AddonInfo.Variables.Database.LOCAL_PERSISTENT_NAME] = nil
		end
	end

	--------------------------------
	-- EVENTS
	--------------------------------

	--------------------------------
	-- SETUP
	--------------------------------
end

function NS.Script:OnInitialize()
	env.C.Libraries.AceTimer:ScheduleTimer(function()
		NS.Variables.DB_GLOBAL = AceDB:New(env.C.AddonInfo.Variables.Database.GLOBAL_NAME, env.C.AddonInfo.Variables.Database.GLOBAL_DEFAULT, true)
		NS.Variables.DB_LOCAL = AceDB:New(env.C.AddonInfo.Variables.Database.LOCAL_NAME, env.C.AddonInfo.Variables.Database.LOCAL_DEFAULT, true)
		NS.Variables.DB_GLOBAL_PERSISTENT = AceDB:New(env.C.AddonInfo.Variables.Database.GLOBAL_PERSISTENT_NAME, env.C.AddonInfo.Variables.Database.GLOBAL_PERSISTENT_DEFAULT, true)
		NS.Variables.DB_LOCAL_PERSISTENT = AceDB:New(env.C.AddonInfo.Variables.Database.LOCAL_PERSISTENT_NAME, env.C.AddonInfo.Variables.Database.LOCAL_PERSISTENT_DEFAULT, true)
	end, .1)
end

LibStub("AceAddon-3.0"):NewAddon(NS.Script, env.C.AddonInfo.Variables.General.IDENTIFIER)
