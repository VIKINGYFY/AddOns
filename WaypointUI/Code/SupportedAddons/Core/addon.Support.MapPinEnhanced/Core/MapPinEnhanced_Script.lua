---@class env
local env = select(2, ...)
local CallbackRegistry = env.C.CallbackRegistry.Script
local PrefabRegistry = env.C.PrefabRegistry.Script
local TagManager = env.C.TagManager.Script
local L = env.C.AddonInfo.Locales
local NS = env.Support.MapPinEnhanced; env.Support.MapPinEnhanced = NS

--------------------------------

NS.Script = {}

--------------------------------

function NS.Script:Load()
	--------------------------------
	-- REFERENCES
	--------------------------------

	local Frame = MapPinEnhancedSuperTrackedPin
	local Database = MapPinEnhancedDB
	local Callback = NS.Script; NS.Script = Callback

	--------------------------------
	-- FUNCTIONS (MAIN)
	--------------------------------

	do
		do -- OVERRIDE
			function Callback:HideElements()
				if Frame then
					Frame:HookScript("OnShow", function()
						Frame:Hide()
					end)
				end
			end
		end

		do -- GET
			function Callback:GetSets()
				for set, setContent in pairs(Database.sets) do
					for pin, pinContent in pairs(setContent.pins) do
						-- Pin content
					end
				end
			end
		end

		do -- SET

		end
	end

	--------------------------------
	-- EVENTS
	--------------------------------

	--------------------------------
	-- SETUP
	--------------------------------

	do
		Callback:HideElements()
	end
end
