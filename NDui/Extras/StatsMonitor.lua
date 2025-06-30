local _, ns = ...
local B, C, L, DB = unpack(ns)
local cr, cg, cb = DB.r, DB.g, DB.b

local barWidth, barHeight = 150, 10
local barData = {
	{label = "主要", limit = 100000},
	{label = "爆击", limit = 100},
	{label = "急速", limit = 100},
	{label = "精通", limit = 100},
	{label = "全能", limit = 100},
	{label = "移速", limit = 600},
	{label = "闪避", limit = 100, role = "Tank"},
	{label = "招架", limit = 100, role = "Tank"},
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

local function SetupValue(bar, stat, isNumb)
	if not bar then return end

	local r, g, b = B.Color(stat, bar.limit, true)
	bar:SetValue(stat)
	bar:SetStatusBarColor(r, g, b)
	--bar:SetStatusBarColor(r, g, b)
	bar.value:SetText(isNumb and B.Numb(stat) or B.Perc(stat))
	--bar.title:SetTextColor(r, g, b)
	--bar.value:SetTextColor(r, g, b)
end

function StatsMonitor:UpdateBars()
	if not self.bars then return end

	self.bars[1].title:SetText(DB.mainStat)
	for _, bar in pairs(self.bars) do
		if bar.role then
			bar:SetShown(bar.role == DB.Role)
		end
	end
end

function StatsMonitor:UpdateValue()
	if not self.bars then return end

	local isGliding, canGlide, forwardSpeed = C_PlayerInfo.GetGlidingInfo()
	local isFlying, isSwimming = IsFlying("player"), IsSwimming("player")
	local currentSpeed, runSpeed, flightSpeed, swimSpeed = GetUnitSpeed("player")
	local speedBase = (isGliding and forwardSpeed) or (isFlying and flightSpeed) or (isSwimming and swimSpeed) or runSpeed

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

	local speed = speedBase / 7 * 100
	SetupValue(self.bars[6], speed)

	local dodge = GetDodgeChance()
	SetupValue(self.bars[7], dodge)

	local parry = GetParryChance()
	SetupValue(self.bars[8], parry)
end

function StatsMonitor:PLAYER_LOGIN()
	local mover = B.Mover(self, "属性监控", "StatsMonitor", {"BOTTOMRIGHT", UIParent, "BOTTOM", -300, 220}, barWidth, barHeight)
	self:ClearAllPoints()
	self:SetPoint("TOP", mover, "TOP")

	self.bars = {}

	for i, v in pairs(barData) do
		local bar = B.CreateSB(self)
		bar:SetPoint("TOP", self, "TOP", 0, -barHeight - (i - 1) * (barHeight*2))
		bar:SetMinMaxValues(0, v.limit)
		bar:SetSize(barWidth, barHeight)
		bar:SetValue(0)

		B.SmoothBar(bar)

		bar.title = B.CreateFS(bar, barHeight+4, v.label, false, "LEFT", 0, barHeight/2)
		bar.value = B.CreateFS(bar, barHeight+4, "", false, "RIGHT", 0, barHeight/2)
		bar.limit = v.limit
		bar.role = v.role

		self.bars[i] = bar
	end

	self:UpdateBars()
	self:UpdateValue()
end

function StatsMonitor:PLAYER_ENTERING_WORLD()
	self:UpdateBars()
	self:UpdateValue()
end

function StatsMonitor:PLAYER_TALENT_UPDATE()
	self:UpdateBars()
	self:UpdateValue()
end

function StatsMonitor:UNIT_AURA()
	self:UpdateValue()
end

function StatsMonitor:ACTIONBAR_UPDATE_COOLDOWN()
	self:UpdateValue()
end
