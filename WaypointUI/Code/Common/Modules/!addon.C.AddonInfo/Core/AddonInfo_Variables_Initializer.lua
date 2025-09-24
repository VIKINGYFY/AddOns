---@class env
local env = select(2, ...)
local NS = env.C.AddonInfo; env.C.AddonInfo = NS

--------------------------------

NS.Variables = NS.Variables or {}
NS.Variables.Initializer = {}

--------------------------------
-- VARIABLES
--------------------------------

do -- MAIN

end

do -- CONSTANTS
	do -- LOAD
		NS.Variables.Initializer.LIST_PRIORITY = function()

		end
	end
end
