local _, ns = ...
local B, C, L, DB = unpack(ns)
if not C.Infobar.Combat then return end

local module = B:GetModule("Infobar")
local info = module:RegisterInfobar("Combat", C.Infobar.CombatPos)

-- 变量
local combatStart, lastCombatDuration, lastCombatTime = 0, 0, 0
local loadStart, lastLoadDuration, lastLoadTime = 0, 0, 0

-- 获取地区信息
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

-- 显示逻辑
local function ShowCombat(self)
	lastCombatDuration = combatStart > 0 and (GetTime() - combatStart) or 0
	lastCombatTime = lastCombatDuration > 0 and SecondsToTime(lastCombatDuration, false, true, 3) or UNKNOWN
	self.text:SetFormattedText("|cff00FF00%s|r<%s>", LEAVING_COMBAT, lastCombatTime)
end

local function ShowLoading(self)
	lastLoadDuration = loadStart > 0 and (GetTime() - loadStart) or 0
	lastLoadTime = lastLoadDuration > 0 and SecondsToTime(lastLoadDuration, false, true, 2) or UNKNOWN
	self.text:SetFormattedText("|cff00FFFF%s|r<%s>", "过图时长", lastLoadTime)
end

local function ShowUnknown(self)
	self.text:SetFormattedText("|cffFFFF00%s|r<%s>", UNKNOWN, UNKNOWN)
end

-- 战斗中更新计时器
local function UpdateCombatTimer(self, elapsed)
	self.timer = (self.timer or 0) + elapsed
	if self.timer >= 1 then
		local duration = GetTime() - combatStart
		local durationTime = SecondsToClock(duration)
		local r, g, b = B.SmoothColor(duration, 600)
		local combatTime = B.HexRGB(r, g, b, "<"..durationTime..">")
		self.text:SetFormattedText("|cffFF0000%s|r%s", ENTERING_COMBAT, combatTime)

		self.timer = 0
	end
end

-- 事件列表
info.eventList = {
	"PLAYER_REGEN_DISABLED",   -- 进入战斗
	"PLAYER_REGEN_ENABLED",    -- 脱离战斗
	"LOADING_SCREEN_ENABLED",  -- 过图开始
	"LOADING_SCREEN_DISABLED", -- 过图结束
}

-- 事件处理
info.onEvent = function(self, event)
	if event == "PLAYER_REGEN_DISABLED" then
		-- 进入战斗
		combatStart = GetTime()
		self:SetScript("OnUpdate", UpdateCombatTimer)
	elseif event == "PLAYER_REGEN_ENABLED" then
		-- 脱离战斗
		ShowCombat(self)
		self:SetScript("OnUpdate", nil)
	elseif event == "LOADING_SCREEN_ENABLED" then
		-- 过图开始
		loadStart = GetTime()
	elseif event == "LOADING_SCREEN_DISABLED" then
		-- 过图完成
		ShowLoading(self)
	else
		-- 切换地图/副本
		if not InCombatLockdown() then
			self:SetScript("OnUpdate", nil)
			if lastCombatDuration > 0 then
				ShowCombat(self)
			elseif lastLoadDuration > 0 then
				ShowLoading(self)
			else
				ShowUnknown(self)
			end
		end
	end
end

-- 鼠标提示
info.onEnter = function(self)
	local _, anchor, offset = module:GetTooltipAnchor(info)
	GameTooltip:SetOwner(self, "ANCHOR_"..anchor, 0, offset)
	GameTooltip:ClearLines()

	GameTooltip:AddDoubleLine("战斗时长:", lastCombatTime, 0,1,1, 1,1,1)
	GameTooltip:AddDoubleLine("过图时长:", lastLoadTime, 0,1,1, 1,1,1)

	GameTooltip:Show()
end

info.onLeave = function()
	GameTooltip:Hide()
end
