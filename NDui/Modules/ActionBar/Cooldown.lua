local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:RegisterModule("Cooldown")

local FONT_SIZE = 18
local MIN_DURATION = 2.5                    -- the minimum duration to show cooldown text for
local MIN_SCALE = 0.5                       -- the minimum scale we want to show cooldown counts at, anything below this will be hidden
local ICON_SIZE = 36
local hideNumbers, active, hooked = {}, {}, {}

function module:StopTimer()
	self.enabled = nil
	self:Hide()
end

function module:ForceUpdate()
	self.nextUpdate = 0
	self:Show()
end

function module:OnSizeChanged(width, height)
	local fontScale = B:Round((width+height)/2) / ICON_SIZE
	if fontScale == self.fontScale then return end
	self.fontScale = fontScale

	if fontScale < MIN_SCALE then
		self:Hide()
	else
		B.SetFontSize(self.text, fontScale * FONT_SIZE)
		if self.enabled then
			module.ForceUpdate(self)
		end
	end
end

function module:TimerOnUpdate(elapsed)
	if self.nextUpdate > 0 then
		self.nextUpdate = self.nextUpdate - elapsed
	else
		local passTime = GetTime() - self.start
		local remain = passTime >= 0 and ((self.duration - passTime) / self.modRate) or self.duration
		if remain > 0 then
			local getTime, nextUpdate = B.FormatTime(remain, self.modRate)
			self.text:SetText(getTime)
			self.nextUpdate = nextUpdate
		else
			module.StopTimer(self)
		end
	end
end

function module:ScalerOnSizeChanged(...)
	module.OnSizeChanged(self.timer, ...)
end

function module:OnCreate()
	local scaler = CreateFrame("Frame", nil, self)
	scaler:SetAllPoints(self)

	local timer = CreateFrame("Frame", nil, scaler)
	timer:SetScript("OnUpdate", module.TimerOnUpdate)
	timer:SetAllPoints(scaler)
	timer:Hide()
	scaler.timer = timer

	timer.text = B.CreateFS(timer, FONT_SIZE)

	module.OnSizeChanged(timer, scaler:GetSize())
	scaler:SetScript("OnSizeChanged", module.ScalerOnSizeChanged)

	self.timer = timer
	return timer
end

function module:StartTimer(start, duration, modRate)
	if self:IsForbidden() then return end
	if self.noCooldownCount or hideNumbers[self] then return end

	local frameName = self.GetName and self:GetName()
	if C.db["Actionbar"]["OverrideWA"] and frameName and string.find(frameName, "WeakAuras") then
		self.noCooldownCount = true
		return
	end

	local parent = self:GetParent()
	start = tonumber(start) or 0
	duration = tonumber(duration) or 0
	modRate = tonumber(modRate) or 1

	if start > 0 and duration > MIN_DURATION then
		local timer = self.timer or module.OnCreate(self)
		timer.start = start
		timer.duration = duration
		timer.modRate = modRate
		timer.enabled = true
		timer.nextUpdate = 0

		-- wait for blizz to fix itself
		local charge = parent and parent.chargeCooldown
		local chargeTimer = charge and charge.timer
		if chargeTimer and chargeTimer ~= timer then
			module.StopTimer(chargeTimer)
		end

		if timer.fontScale and timer.fontScale >= MIN_SCALE then
			timer:Show()
		end
	elseif self.timer then
		module.StopTimer(self.timer)
	end

	-- hide cooldown flash if barFader enabled
	if parent and parent.__faderParent then
		if self:GetEffectiveAlpha() > 0 then
			self:Show()
		else
			self:Hide()
		end
	end

	-- Disable blizzard cooldown numbers
	if self.SetHideCountdownNumbers then
		self:SetHideCountdownNumbers(true)
	end
end

function module:HideCooldownNumbers()
	hideNumbers[self] = true
	if self.timer then module.StopTimer(self.timer) end
end

function module:CooldownOnShow()
	active[self] = true
end

function module:CooldownOnHide()
	active[self] = nil
end

local function shouldUpdateTimer(self, start)
	local timer = self.timer
	if not timer then
		return true
	end
	return timer.start ~= start
end

function module:CooldownUpdate()
	local button = self:GetParent()
	local start, duration, _, modRate = GetActionCooldown(button.action)

	if shouldUpdateTimer(self, start) then
		module.StartTimer(self, start, duration, modRate)
	end
end

function module:ActionbarUpateCooldown()
	for cooldown in pairs(active) do
		module.CooldownUpdate(cooldown)
	end
end

function module:RegisterActionButton()
	local cooldown = self.cooldown
	if not hooked[cooldown] then
		cooldown:HookScript("OnShow", module.CooldownOnShow)
		cooldown:HookScript("OnHide", module.CooldownOnHide)

		hooked[cooldown] = true
	end
end

function module:OnSetHideCountdownNumbers(hide)
	local disable = not (hide or self.noCooldownCount or self:IsForbidden())
	if disable then
		self:SetHideCountdownNumbers(true)
	end
end

function module:OnLogin()
	if not C.db["Actionbar"]["Cooldown"] then return end

	local cooldownIndex = getmetatable(ActionButton1Cooldown).__index
	hooksecurefunc(cooldownIndex, "SetCooldown", module.StartTimer)
	hooksecurefunc(cooldownIndex, "SetHideCountdownNumbers", module.OnSetHideCountdownNumbers)
	hooksecurefunc("CooldownFrame_SetDisplayAsPercentage", module.HideCooldownNumbers)
	B:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN", module.ActionbarUpateCooldown)

	-- Hide Default Cooldown
	SetCVar("countdownForCooldowns", 0)
end