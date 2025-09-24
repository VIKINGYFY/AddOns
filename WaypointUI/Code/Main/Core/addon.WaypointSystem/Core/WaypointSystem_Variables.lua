---@class env
local env = select(2, ...)
local CallbackRegistry = env.C.CallbackRegistry.Script
local PrefabRegistry = env.C.PrefabRegistry.Script
local TagManager = env.C.TagManager.Script
local L = env.C.AddonInfo.Locales
local NS = env.WaypointSystem; env.WaypointSystem = NS

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
			NS.Variables.PATH = env.CS:GetAddonPathElement() .. "Waypoint/"
			NS.Variables.PADDING = 10

			NS.Variables.FRAME_STRATA = "BACKGROUND"
			NS.Variables.FRAME_LEVEL = 99
			NS.Variables.FRAME_LEVEL_MAX = 999
		end
	end

	do -- MAIN
		NS.Variables.IsActive = false -- check for whether the waypoint system is updating

		NS.Variables.ArrivalTime = nil
		NS.Variables.Session = {}
	end

	--------------------------------
	-- EVENTS
	--------------------------------


end
