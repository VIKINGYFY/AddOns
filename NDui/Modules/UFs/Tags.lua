local _, ns = ...
local B, C, L, DB = unpack(ns)
local oUF = ns.oUF

local ALTERNATE_POWER_INDEX = Enum.PowerType.Alternate or 10
-- Add scantip back, due to issue on ColorMixin
local scanTip = CreateFrame("GameTooltip", "NDui_ScanTooltip", nil, "GameTooltipTemplate")


local function CurrentAndPercent(cur, per)
	if per < 100 then
		return B.Numb(cur)..DB.Separator..B.Perc(per)
	else
		return B.Numb(cur)
	end
end

local function CurrentAndMax(cur, max)
	if cur < max then
		return B.Numb(cur)..DB.Separator..B.Numb(max)
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
	local per = max == 0 and 0 or (cur/max * 100)
	local loss = max == 0 and 0 or (max - cur)
	local lossper = max == 0 and 0 or (loss/max * 100)

	if arg1 == "currentpercent" then
		return CurrentAndPercent(cur, per)
	elseif arg1 == "currentmax" then
		return CurrentAndMax(cur, max)
	elseif arg1 == "current" then
		return B.Numb(cur)
	elseif arg1 == "percent" then
		return per < 100 and B.Perc(per, true)
	elseif arg1 == "loss" then
		return loss ~= 0 and B.Numb(loss)
	elseif arg1 == "losspercent" then
		return loss ~= 0 and B.Perc(lossper)
	end
end
oUF.Tags.Events["VariousHP"] = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED PARTY_MEMBER_ENABLE PARTY_MEMBER_DISABLE"

oUF.Tags.Methods["VariousMP"] = function(unit, _, arg1)
	local cur, max = UnitPower(unit), UnitPowerMax(unit)
	local per = max == 0 and 0 or (cur/max * 100)
	local loss = max == 0 and 0 or (max - cur)
	local lossper = max == 0 and 0 or (loss/max * 100)

	if arg1 == "currentpercent" then
		return CurrentAndPercent(cur, per)
	elseif arg1 == "currentmax" then
		return CurrentAndMax(cur, max)
	elseif arg1 == "current" then
		return B.Numb(cur)
	elseif arg1 == "percent" then
		return per < 100 and B.Perc(per, true)
	elseif arg1 == "loss" then
		return loss ~= 0 and B.Numb(loss)
	elseif arg1 == "losspercent" then
		return loss ~= 0 and B.Perc(lossper)
	end
end
oUF.Tags.Events["VariousMP"] = "UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_DISPLAYPOWER"

oUF.Tags.Methods["curAbsorb"] = function(unit)
	local value = UnitGetTotalAbsorbs(unit)
	return value > 0 and DB.InfoColor..B.Numb(value).." |r"
end
oUF.Tags.Events["curAbsorb"] = "UNIT_ABSORB_AMOUNT_CHANGED UNIT_HEAL_ABSORB_AMOUNT_CHANGED"

oUF.Tags.Methods["color"] = function(unit)
	local class = select(2, UnitClass(unit))
	local reaction = UnitReaction(unit, "player")

	if UnitIsTapDenied(unit) then
		return B.HexRGB(oUF.colors.tapped)
	elseif UnitIsPlayer(unit) or UnitInPartyIsAI(unit) then
		return B.HexRGB(oUF.colors.class[class])
	elseif reaction then
		return B.HexRGB(oUF.colors.reaction[reaction])
	else
		return B.HexRGB(1, 1, 1)
	end
end
oUF.Tags.Events["color"] = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_NAME_UPDATE UNIT_FACTION UNIT_CONNECTION PLAYER_FLAGS_CHANGED"

oUF.Tags.Methods["flags"] = function(unit)
	if UnitIsAFK(unit) then
		return "|cffCCCCCC <"..AFK..">|r"
	elseif UnitIsDND(unit) then
		return "|cffCCCCCC <"..DND..">|r"
	else
		return ""
	end
end
oUF.Tags.Events["flags"] = "PLAYER_FLAGS_CHANGED"

