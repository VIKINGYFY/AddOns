---@class env
local env = select(2, ...)
local CallbackRegistry = env.C.CallbackRegistry.Script
local PrefabRegistry = env.C.PrefabRegistry.Script
local TagManager = env.C.TagManager.Script
local L = env.C.AddonInfo.Locales
local NS = env.C.EventListener; env.C.EventListener = NS

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

	--------------------------------
	-- EVENTS
	--------------------------------

	do
		local Event_Key = CreateFrame("Frame")
		local function EventKeyInit()
			if InCombatLockdown() then return end
			Event_Key:SetPropagateKeyboardInput(true)
			Event_Key:SetScript("OnKeyDown", function(_, key)
				CallbackRegistry:Trigger("EVENT_KEY_DOWN", key)
			end)
			Event_Key:SetScript("OnKeyUp", function(_, key)
				CallbackRegistry:Trigger("EVENT_KEY_UP", key)
			end)
			CallbackRegistry:Add("EVENT_PREVENT_KEY", function()
				if not InCombatLockdown() then
					Event_Key:SetPropagateKeyboardInput(false)
					C_Timer.After(0, function()
						Event_Key:SetPropagateKeyboardInput(true)
					end)
				end
			end)
		end
		EventKeyInit()

		local Event_General = CreateFrame("Frame")
		Event_General:RegisterEvent("UI_SCALE_CHANGED")
		Event_General:RegisterEvent("GLOBAL_MOUSE_DOWN")
		Event_General:RegisterEvent("GLOBAL_MOUSE_UP")
		Event_General:RegisterEvent("CINEMATIC_START")
		Event_General:RegisterEvent("CINEMATIC_STOP")
		Event_General:RegisterEvent("PLAY_MOVIE")
		Event_General:RegisterEvent("STOP_MOVIE")
		Event_General:RegisterEvent("CVAR_UPDATE")
		Event_General:RegisterEvent("PLAYER_REGEN_ENABLED")
		Event_General:SetScript("OnEvent", function(self, event, ...)
			if event == "GLOBAL_MOUSE_DOWN" then
				CallbackRegistry:Trigger("EVENT_MOUSE_DOWN", ...)
			elseif event == "GLOBAL_MOUSE_UP" then
				CallbackRegistry:Trigger("EVENT_MOUSE_UP", ...)
			end

			if event == "UI_SCALE_CHANGED" then
				CallbackRegistry:Trigger("UI_SCALE_CHANGED", ...)
			end

			if event == "CINEMATIC_START" or event == "PLAY_MOVIE" then
				CallbackRegistry:Trigger("EVENT_CINEMATIC_START", ...)
			elseif event == "CINEMATIC_STOP" or event == "STOP_MOVIE" then
				CallbackRegistry:Trigger("EVENT_CINEMATIC_STOP", ...)
			end

			if event == "CVAR_UPDATE" then
				CallbackRegistry:Trigger("EVENT_CVAR_UPDATE", ...)
			end

			if event == "PLAYER_REGEN_ENABLED" then
				EventKeyInit()
			end
		end)
	end

	--------------------------------
	-- SETUP
	--------------------------------
end
