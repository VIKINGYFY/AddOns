local _, addon = ...
local L = addon.L

local function formatPercentage(value)
	return PERCENTAGE_STRING:format(math.floor((value * 100) + 0.5))
end

addon:RegisterSettings('BetterWorldQuestsDB', {
	{
		key = 'mapScale',
		type = 'slider',
		title = L['Map pin scale'],
		tooltip = L['The scale of world quest pins on the current map'],
		default = 1.25,
		minValue = 0.1,
		maxValue = 3,
		valueStep = 0.01,
		valueFormat = formatPercentage,
	},
	{
		key = 'parentScale',
		type = 'slider',
		title = L['Overview pin scale'],
		tooltip = L['The scale of world quest pins on a parent/continent map'],
		default = 1,
		minValue = 0.1,
		maxValue = 3,
		valueStep = 0.01,
		valueFormat = formatPercentage,
	},
	{
		key = 'zoomFactor',
		type = 'slider',
		title = L['Pin size zoom factor'],
		tooltip = L['How much extra scale to apply when map is zoomed'],
		default = 0.5,
		minValue = 0,
		maxValue = 1,
		valueStep = 0.01,
		valueFormat = formatPercentage,
	},
	{
		key = 'hideModifier',
		type = 'menu',
		title = L['Hold key to hide'],
		tooltip = L['Hold this key to temporarily hide all world quests'],
		default = 'ALT',
		options = {
			NEVER = NEVER,
			ALT = ALT_KEY,
			CTRL = CTRL_KEY,
			SHIFT = SHIFT_KEY,
		},
	},
})

addon:RegisterSettingsSlash('/betterworldquests', '/bwq')