oUF.Tags.Methods["status"] = function(unit)
	if not UnitIsConnected(unit) then
		return "|cffCCCCCC"..PLAYER_OFFLINE.."|r"
	elseif UnitIsDead(unit) then
		return "|cffCCCCCC"..DEAD.."|r"
	elseif UnitIsGhost(unit) then
		return "|cffCCCCCC"..L["Ghost"].."|r"
	elseif GetNumArenaOpponentSpecs() == 0 then
		return "|cffCCCCCC"..UNKNOWN.."|r"
	end
end
oUF.Tags.Events["status"] = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_NAME_UPDATE UNIT_CONNECTION PLAYER_FLAGS_CHANGED"

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
		local realTag = level ~= realLevel and "*" or ""
		str = color..level..realTag.."|r"
	else
		str = "|cffFF0000??|r"
	end

	local class = UnitClassification(unit)
	if class == "worldboss" then
		str = " |cffFF0000B|r"
	elseif class == "rareelite" then
		str = str.." |cff00FFFFRE|r"
	elseif class == "elite" then
		str = str.." |cffFFFF00E|r"
	elseif class == "rare" then
		str = str.." |cff00FF00R|r"
	end

	return str
end
oUF.Tags.Events["fulllevel"] = "UNIT_LEVEL PLAYER_LEVEL_UP UNIT_CLASSIFICATION_CHANGED"

-- RaidFrame tags
local healthModeType = {
	[2] = "percent",
	[3] = "current",
	[4] = "loss",
	[5] = "losspercent",
}
oUF.Tags.Methods["raidhp"] = function(unit)
	local healthType = healthModeType[C.db["UFs"]["RaidHPMode"]]
	return oUF.Tags.Methods["VariousHP"](unit, _, healthType)
end
oUF.Tags.Events["raidhp"] = oUF.Tags.Events["VariousHP"]

-- Nameplate tags
oUF.Tags.Methods["nppp"] = function(unit)
	local per = oUF.Tags.Methods["perpp"](unit)
	return B.Perc(per)
end
oUF.Tags.Events["nppp"] = "UNIT_POWER_FREQUENT UNIT_MAXPOWER"

oUF.Tags.Methods["nplevel"] = function(unit)
	local level = UnitLevel(unit)
	if level and level ~= UnitLevel("player") then
		if level > 0 then
			level = B.HexRGB(GetCreatureDifficultyColor(level))..level.."|r "
		else
			level = "|cffFF0000??|r "
		end
	else
		level = ""
	end

	return level
end
oUF.Tags.Events["nplevel"] = "UNIT_LEVEL PLAYER_LEVEL_UP"

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
	local cur = UnitPower(unit)
	local per = oUF.Tags.Methods["perpp"](unit) or 0
	if UnitPowerType(unit) == 0 then
		return per
	else
		return cur
	end
end
oUF.Tags.Events["pppower"] = "UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_DISPLAYPOWER"

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
		local data = not DB.isWW and C_TooltipInfo.GetUnit(unit) -- FIXME: ColorMixin error
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

oUF.Tags.Methods["tarname"] = function(unit)
	local tarUnit = unit.."target"
	if UnitExists(tarUnit) then
		local tarClass = select(2, UnitClass(tarUnit))
		return B.HexRGB(oUF.colors.class[tarClass])..UnitName(tarUnit)
	end
end
oUF.Tags.Events["tarname"] = "UNIT_NAME_UPDATE UNIT_THREAT_SITUATION_UPDATE UNIT_HEALTH"

-- AltPower value tag
oUF.Tags.Methods["altpower"] = function(unit)
	local cur = UnitPower(unit, ALTERNATE_POWER_INDEX)

	return cur > 0 and cur
end
oUF.Tags.Events["altpower"] = "UNIT_POWER_UPDATE UNIT_MAXPOWER"

-- Monk stagger
oUF.Tags.Methods["monkstagger"] = function(unit)
	if unit ~= "player" then return end
	local cur = UnitStagger(unit) or 0
	local max = UnitHealthMax(unit) or 0
	if (cur == 0) or (max == 0) then return end

	return B.Numb(cur)..DB.Separator..B.Perc(cur/max * 100)
end
oUF.Tags.Events["monkstagger"] = "UNIT_MAXHEALTH UNIT_AURA"