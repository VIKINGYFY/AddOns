---@class env
local env = select(2, ...)
local NS = env.C.Frame; env.C.Frame = NS

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
	end

	do -- MAIN

	end

	--------------------------------
	-- EVENTS
	--------------------------------
end
