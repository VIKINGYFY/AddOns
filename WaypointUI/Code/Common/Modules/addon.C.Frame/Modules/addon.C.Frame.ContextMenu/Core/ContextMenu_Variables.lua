---@class env
local env = select(2, ...)
local CallbackRegistry = env.C.CallbackRegistry.Script
local PrefabRegistry = env.C.PrefabRegistry.Script
local TagManager = env.C.TagManager.Script
local L = env.C.AddonInfo.Locales
local NS = env.C.Frame.ContextMenu; env.C.Frame.ContextMenu = NS

--------------------------------

NS.Variables = {}

--------------------------------

function NS.Variables:Load()
	--------------------------------
	-- VARIABLES
	--------------------------------

	do -- CONSTANTS
		do -- SCALE
			NS.Variables.RATIO_REFERENCE = 1000

			--------------------------------

			do -- FUNCTIONS
				function NS.Variables:RATIO(level)
					return NS.Variables.RATIO_REFERENCE / env.C.Variables:RAW_RATIO(level)
				end
			end
		end

		do -- MAIN
			NS.Variables.PATH = nil

			NS.Variables.FRAME_STRATA = "FULLSCREEN_DIALOG"
			NS.Variables.FRAME_LEVEL = 999
			NS.Variables.FRAME_LEVEL_MAX = 1999
		end

		do -- PADDING
			NS.Variables.PADDING = NS.Variables:RATIO(8)
		end
	end

	do -- MAIN

	end

	--------------------------------
	-- EVENTS
	--------------------------------
end
