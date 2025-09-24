---@class env
local env = select(2, ...)

--------------------------------

env.CS = {}
local NS = env.CS; env.CS = NS

--------------------------------
-- SHARED FUNCTIONS
--------------------------------

do
	do -- Get
		-- Returns add-on name.
		function NS:GetAddonName() return env.C.AddonInfo.Variables.General.NAME end

		-- Returns add-on version string.
		function NS:GetAddonVersionString() return env.C.AddonInfo.Variables.General.VERSION_STRING end

		-- Returns add-on version number.
		function NS:GetAddonVersionNumber() return env.C.AddonInfo.Variables.General.VERSION_NUMBER end

		-- Returns general add-on frame.
		function NS:GetAddonFrame() return env.C.AddonInfo.Variables.General.ADDON_FRAME end

		-- Returns general Common Framework frame.
		function NS:GetCommonFrame() return env.C.AddonInfo.Variables.General.COMMON_FRAME end

		-- Returns add-on general path.
		function NS:GetAddonPath() return env.C.AddonInfo.Variables.General.ADDON_PATH end

		-- Returns add-on font path.
		function NS:GetAddonPathFont() return env.C.AddonInfo.Variables.General.ADDON_PATH_FONT end

		-- Returns add-on element path.
		function NS:GetAddonPathElement() return env.C.AddonInfo.Variables.General.ADDON_PATH_ELEMENT end

		-- Returns add-on audio path.
		function NS:GetAddonPathSound() return env.C.AddonInfo.Variables.General.ADDON_PATH_SOUND end

		-- Returns Common Framework path.
		function NS:GetCommonPath() return env.C.AddonInfo.Variables.General.COMMON_PATH end

		-- Returns Common Framework art path.
		function NS:GetCommonPathArt() return env.C.AddonInfo.Variables.General.COMMON_PATH_ART end

		-- Returns Common Framework art -> config path.
		function NS:GetCommonPathConfig() return env.C.AddonInfo.Variables.General.COMMON_PATH_ART .. "Config/" end

		-- Returns Common Framework art -> element path.
		function NS:GetCommonPathElement() return env.C.AddonInfo.Variables.General.COMMON_PATH_ART .. "Elements/" end

		-- Returns shared variable / color.
		function NS:GetSharedColor() return env.C.SharedVariables.Color end

		-- Returns shared variable / util.
		function NS:GetSharedUtil() return env.C.SharedVariables.Util end
	end

	do -- Image / Icon
		-- Returns icon path using the specified name. File name only - exclude file extension.
		---@param iconName string
		---@return string iconPath
		function NS:NewIcon(iconName) return env.C.AddonInfo.Variables.General.COMMON_PATH_ART .. "Icons/" .. iconName .. ".png" end

		-- Returns inline icon using the specified name. File name only - exclude file extension.
		---@param iconName string
		---@param size number
		---@return string inlineIconString
		function NS:GetInlineIcon(iconName, size) return env.C.API.Util:InlineIcon(env.CS:GetCommonPathArt() .. "Icons/" .. iconName .. ".png", size, size, 0, 0, "Texture") end

		-- Returns chat icon using the specified name. File name only - exclude file extension.
		---@param iconName string
		---@param size number
		---@return string chatIconString
		function NS:GetChatIcon(iconName, size) return env.C.API.Util:InlineIcon(env.CS:GetCommonPathArt() .. "Chat/" .. iconName .. ".png", size, size, 0, 0, "Texture") end

		-- Returns the a icon in in-line icon format.
		---@param size number
		---@return string inlineIconString
		function NS:GetAddonInlineIcon(size) return env.C.API.Util:InlineIcon(env.C.AddonInfo.Variables.General.ADDON_ICON_ALT, size, size, 0, 0, "Texture") end
	end

	do -- Font
		-- Creates a new font info object.
		function NS:NewFontInfo(name, path, sizeModifier)
			local fontInfo = {
				name = name,
				path = path,
				sizeModifier = sizeModifier
			}
			return fontInfo
		end

		-- Calculates the text size after applying font scaling.
		function NS:NewFontSize(original, modifier)
			return math.ceil(original * modifier)
		end

		-- Checks if the provided font is valid & exists.
		function NS:CheckFontIntegrity(fontInfo)
			-- check if font info is missing info
			if not fontInfo.name or not fontInfo.path or not fontInfo.sizeModifier then
				return false
			end

			-- check if font file path exists in all fonts list
			if env.C.Fonts and env.C.Fonts.Script and env.C.Fonts.Script.CustomFontUtil then
				local allFonts = env.C.Fonts.Script.CustomFontUtil:GetAllFonts()
				for k, v in pairs(allFonts) do
					if v.path == fontInfo.path then
						return true
					end
				end
			end

			return false
		end
	end
end
