local _, ns = ...
local B, C, L, DB = unpack(ns)

local function GetCurrentSpeed()
	local isGliding, canGlide, forwardSpeed = C_PlayerInfo.GetGlidingInfo()
	local isFlying, isSwimming, isOnTaxi = IsFlying("player"), IsSwimming("player"), UnitOnTaxi("player")
	local currentSpeed, runSpeed, flightSpeed, swimSpeed = GetUnitSpeed("player")
	local speedBase = (isGliding and forwardSpeed) or (isFlying and flightSpeed) or (isSwimming and swimSpeed) or (isOnTaxi and currentSpeed) or runSpeed
	--local speedBase = (isGliding and forwardSpeed) or currentSpeed

	return speedBase / 7 * 100
end

local function GetVersatility()
	return GetCombatRatingBonus(29)
end

local function GetPrimaryStat()
	return UnitStat("player", DB.mainID)
end

local barWidth, barHeight = 150, 10
local barData = {
	{label = DB.mainStat, limit = 150000, hide = 0, numb = true, func = GetPrimaryStat},
	{label = "爆击", limit = 100, hide = 0, func = GetSpellCritChance},
	{label = "急速", limit = 100, hide = 0, func = GetHaste},
	{label = "精通", limit = 100, hide = 0, func = GetMasteryEffect},
	{label = "全能", limit = 100, hide = 0, func = GetVersatility},
	{label = "移速", limit = 500, hide = 0, func = GetCurrentSpeed},
	{label = "躲闪", limit = 100, hide = 0, role = "Tank", func = GetDodgeChance},
	{label = "招架", limit = 100, hide = 0, role = "Tank", func = GetParryChance},
	{label = "格挡", limit = 100, hide = 0, role = "Tank", func = GetBlockChance},
}

local StatsMonitor = CreateFrame("Frame", "StatsMonitor", UIParent, "BackdropTemplate")
StatsMonitor:SetSize(barWidth, barHeight)
StatsMonitor:RegisterEvent("PLAYER_LOGIN")
StatsMonitor:RegisterEvent("PLAYER_ENTERING_WORLD")
StatsMonitor:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
StatsMonitor:RegisterEvent("PLAYER_TALENT_UPDATE")
StatsMonitor:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
StatsMonitor:RegisterUnitEvent("UNIT_AURA", "player", "target")

StatsMonitor:SetScript("OnEvent", function(self, event, ...)
	self[event](self, event, ...)
end)

function StatsMonitor:UpdateValues()
	if not self.bars then return end

	for _, bar in ipairs(self.bars) do
		local stat = bar.func()
		if not stat then return end

		bar.stat = stat

		local r, g, b = B.SmoothColor(stat, bar.limit)
		bar:SetValue(stat)
		bar:SetStatusBarColor(r, g, b)
		bar.value:SetText(bar.numb and B.Numb(stat) or B.Perc(stat))
		--bar.title:SetTextColor(r, g, b)
		--bar.value:SetTextColor(r, g, b)
	end
end

function StatsMonitor:UpdateLayout()
	if not self.bars then return end

	self.bars[1].title:SetText(DB.mainStat)

	local showCount = 0
	for _, bar in ipairs(self.bars) do
		local shouldHide

		if bar.role and bar.role ~= DB.Role then
			shouldHide = true
		end

		if not shouldHide and (not bar.stat or bar.stat <= bar.hide) then
			shouldHide = true
		end

		if shouldHide then
			bar:Hide()
		else
			bar:Show()
			showCount = showCount + 1
		end

		bar:ClearAllPoints()
		bar:SetPoint("TOP", self, "TOP", 0, -barHeight - (showCount - 1) * (barHeight * 2))
	end

	self:SetSize(barWidth, showCount * (barHeight * 2))
	self:ClearAllPoints()
	self:SetPoint("BOTTOM", self.mover, "BOTTOM")
end

function StatsMonitor:PLAYER_LOGIN()
	self.mover = B.Mover(self, "属性监控", "StatsMonitor", {"BOTTOMRIGHT", UIParent, "BOTTOM", -300, 80}, barWidth, barHeight*2)

	self.bars = {}
	for i, v in ipairs(barData) do
		if self.bars[i] then return end

		local bar = B.CreateSB(self)
		bar:SetPoint("TOP", self, "TOP", 0, -barHeight - (i - 1) * (barHeight * 2))
		bar:SetMinMaxValues(0, v.limit)
		bar:SetSize(barWidth, barHeight)
		bar:SetValue(0)

		B.SmoothBar(bar)

		bar.title = B.CreateFS(bar, barHeight + 4, v.label, false, "LEFT", 2, barHeight / 2)
		bar.value = B.CreateFS(bar, barHeight + 4, "", false, "RIGHT", -2, barHeight / 2)

		for k, e in pairs(v) do bar[k] = e end

		self.bars[i] = bar
	end

	self:UpdateValues()
	self:UpdateLayout()
end

function StatsMonitor:PLAYER_ENTERING_WORLD()
	self:UpdateValues()
	self:UpdateLayout()
end

function StatsMonitor:PLAYER_EQUIPMENT_CHANGED()
	self:UpdateValues()
	self:UpdateLayout()
end

function StatsMonitor:PLAYER_TALENT_UPDATE()
	self:UpdateValues()
	self:UpdateLayout()
end

function StatsMonitor:UNIT_AURA()
	self:UpdateValues()
end

function StatsMonitor:ACTIONBAR_UPDATE_COOLDOWN()
	self:UpdateValues()
end
