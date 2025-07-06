local _, ns = ...
local B, C, L, DB = unpack(ns)

local barWidth, barHeight = 150, 10
local barData = {
	{label = DB.mainStat, limit = 100000},
	{label = "爆击", limit = 100},
	{label = "急速", limit = 100},
	{label = "精通", limit = 100},
	{label = "全能", limit = 100},
	{label = "移速", limit = 500},
	{label = "躲闪", limit = 100, role = "Tank"},
	{label = "招架", limit = 100, role = "Tank"},
	{label = "格挡", limit = 100, hide = 0},
}

local StatsMonitor = CreateFrame("Frame", "StatsMonitor", UIParent, "BackdropTemplate")
StatsMonitor:SetSize(barWidth, barHeight)
StatsMonitor:RegisterEvent("PLAYER_LOGIN")
StatsMonitor:RegisterEvent("PLAYER_ENTERING_WORLD")
StatsMonitor:RegisterEvent("PLAYER_TALENT_UPDATE")
StatsMonitor:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
StatsMonitor:RegisterUnitEvent("UNIT_AURA", "player", "target")

StatsMonitor:SetScript("OnEvent", function(self, event, ...)
	self[event](self, event, ...)
end)

local function GetCurrentSpeed()
	local isGliding, canGlide, forwardSpeed = C_PlayerInfo.GetGlidingInfo()
	local isFlying, isSwimming, isOnTaxi = IsFlying("player"), IsSwimming("player"), UnitOnTaxi("player")
	local currentSpeed, runSpeed, flightSpeed, swimSpeed = GetUnitSpeed("player")
	local speedBase = (isGliding and forwardSpeed) or (isFlying and flightSpeed) or (isSwimming and swimSpeed) or (isOnTaxi and currentSpeed) or runSpeed
	--local speedBase = (isGliding and forwardSpeed) or currentSpeed

	return speedBase / 7 * 100
end

local function SetupValue(bar, stat, isNumb)
	if not bar then return end

	local r, g, b = B.Color(stat, bar.limit)

	bar:SetValue(stat)
	bar:SetStatusBarColor(r, g, b)
	bar.value:SetText(isNumb and B.Numb(stat) or B.Perc(stat))
	--bar.title:SetTextColor(r, g, b)
	--bar.value:SetTextColor(r, g, b)
end

function StatsMonitor:UpdateSelf()
	if not self.bars then return end

	self.bars[1].title:SetText(DB.mainStat)

	local hideCount = 0
	for _, bar in ipairs(self.bars) do
		if (bar.role and bar.role ~= DB.Role) or (bar.hide and bar.hide >= GetBlockChance()) then
			bar:Hide()
			hideCount = hideCount + 1
		else
			bar:Show()
		end
	end

	self:SetSize(barWidth, barHeight * (#self.bars - hideCount) * 2)
	self:ClearAllPoints()
	self:SetPoint("BOTTOM", self.mover, "BOTTOM")
end

function StatsMonitor:UpdateValue()
	if not self.bars then return end

	local main = UnitStat("player", DB.mainID)
	SetupValue(self.bars[1], main, true)

	local crit = GetSpellCritChance()
	SetupValue(self.bars[2], crit)

	local haste = GetHaste()
	SetupValue(self.bars[3], haste)

	local mastery = GetMasteryEffect()
	SetupValue(self.bars[4], mastery)

	local versatility = GetCombatRatingBonus(29)
	SetupValue(self.bars[5], versatility)

	local speed = GetCurrentSpeed()
	SetupValue(self.bars[6], speed)

	local dodge = GetDodgeChance()
	SetupValue(self.bars[7], dodge)

	local parry = GetParryChance()
	SetupValue(self.bars[8], parry)

	local block = GetBlockChance()
	SetupValue(self.bars[9], block)
end

function StatsMonitor:PLAYER_LOGIN()
	self.mover = B.Mover(self, "属性监控", "StatsMonitor", {"BOTTOMRIGHT", UIParent, "BOTTOM", -300, 80}, barWidth, barHeight*2)

	self.bars = {}
	for i, v in ipairs(barData) do
		local bar = B.CreateSB(self)
		bar:SetPoint("TOP", self, "TOP", 0, -barHeight - (i - 1) * (barHeight*2))
		bar:SetMinMaxValues(0, v.limit)
		bar:SetSize(barWidth, barHeight)
		bar:SetValue(0)

		B.SmoothBar(bar)

		bar.title = B.CreateFS(bar, barHeight+4, v.label, false, "LEFT", 2, barHeight/2)
		bar.value = B.CreateFS(bar, barHeight+4, "", false, "RIGHT", -2, barHeight/2)
		bar.limit = v.limit
		bar.role = v.role
		bar.hide = v.hide

		self.bars[i] = bar
	end

	self:UpdateSelf()
	self:UpdateValue()
end

function StatsMonitor:PLAYER_ENTERING_WORLD()
	self:UpdateSelf()
	self:UpdateValue()
end

function StatsMonitor:PLAYER_TALENT_UPDATE()
	self:UpdateSelf()
	self:UpdateValue()
end

function StatsMonitor:UNIT_AURA()
	self:UpdateValue()
end

function StatsMonitor:ACTIONBAR_UPDATE_COOLDOWN()
	self:UpdateValue()
end
