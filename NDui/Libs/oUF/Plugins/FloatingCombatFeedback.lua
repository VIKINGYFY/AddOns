-----------------------------------------------
-- oUF_FloatingCombatFeedback, by lightspark
-- NDui MOD
-----------------------------------------------
local _, ns = ...
local B, C, L, DB = unpack(ns)
local oUF = ns.oUF
assert(oUF, "oUF FloatingCombatFeedback was unable to locate oUF install")

-- 基础属性定义
local SCHOOL_NONE     = 0x00 -- 0x00 or 0 (灰色)
local SCHOOL_PHYSICAL = 0x01 -- 0x01 or 1 (黄色)
local SCHOOL_HOLY     = 0x02 -- 0x02 or 2 (浅黄色/金色)
local SCHOOL_FIRE     = 0x04 -- 0x04 or 4 (橙色)
local SCHOOL_NATURE   = 0x08 -- 0x08 or 8 (浅绿色)
local SCHOOL_FROST    = 0x10 -- 0x10 or 16 (浅蓝色/青色)
local SCHOOL_SHADOW   = 0x20 -- 0x20 or 32 (紫色)
local SCHOOL_ARCANE   = 0x40 -- 0x40 or 64 (粉色/洋红色)

-- 混合属性的定义（按位或组合）
local SCHOOL_MASK_HOLYFIRE    = SCHOOL_HOLY + SCHOOL_FIRE -- 0x06 or 6
local SCHOOL_MASK_HOLYSTORM   = SCHOOL_HOLY + SCHOOL_NATURE -- 0x0A or 10
local SCHOOL_MASK_FIRESTORM   = SCHOOL_FIRE + SCHOOL_NATURE -- 0x0C or 12
local SCHOOL_MASK_ELEMENTAL   = SCHOOL_FIRE + SCHOOL_NATURE + SCHOOL_FROST -- 0x1C or 28
local SCHOOL_MASK_HOLYFROST   = SCHOOL_HOLY + SCHOOL_FROST -- 0x12 or 18
local SCHOOL_MASK_FROSTFIRE   = SCHOOL_FROST + SCHOOL_FIRE -- 0x14 or 20
local SCHOOL_MASK_FROSTSTORM  = SCHOOL_FROST + SCHOOL_NATURE -- 0x18 or 24
local SCHOOL_MASK_TWILIGHT    = SCHOOL_SHADOW + SCHOOL_HOLY -- 0x22 or 34
local SCHOOL_MASK_SHADOWFLAME = SCHOOL_SHADOW + SCHOOL_FIRE -- 0x24 or 36
local SCHOOL_MASK_SHADOWSTORM = SCHOOL_SHADOW + SCHOOL_NATURE -- 0x28 or 40
local SCHOOL_MASK_SHADOWFROST = SCHOOL_SHADOW + SCHOOL_FROST -- 0x30 or 48
local SCHOOL_MASK_CHROMATIC   = SCHOOL_PHYSICAL + SCHOOL_HOLY + SCHOOL_FIRE + SCHOOL_NATURE + SCHOOL_FROST + SCHOOL_SHADOW -- 0x3E or 62
local SCHOOL_MASK_DIVINE      = SCHOOL_ARCANE + SCHOOL_HOLY -- 0x42 or 66
local SCHOOL_MASK_SPELLFIRE   = SCHOOL_ARCANE + SCHOOL_FIRE -- 0x44 or 68
local SCHOOL_MASK_SPELLSTORM  = SCHOOL_ARCANE + SCHOOL_NATURE -- 0x48 or 72
local SCHOOL_MASK_SPELLFROST  = SCHOOL_ARCANE + SCHOOL_FROST -- 0x50 or 80
local SCHOOL_MASK_SPELLSHADOW = SCHOOL_ARCANE + SCHOOL_SHADOW -- 0x60 or 96
local SCHOOL_MASK_COSMIC      = SCHOOL_HOLY + SCHOOL_SHADOW + SCHOOL_ARCANE -- 0x6A or 106
local SCHOOL_MASK_CHAOS       = SCHOOL_FIRE + SCHOOL_NATURE + SCHOOL_FROST + SCHOOL_SHADOW + SCHOOL_ARCANE -- 0x7C or 124
local SCHOOL_MASK_MAGICAL     = SCHOOL_HOLY + SCHOOL_FIRE + SCHOOL_NATURE + SCHOOL_FROST + SCHOOL_SHADOW + SCHOOL_ARCANE -- 0x7E or 126
local SCHOOL_MASK_ALL         = SCHOOL_PHYSICAL + SCHOOL_HOLY + SCHOOL_FIRE + SCHOOL_NATURE + SCHOOL_FROST + SCHOOL_SHADOW + SCHOOL_ARCANE -- 0x7F or 127

