---@class env
local env = select(2, ...)
local NS = env.C.AddonInfo; env.C.AddonInfo = NS

--------------------------------

NS.Variables = NS.Variables or {}
NS.Variables.GameTooltip = {}

--------------------------------
-- VARIABLES
--------------------------------

do -- MAIN

end

do -- CONSTANTS
	NS.Variables.GameTooltip.TOOLTIP_STYLE = {
		["GameTooltip"] = {
			["texture"] = env.CS:GetCommonPathArt() .. "Tooltip/background-generic.png",
			["modifier"] = .275
		},
		["ShoppingTooltip1"] = {
			["texture"] = env.CS:GetCommonPathArt() .. "Tooltip/background-generic.png",
			["modifier"] = .175
		},
		["ShoppingTooltip2"] = {
			["texture"] = env.CS:GetCommonPathArt() .. "Tooltip/background-generic.png",
			["modifier"] = .175
		}
	}
end
