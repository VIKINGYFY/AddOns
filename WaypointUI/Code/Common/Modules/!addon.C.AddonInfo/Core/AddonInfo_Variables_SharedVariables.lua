---@class env
local env = select(2, ...)
local NS = env.C.AddonInfo; env.C.AddonInfo = NS

--------------------------------

NS.Variables = NS.Variables or {}
NS.Variables.SharedVariables = {}

--------------------------------
-- VARIABLES
--------------------------------

do -- MAIN

end

do -- CONSTANTS
	NS.Variables.SharedVariables.PATH_TOOLTIP_DIVIDER = env.CS:GetAddonPathElement() .. "background-tooltip-divider.png"
end