local eventColors = {
	COMBAT_IN  = {r = 1, g = 0, b = 0},
	COMBAT_OUT = {r = 0, g = 1, b = 0},
}

local schoolColors = {
	-- 基础属性颜色
	[SCHOOL_NONE]             = {r = 0.50, g = 0.50, b = 0.50}, -- 0x00 or 0 (灰色)
	[SCHOOL_PHYSICAL]         = {r = 1.00, g = 1.00, b = 0.00}, -- 0x01 or 1 (黄色)
	[SCHOOL_HOLY]             = {r = 1.00, g = 1.00, b = 0.50}, -- 0x02 or 2 (浅黄色/金色)
	[SCHOOL_FIRE]             = {r = 1.00, g = 0.50, b = 0.00}, -- 0x04 or 4 (橙色)
	[SCHOOL_NATURE]           = {r = 0.25, g = 1.00, b = 0.25}, -- 0x08 or 8 (浅绿色)
	[SCHOOL_FROST]            = {r = 0.50, g = 1.00, b = 1.00}, -- 0x10 or 16 (浅蓝色/青色)
	[SCHOOL_SHADOW]           = {r = 0.50, g = 0.50, b = 1.00}, -- 0x20 or 32 (紫色)
	[SCHOOL_ARCANE]           = {r = 1.00, g = 0.50, b = 1.00}, -- 0x40 or 64 (粉色/洋红色)

	-- 混合属性颜色（平均值）
	[SCHOOL_MASK_HOLYFIRE]    = { r = 1.00, g = 0.75, b = 0.25 }, -- 0x06 or 6 (HOLY + FIRE)
	[SCHOOL_MASK_HOLYSTORM]   = { r = 0.63, g = 1.00, b = 0.38 }, -- 0x0A or 10 (HOLY + NATURE)
	[SCHOOL_MASK_FIRESTORM]   = { r = 0.63, g = 0.75, b = 0.13 }, -- 0x0C or 12 (FIRE + NATURE)
	[SCHOOL_MASK_HOLYFROST]   = { r = 0.75, g = 1.00, b = 0.75 }, -- 0x12 or 18 (HOLY + FROST)
	[SCHOOL_MASK_FROSTFIRE]   = { r = 0.75, g = 0.75, b = 0.50 }, -- 0x14 or 20 (FROST + FIRE)
	[SCHOOL_MASK_FROSTSTORM]  = { r = 0.38, g = 1.00, b = 0.63 }, -- 0x18 or 24 (FROST + NATURE)
	[SCHOOL_MASK_ELEMENTAL]   = { r = 0.58, g = 0.83, b = 0.42 }, -- 0x1C or 28 (FIRE + NATURE + FROST)
	[SCHOOL_MASK_TWILIGHT]    = { r = 0.75, g = 0.75, b = 0.75 }, -- 0x22 or 34 (SHADOW + HOLY)
	[SCHOOL_MASK_SHADOWFLAME] = { r = 0.75, g = 0.50, b = 0.50 }, -- 0x24 or 36 (SHADOW + FIRE)
	[SCHOOL_MASK_SHADOWSTORM] = { r = 0.38, g = 0.75, b = 0.63 }, -- 0x28 or 40 (SHADOW + NATURE)
	[SCHOOL_MASK_SHADOWFROST] = { r = 0.50, g = 0.75, b = 1.00 }, -- 0x30 or 48 (SHADOW + FROST)
	[SCHOOL_MASK_CHROMATIC]   = { r = 0.71, g = 0.83, b = 0.46 }, -- 0x3E or 62 (PHYSICAL + HOLY + FIRE + NATURE + FROST + SHADOW)
	[SCHOOL_MASK_DIVINE]      = { r = 1.00, g = 0.75, b = 0.75 }, -- 0x42 or 66 (ARCANE + HOLY)
	[SCHOOL_MASK_SPELLFIRE]   = { r = 1.00, g = 0.50, b = 0.50 }, -- 0x44 or 68 (ARCANE + FIRE)
	[SCHOOL_MASK_SPELLSTORM]  = { r = 0.63, g = 0.75, b = 0.63 }, -- 0x48 or 72 (ARCANE + NATURE)
	[SCHOOL_MASK_SPELLFROST]  = { r = 0.75, g = 0.75, b = 1.00 }, -- 0x50 or 80 (ARCANE + FROST)
	[SCHOOL_MASK_SPELLSHADOW] = { r = 0.75, g = 0.50, b = 1.00 }, -- 0x60 or 96 (ARCANE + SHADOW)
	[SCHOOL_MASK_COSMIC]      = { r = 0.83, g = 0.67, b = 0.83 }, -- 0x6A or 106 (HOLY + SHADOW + ARCANE)
	[SCHOOL_MASK_CHAOS]       = { r = 0.65, g = 0.70, b = 0.65 }, -- 0x7C or 124 (FIRE + NATURE + FROST + SHADOW + ARCANE)
	[SCHOOL_MASK_MAGICAL]     = { r = 0.71, g = 0.75, b = 0.63 }, -- 0x7E or 126 (HOLY + FIRE + NATURE + FROST + SHADOW + ARCANE)
	[SCHOOL_MASK_ALL]         = { r = 1.00, g = 1.00, b = 1.00 }, -- 0x7F or 127 (ALL)
}

