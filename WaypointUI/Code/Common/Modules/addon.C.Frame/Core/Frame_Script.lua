---@class env
local env = select(2, ...)
local CallbackRegistry = env.C.CallbackRegistry.Script
local PrefabRegistry = env.C.PrefabRegistry.Script
local TagManager = env.C.TagManager.Script
local L = env.C.AddonInfo.Locales
local NS = env.C.Frame; env.C.Frame = NS

--------------------------------

NS.Script = {}

--------------------------------

function NS.Script:Load()
	--------------------------------
	-- REFERENCES
	--------------------------------

	local Frame = env.C.AddonInfo.Variables.General.ADDON_FRAME
	local Callback = NS.Script; NS.Script = Callback

	--------------------------------
	-- FUNCTIONS (FRAME)
	--------------------------------

	--------------------------------
	-- FUNCTIONS (MAIN)
	--------------------------------

	--------------------------------
	-- FUNCTIONS (ANIMATION)
	--------------------------------

	--------------------------------
	-- EVENTS
	--------------------------------

	do
		CallbackRegistry:Add("EVENT_CINEMATIC_START", function()
			Frame:Hide()
		end)

		CallbackRegistry:Add("EVENT_CINEMATIC_STOP", function()
			Frame:Show()
		end)
	end

	--------------------------------
	-- SETUP
	--------------------------------
end
