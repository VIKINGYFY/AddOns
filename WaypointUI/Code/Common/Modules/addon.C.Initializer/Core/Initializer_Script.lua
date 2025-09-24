---@class env
local env = select(2, ...)
local CallbackRegistry = env.C.CallbackRegistry.Script
local PrefabRegistry = env.C.PrefabRegistry.Script
local TagManager = env.C.TagManager.Script
local L = env.C.AddonInfo.Locales
local NS = env.C.Initializer; env.C.Initializer = NS

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
		function Callback:LoadCode()
			do -- PRIORITY
				if env.C.AddonInfo.Variables.Initializer.LIST_PRIORITY then
					env.C.AddonInfo.Variables.Initializer.LIST_PRIORITY()
				end

				--------------------------------

				CallbackRegistry:Trigger("ADDON_LOADED_PRIORITY")
			end

			do -- MAIN
				C_Timer.After(.1, function()
					if env.Main then
						env.Main:Load()
					else
						print("|cffFF0000" .. env.C.AddonInfo.Variables.General.IDENTIFIER .. " - Missing reference to 'env.Main'|r")
					end

					--------------------------------

					CallbackRegistry:Trigger("ADDON_LOADED_CODE")
				end)
			end

			--------------------------------

			C_Timer.After(2.5, function()
				NS.Variables.Ready = true
				CallbackRegistry:Trigger("ADDON_LOADED")
			end)
		end

		function Callback:Initalize()
			if InCombatLockdown() then
				NS.Variables.QueuedForInitalization = true
				return
			end
			NS.Variables.QueuedForInitalization = false

			--------------------------------

			if NS.Variables.Initalized then
				return
			end
			NS.Variables.Initalized = true

			--------------------------------

			Callback:LoadCode()
		end
	end

	--------------------------------
	-- EVENTS
	--------------------------------

	do
		local Events = env.C.FrameTemplates:CreateFrame("Frame")
		Events:RegisterEvent("PLAYER_REGEN_ENABLED")
		Events:SetScript("OnEvent", function(_, event, ...)
			if NS.Variables.QueuedForInitalization then
				if event == "PLAYER_REGEN_ENABLED" then
					if not InCombatLockdown() then
						Callback:Initalize()

						Events:UnregisterEvent("PLAYER_REGEN_ENABLED")
					end
				end
			end
		end)
	end

	--------------------------------
	-- SETUP
	--------------------------------

	do
		Callback:Initalize()
	end
end