local eventFilter = {
	["SWING_DAMAGE"] = {suffix = "DAMAGE", index = 10, iconType = "swing", autoAttack = true},
	["RANGE_DAMAGE"] = {suffix = "DAMAGE", index = 13, iconType = "range", autoAttack = true},
	["SPELL_DAMAGE"] = {suffix = "DAMAGE", index = 13, iconType = "spell"},
	["SPELL_PERIODIC_DAMAGE"] = {suffix = "DAMAGE", index = 13, iconType = "spell", isPeriod = true},
	["SPELL_BUILDING_DAMAGE"] = {suffix = "DAMAGE", index = 13, iconType = "spell"},

	["SPELL_HEAL"] = {suffix = "HEAL", index = 13, iconType = "spell"},
	["SPELL_PERIODIC_HEAL"] = {suffix = "HEAL", index = 13, iconType = "spell", isPeriod = true},
	["SPELL_BUILDING_HEAL"] = {suffix = "HEAL", index = 13, iconType = "spell"},

	["SWING_MISSED"] = {suffix = "MISS", index = 10, iconType = "swing", autoAttack = true},
	["RANGE_MISSED"] = {suffix = "MISS", index = 13, iconType = "range", autoAttack = true},
	["SPELL_MISSED"] = {suffix = "MISS", index = 13, iconType = "spell"},
	["SPELL_PERIODIC_MISSED"] = {suffix = "MISS", index = 13, iconType = "spell", isPeriod = true},

	["ENVIRONMENTAL_DAMAGE"] = {suffix = "ENVIRONMENT", index = 10, iconType = "env"},
}

local envTexture = {
	["Drowning"] = "spell_shadow_demonbreath",
	["Falling"] = "ability_rogue_quickrecovery",
	["Fatigue"] = "ability_creature_cursed_04",
	["Fire"] = "spell_fire_fire",
	["Lava"] = "spell_fire_incinerate",
	["Slime"] = "ability_creature_poison_02",
}

local iconCache = {}
local function getSpellIcon(spellID)
	if spellID and not iconCache[spellID] then
		local texture = C_Spell.GetSpellTexture(spellID)
		iconCache[spellID] = texture
	end
	return iconCache[spellID]
end

local missCache = {}
local function getMissText(missType)
	if missType and not missCache[missType] then
		missCache[missType] = _G["COMBAT_TEXT_"..missType]
	end
	return missCache[missType]
