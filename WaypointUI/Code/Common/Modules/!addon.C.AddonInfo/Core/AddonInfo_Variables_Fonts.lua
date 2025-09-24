---@class env
local env = select(2, ...)
local NS = env.C.AddonInfo; env.C.AddonInfo = NS

--------------------------------

NS.Variables = NS.Variables or {}
NS.Variables.Fonts = {}

--------------------------------
-- VARIABLES
--------------------------------

do -- MAIN

end

do -- CONSTANTS
	do -- FONTS
		NS.Variables.Fonts.FONT_TABLE = {
			["enUS"] = {
				["CONTENT_DEFAULT"] = env.CS:NewFontInfo("Default", GameFontNormal:GetFont(), 1),
			},
			["deDE"] = {
				["CONTENT_DEFAULT"] = env.CS:NewFontInfo("Default", GameFontNormal:GetFont(), 1),
			},
			["esES"] = {
				["CONTENT_DEFAULT"] = env.CS:NewFontInfo("Default", GameFontNormal:GetFont(), 1),
			},
			["esMX"] = {
				["CONTENT_DEFAULT"] = env.CS:NewFontInfo("Default", GameFontNormal:GetFont(), 1),
			},
			["frFR"] = {
				["CONTENT_DEFAULT"] = env.CS:NewFontInfo("Default", GameFontNormal:GetFont(), 1),
			},
			["itIT"] = {
				["CONTENT_DEFAULT"] = env.CS:NewFontInfo("Default", GameFontNormal:GetFont(), 1),
			},
			["koKR"] = {
				["CONTENT_DEFAULT"] = env.CS:NewFontInfo("Default", GameFontNormal:GetFont(), 1),
			},
			["ptBR"] = {
				["CONTENT_DEFAULT"] = env.CS:NewFontInfo("Default", GameFontNormal:GetFont(), 1),
			},
			["ruRU"] = {
				["CONTENT_DEFAULT"] = env.CS:NewFontInfo("Default", GameFontNormal:GetFont(), 1),
			},
			["zhCN"] = {
				["CONTENT_DEFAULT"] = env.CS:NewFontInfo("Default", GameFontNormal:GetFont(), 1.25),
			},
			["zhTW"] = {
				["CONTENT_DEFAULT"] = env.CS:NewFontInfo("Default", GameFontNormal:GetFont(), 1.25),
			},
		}
	end
end
