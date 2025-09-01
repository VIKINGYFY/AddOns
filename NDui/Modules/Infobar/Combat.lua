local _, ns = ...
local B, C, L, DB = unpack(ns)
if not C.Infobar.Combat then return end

local module = B:GetModule("Infobar")
local info = module:RegisterInfobar("Combat", C.Infobar.CombatPos)

local combatStart, lastCombatDuration = 0, 0
local lastCombatZone, lastCombatInst = UNKNOWN

local function GetZoneInfo()
	local mainZone, subZone = GetAreaText(), GetMinimapZoneText()
	local fullZone = (mainZone ~= subZone) and (mainZone.." - "..subZone) or subZone

	local instanceName, instanceType, difficultyID, difficultyName = GetInstanceInfo()
	if difficultyID == 8 then
		local activeLevel = C_ChallengeMode.GetActiveKeystoneInfo()
		difficultyName = difficultyName.." - "..activeLevel
	end
	local fullInst = instanceType ~= "none" and format("%s <%s>", instanceName, difficultyName) or nil

	return fullZone, fullInst
end

local function UpdateCombatTimer(self, elapsed)
	self.timer = (self.timer or 0) + elapsed
	if self.timer >= 1 then
		local duration = GetTime() - combatStart
		local durationTime = SecondsToClock(duration)
		local r, g, b = B.SmoothColor(duration, 300)
		local combatTime = B.HexRGB(r, g, b, durationTime)
		self.text:SetFormattedText("|cffFF0000%s|r<%s>", ENTERING_COMBAT, combatTime)

		self.timer = 0
	end
end

info.eventList = {
	"PLAYER_REGEN_DISABLED", -- 进入战斗
	"PLAYER_REGEN_ENABLED",  -- 脱离战斗
}

info.onEvent = function(self, event)
	if event == "PLAYER_REGEN_DISABLED" then
		combatStart = GetTime()
		lastCombatZone, lastCombatInst = GetZoneInfo()
		self:SetScript("OnUpdate", UpdateCombatTimer)
	else
		lastCombatDuration = combatStart > 0 and (GetTime() - combatStart) or 0

		local lastCombatTime = lastCombatDuration > 0 and SecondsToTime(lastCombatDuration, false, true, 3) or UNKNOWN
		self.text:SetFormattedText("|cff00FF00%s|r<%s>", LEAVING_COMBAT, lastCombatTime)
		self:SetScript("OnUpdate", nil)
	end
end

info.onEnter = function(self)
	local _, anchor, offset = module:GetTooltipAnchor(info)
	GameTooltip:SetOwner(self, "ANCHOR_"..anchor, 0, offset)
	GameTooltip:ClearLines()
	GameTooltip:AddLine("战斗时长", 0,1,1)
	GameTooltip:AddLine(" ")
	if lastCombatDuration > 0 then
		GameTooltip:AddDoubleLine("时长:", SecondsToTime(lastCombatDuration, false, true, 3), 0,1,1, 1,1,1)
		GameTooltip:AddDoubleLine("地区:", lastCombatZone, 0,1,1, 1,1,1)
		if lastCombatInst then
			GameTooltip:AddDoubleLine("副本:", lastCombatInst, 0,1,1, 1,1,1)
		end
	else
		GameTooltip:AddLine("暂无战斗记录", 1,1,1)
	end
	GameTooltip:Show()
end

info.onLeave = function()
	GameTooltip:Hide()
end