end

local function getCombatTexture(iconType, spellID, isPet)
	local texture
	if iconType == "spell" then
		texture = getSpellIcon(spellID)
	elseif iconType == "swing" then
		if isPet then
			texture = 132152
		else
			texture = 132147
		end
	elseif iconType == "range" then
		texture = 132369
	elseif iconType == "env" then
		texture = "Interface\\Icons\\"..(envTexture[spellID] or "trade_engineering")
	end

	return texture
end

local playerGUID = UnitGUID("player")
local function Update(self, event, ...)
	local element = self.FloatingCombatFeedback
	local unit = self.unit

	local unitGUID = UnitGUID(unit)
	if unitGUID ~= element.unitGUID then
		element.unitGUID = unitGUID
	end

	local text, color, texture, critMark

	if eventFilter[event] then
		local _, sourceGUID, _, sourceFlags, _, destGUID, _, _, _, spellID, _, school = ...
		local isPlayer = playerGUID == sourceGUID
		local isRightUnit = element.unitGUID == destGUID
		local isPet = C.db["UFs"]["PetCombatText"] and DB:IsMyPet(sourceFlags)

		if isRightUnit and (unit == "target" and (isPlayer or isPet) or unit == "player") then
			local value = eventFilter[event]
			if not value then return end

			if value.suffix == "DAMAGE" then
				local amount, _, _, _, _, _, critical, _, crushing = select(value.index, ...)
				texture = getCombatTexture(value.iconType, spellID, (isPet and not isPlayer))
				text = "-"..B.Numb(amount)

				if critical or crushing then
					critMark = true
				end
			elseif value.suffix == "HEAL" then
				local amount, overhealing, _, critical = select(value.index, ...)
				texture = getCombatTexture(value.iconType, spellID)

				local overhealText = ""
				if overhealing > 0 then
					amount = amount - overhealing
					overhealText = " ("..B.Numb(overhealing)..")"
				end

				if amount == 0 then return end
				text = "+"..B.Numb(amount)..overhealText

				if critical then
					critMark = true
				end
			elseif value.suffix == "MISS" then
				local missType = select(value.index, ...)
				texture = getCombatTexture(value.iconType, spellID, isPet)
				text = getMissText(missType)
			elseif value.suffix == "ENVIRONMENT" then
				local envType, amount = select(value.index, ...)
				texture = getCombatTexture(value.iconType, envType)
				text = "-"..B.Numb(amount)
			end

			color = schoolColors[school] or schoolColors[0]
		end
	elseif event == "PLAYER_REGEN_DISABLED" then
		texture = ""
		text = ENTERING_COMBAT
		color = eventColors.COMBAT_IN
		critMark = true
	elseif event == "PLAYER_REGEN_ENABLED" then
		texture = ""
		text = LEAVING_COMBAT
		color = eventColors.COMBAT_OUT
		critMark = true
	end

	if text and texture then
		element.Scrolling:AddMessage(format("|T%s:12:18:-2:-4:64:64:5:59:16:48|t%s", texture, B.HexRGB(color)..text..(critMark and "*" or "").."|r"))
	end
end

local function Path(self, ...)
	return (self.FloatingCombatFeedback.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, "ForceUpdate", element.__owner.unit)
end

local function Enable(self, unit)
	local element = self.FloatingCombatFeedback
	if not element then return end

	element.__owner = self
	element.ForceUpdate = ForceUpdate

	for event in pairs(eventFilter) do
		self:RegisterCombatEvent(event, Path)
	end

	if unit == "player" then
		self:RegisterEvent("PLAYER_REGEN_DISABLED", Path, true)
		self:RegisterEvent("PLAYER_REGEN_ENABLED", Path, true)
	end

	return true
end

local function Disable(self)
	local element = self.FloatingCombatFeedback

	if element then
		for event in pairs(eventFilter) do
			self:UnregisterCombatEvent(event, Path)
		end

		self:UnregisterEvent("PLAYER_REGEN_DISABLED", Path)
		self:UnregisterEvent("PLAYER_REGEN_ENABLED", Path)
	end
end

oUF:AddElement("FloatingCombatFeedback", Path, Enable, Disable)