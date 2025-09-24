---@class env
local env = select(2, ...)
local NS = env.C.SharedVariables; env.C.SharedVariables = NS

--------------------------------

NS.Util = {}

--------------------------------
-- VARIABLES
--------------------------------

do  -- MAIN

end

do  -- CONSTANTS

end

--------------------------------
-- FUNCTIONS (TOOLTIP)
--------------------------------

do
	function NS.Util:NewTooltipDivider(width)
		return "\n" .. env.C.API.Util:InlineIcon(env.C.AddonInfo.Variables.SharedVariables.PATH_TOOLTIP_DIVIDER, 1, width, 0, 0) .. "\n"
	end
end

--------------------------------
-- EVENTS
--------------------------------

do

end
