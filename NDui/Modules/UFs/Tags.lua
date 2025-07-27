local _, ns = ...
local B, C, L, DB = unpack(ns)
local oUF = ns.oUF

local ALTERNATE_POWER_INDEX = Enum.PowerType.Alternate or 10
-- Add scantip back, due to issue on ColorMixin
local scanTip = CreateFrame("GameTooltip", "NDui_ScanTooltip", nil, "GameTooltipTemplate")

local HP_EVENTS = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION UNIT_FLAGS PARTY_MEMBER_ENABLE PARTY_MEMBER_DISABLE UNIT_ABSORB_AMOUNT_CHANGED UNIT_HEAL_ABSORB_AMOUNT_CHANGED"
local MP_EVENTS = "UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_DISPLAYPOWER"
local LV_EVENTS = "UNIT_LEVEL PLAYER_LEVEL_CHANGED UNIT_CLASSIFICATION_CHANGED"
local OT_EVENTS = "UNIT_NAME_UPDATE UNIT_CONNECTION UNIT_FLAGS UNIT_FACTION UNIT_CLASSIFICATION_CHANGED"

local function CurrentAndPercent(cur, per, noColor)
	if per < 100 then
		return B.Numb(cur)..DB.Separator..(noColor and B.Perc(per) or B.ColorPerc(per, true))
	else
		return B.Numb(cur)
	end
end

local function CurrentAndMaximum(cur, max, noColor)
	if cur < max then
		return (noColor and B.Numb(cur) or B.ColorNumb(cur, max, true))..DB.Separator..B.Numb(max)
	else
		return B.Numb(cur)
	end
end

oUF.Tags.Methods["VariousHP"] = function(unit, _, arg1)
	if not UnitIsConnected(unit) or UnitIsDeadOrGhost(unit) then
		return oUF.Tags.Methods["status"](unit)
	end

	if not arg1 then return end
	local cur, max = UnitHealth(unit), UnitHealthMax(unit)
	local per = (max == 0 and 0) or (cur/max * 100)
	local loss = (max == 0 and 0) or (cur - max)
	local lossper = (max == 0 and 0) or (loss/max * 100)
	local absorb = UnitGetTotalAbsorbs(unit) or 0

	if arg1 == "currentpercent" then
		return CurrentAndPercent(cur, per)
	elseif arg1 == "currentmaximum" then
		return CurrentAndMaximum(cur, max)
	elseif arg1 == "current" then
		return B.ColorNumb(cur, max, true)
	elseif arg1 == "percent" then
		return B.ColorPerc(per, true)
	elseif arg1 == "loss" then
		return B.ColorNumb(loss, max)
	elseif arg1 == "losspercent" then
		return B.ColorPerc(lossper)
	elseif arg1 == "absorb" then
		return DB.InfoColor..B.Numb(cur + absorb).."|r"
	end
end
oUF.Tags.Events["VariousHP"] = HP_EVENTS

oUF.Tags.Methods["VariousMP"] = function(unit, _, arg1)
	if not arg1 then return end
	local cur, max = UnitPower(unit), UnitPowerMax(unit)
	local per = (max == 0 and 0) or (cur/max * 100)
	local loss = (max == 0 and 0) or (cur - max)
	local lossper = (max == 0 and 0) or (loss/max * 100)

	if arg1 == "currentpercent" then
		return CurrentAndPercent(cur, per, true)
	elseif arg1 == "currentmaximum" then
		return CurrentAndMaximum(cur, max, true)
	elseif arg1 == "current" then
		return B.Numb(cur)
	elseif arg1 == "percent" then
		return B.Perc(per)
	elseif arg1 == "loss" then
		return B.Numb(loss)
	elseif arg1 == "losspercent" then
		return B.Perc(lossper)
	end
end
oUF.Tags.Events["VariousMP"] = MP_EVENTS

oUF.Tags.Methods["color"] = function(unit)
	local class = select(2, UnitClass(unit))
	local reaction = UnitReaction(unit, "player")

	if UnitIsTapDenied(unit) then
		return B.HexRGB(oUF.colors.tapped)
	elseif UnitIsPlayer(unit) or UnitInPartyIsAI(unit) then
		return B.HexRGB(oUF.colors.class[class])
	elseif reaction then
		return B.HexRGB(oUF.colors.reaction[reaction])
	end
end
oUF.Tags.Events["color"] = OT_EVENTS

oUF.Tags.Methods["flags"] = function(unit)
	if UnitIsAFK(unit) then
		return "|cffCCCCCC <"..AFK..">|r"
	elseif UnitIsDND(unit) then
		return "|cffCCCCCC <"..DND..">|r"
	end
end
oUF.Tags.Events["flags"] = "UNIT_FLAGS PLAYER_FLAGS_CHANGED"

oUF.Tags.Methods["status"] = function(unit)
	if not UnitIsConnected(unit) then
		return "|cffCCCCCC"..PLAYER_OFFLINE.."|r"
	elseif UnitIsDeadOrGhost(unit) then
		return "|cffCCCCCC"..DEAD.."|r"
	elseif GetNumArenaOpponentSpecs() == 0 then
		return "|cffCCCCCC"..UNKNOWN.."|r"
	end
end
oUF.Tags.Events["status"] = OT_EVENTS

-- Level tags
oUF.Tags.Methods["fulllevel"] = function(unit)
	local realLevel = UnitLevel(unit)
	local level = UnitEffectiveLevel(unit)
	if UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit) then
		level = UnitBattlePetLevel(unit)
		realLevel = level
	end

	local color = B.HexRGB(GetCreatureDifficultyColor(level))
	local str
	if level > 0 then
		local realTag = (level ~= realLevel and "*") or ""
		str = color..level..realTag.."|r"
	else
		str = "|cffFF0000??|r"
	end

	local class = UnitClassification(unit)
	if class == "worldboss" then
		str = " |cffFF0000B|r"
	elseif class == "rareelite" then
		str = str.." |cffFF00FFRE|r"
	elseif class == "elite" then
		str = str.." |cffFFFF00E|r"
	elseif class == "rare" then
		str = str.." |cff00FFFFR|r"
	end

	return str
end
oUF.Tags.Events["fulllevel"] = LV_EVENTS

-- RaidFrame tags
local healthModeType = {
	[1] = "",
	[2] = "percent",
	[3] = "current",
	[4] = "loss",
	[5] = "losspercent",
	[6] = "absorb",
}
oUF.Tags.Methods["raidhp"] = function(unit)
	local healthType = healthModeType[C.db["UFs"]["RaidHPMode"]]
	return oUF.Tags.Methods["VariousHP"](unit, _, healthType)
end
oUF.Tags.Events["raidhp"] = HP_EVENTS

-- Nameplate tags
oUF.Tags.Methods["nppower"] = function(unit)
	local cur, max = UnitPower(unit), UnitPowerMax(unit)
	local per = (max == 0 and 0) or (cur/max * 100)

	return B.ColorPerc(per)
end
oUF.Tags.Events["nppower"] = MP_EVENTS

oUF.Tags.Methods["nplevel"] = function(unit)
	local level = UnitLevel(unit)
	local color = B.HexRGB(GetCreatureDifficultyColor(level))
	if level and level ~= UnitLevel("player") then
		if level > 0 then
			level = color..level.."|r "
		else
			level = "|cffFF0000??|r "
		end
	else
		level = ""
	end

	return level
end
oUF.Tags.Events["nplevel"] = LV_EVENTS

local NPClassifies = {
	rare = "  ",
	elite = "  ",
	rareelite = "  ",
	worldboss = "  ",
}
oUF.Tags.Methods["nprare"] = function(unit)
	local class = UnitClassification(unit)
	return class and NPClassifies[class]
end
oUF.Tags.Events["nprare"] = "UNIT_CLASSIFICATION_CHANGED"

oUF.Tags.Methods["pppower"] = function(unit)
	local cur, max = UnitPower(unit), UnitPowerMax(unit)

	return DB.MyColor..B.Numb(cur).."|r"
end
oUF.Tags.Events["pppower"] = MP_EVENTS

oUF.Tags.Methods["npctitle"] = function(unit)
	local isPlayer = UnitIsPlayer(unit)
	if isPlayer and C.db["Nameplate"]["NameOnlyGuild"] then
		local guildName = GetGuildInfo(unit)
		if guildName then
			return "<"..guildName..">"
		end
	elseif not isPlayer and C.db["Nameplate"]["NameOnlyTitle"] then
		scanTip:SetOwner(UIParent, "ANCHOR_NONE")
		scanTip:SetUnit(unit)

		local textLine = _G[format("NDui_ScanTooltipTextLeft%d", GetCVarBool("colorblindmode") and 3 or 2)]
		local title = textLine and textLine:GetText()
		if title and not string.find(title, "^"..LEVEL) then
			return title
		end
--[[
		local data = C_TooltipInfo.GetUnit(unit) -- FIXME: ColorMixin error
		if not data then return "" end

		local lineData = data.lines[GetCVarBool("colorblindmode") and 3 or 2]
		if lineData then
			local title = lineData.leftText
			if title and not string.find(title, "^"..LEVEL) then
				return title
			end
		end
]]
	end
end
oUF.Tags.Events["npctitle"] = "UNIT_NAME_UPDATE"

oUF.Tags.Methods["targetname"] = function(unit)
	local tarUnit = unit.."target"
	if UnitExists(tarUnit) then
		local tarClass = select(2, UnitClass(tarUnit))
		local tarName = UnitName(tarUnit)

		return B.HexRGB(oUF.colors.class[tarClass])..tarName
	end
end
oUF.Tags.Events["targetname"] = "UNIT_AURA UNIT_NAME_UPDATE UNIT_THREAT_LIST_UPDATE UNIT_THREAT_SITUATION_UPDATE UNIT_TARGET UNIT_TARGETABLE_CHANGED"

-- AltPower value tag
oUF.Tags.Methods["altpower"] = function(unit)
	local cur, max = UnitPower(unit, ALTERNATE_POWER_INDEX), UnitPowerMax(unit, ALTERNATE_POWER_INDEX)

	return cur > 0 and B.ColorNumb(cur, max, true)
end
oUF.Tags.Events["altpower"] = MP_EVENTS

-- Monk stagger
oUF.Tags.Methods["stagger"] = function(unit)
	if unit ~= "player" then return end
	local cur, max = UnitStagger(unit), UnitHealthMax(unit)
	local per = (max == 0 and 0) or (cur/max * 100)

	return B.ColorNumb(cur, max)..DB.Separator..B.ColorPerc(per)
end
oUF.Tags.Events["stagger"] = "UNIT_MAXHEALTH UNIT_AURA"