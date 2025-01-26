local _, ns = ...
local B, C, L, DB = unpack(ns)
local oUF = ns.oUF
local UF = B:GetModule("UnitFrames")

-- RaidFrame Elements
function UF:CreateRaidIcons(self)
	local check = self:CreateTexture(nil, "OVERLAY")
	check:SetSize(16, 16)
	check:SetPoint("BOTTOM", self, "BOTTOM")
	self.ReadyCheckIndicator = check

	local resurrect = self:CreateTexture(nil, "OVERLAY")
	resurrect:SetSize(20, 20)
	resurrect:SetPoint("CENTER", self, "CENTER")
	self.ResurrectIndicator = resurrect

	local role = self:CreateTexture(nil, "OVERLAY")
	role:SetSize(16, 16)
	role:SetPoint("RIGHT", self.GroupRoleIndicator, "LEFT")
	self.RaidRoleIndicator = role

	local summon = self:CreateTexture(nil, "OVERLAY")
	summon:SetSize(32, 32)
	summon:SetPoint("CENTER", self, "CENTER")
	self.SummonIndicator = summon
end

function UF:UpdateTargetBorder()
	if UnitIsUnit("target", self.unit) then
		self.TargetBorder:Show()
	else
		self.TargetBorder:Hide()
	end
end

function UF:CreateTargetBorder(self)
	local border = B.CreateBDFrame(self, 0)
	border:SetOutside(self)
	border:SetBackdropBorderColor(1, 1, 1)
	border:Hide()

	self.TargetBorder = border
	self:RegisterEvent("PLAYER_TARGET_CHANGED", UF.UpdateTargetBorder, true)
	self:RegisterEvent("GROUP_ROSTER_UPDATE", UF.UpdateTargetBorder, true)
end

function UF:UpdateThreatBorder(_, unit)
	if unit ~= self.unit then return end

	local element = self.ThreatIndicator
	local status = UnitThreatSituation(unit)

	if status and status > 1 then
		local r, g, b = unpack(oUF.colors.threat[status])
		element:SetBackdropBorderColor(r, g, b)
		element:Show()
	else
		element:Hide()
	end
end

function UF:CreateThreatBorder(self)
	local threatIndicator = B.CreateSD(self, 6, true)
	threatIndicator:SetFrameLevel(self:GetFrameLevel() + 1)
	threatIndicator:SetOutside(self, 6+C.mult, 6+C.mult)
	threatIndicator:Hide()

	self.ThreatIndicator = threatIndicator
	self.ThreatIndicator.Override = UF.UpdateThreatBorder
end

local keyList = {}
local mouseButtonList = {"LMB","RMB","MMB","MB4","MB5"}
local modKeyList = {"","ALT-","CTRL-","SHIFT-","ALT-CTRL-","ALT-SHIFT-","CTRL-SHIFT-","ALT-CTRL-SHIFT-"}
local numModKeys = #modKeyList

for i = 1, #mouseButtonList do
	local button = mouseButtonList[i]
	for j = 1, numModKeys do
		local modKey = modKeyList[j]
		keyList[modKey..button] = modKey.."%s"..i
	end
end

local wheelGroupIndex = {}
for i = 1, numModKeys do
	local modKey = modKeyList[i]
	wheelGroupIndex[5 + i] = modKey.."MOUSEWHEELUP"
	wheelGroupIndex[numModKeys + 5 + i] = modKey.."MOUSEWHEELDOWN"
end
for keyIndex, keyString in pairs(wheelGroupIndex) do
	keyString = string.gsub(keyString, "MOUSEWHEELUP", "MWU")
	keyString = string.gsub(keyString, "MOUSEWHEELDOWN", "MWD")
	keyList[keyString] = "%s"..keyIndex
end

function UF:DefaultClickSets()
	if not NDuiADB["ClickSets"][DB.MyClass] then NDuiADB["ClickSets"][DB.MyClass] = {} end
	if not next(NDuiADB["ClickSets"][DB.MyClass]) then
		for fullkey, spellID in pairs(C.ClickCastList[DB.MyClass]) do
			NDuiADB["ClickSets"][DB.MyClass][fullkey] = spellID
		end
	end
end

local onEnterString = "self:ClearBindings();"
local onLeaveString = onEnterString
for keyIndex, keyString in pairs(wheelGroupIndex) do
	onEnterString = format("%sself:SetBindingClick(0, \"%s\", self:GetName(), \"Button%d\");", onEnterString, keyString, keyIndex)
end
local onMouseString = "if not self:IsUnderMouse(false) then self:ClearBindings(); end"

local function setupMouseWheelCast(self)
	local found
	for fullkey in pairs(NDuiADB["ClickSets"][DB.MyClass]) do
		if string.match(fullkey, "MW%w") then
			found = true
			break
		end
	end

	if found then
		self:SetAttribute("clickcast_onenter", onEnterString)
		self:SetAttribute("clickcast_onleave", onLeaveString)
		self:SetAttribute("_onshow", onLeaveString)
		self:SetAttribute("_onhide", onLeaveString)
		self:SetAttribute("_onmousedown", onMouseString)
	end
end

local fixedSpells = {
	[360823] = 365585, -- incorrect spellID for Evoker
}

local function setupClickSets(self)
	if self.clickCastRegistered then return end

	for fullkey, value in pairs(NDuiADB["ClickSets"][DB.MyClass]) do
		if fullkey == "SHIFT-LMB" then self.focuser = true end

		local keyIndex = keyList[fullkey]
		if keyIndex then
			if tonumber(value) then
				value = fixedSpells[value] or value
				--self:SetAttribute(format(keyIndex, "type"), "spell")
				--self:SetAttribute(format(keyIndex, "spell"), value)
				local spellName = C_Spell.GetSpellName(value)
				if spellName then
					self:SetAttribute(format(keyIndex, "type"), "macro")
					self:SetAttribute(format(keyIndex, "macrotext"), "/cast [@mouseover]"..spellName)
				end
			elseif value == "target" then
				self:SetAttribute(format(keyIndex, "type"), "target")
			elseif value == "focus" then
				self:SetAttribute(format(keyIndex, "type"), "focus")
			elseif value == "follow" then
				self:SetAttribute(format(keyIndex, "type"), "macro")
				self:SetAttribute(format(keyIndex, "macrotext"), "/follow mouseover")
			elseif string.match(value, "/") then
				self:SetAttribute(format(keyIndex, "type"), "macro")
				value = string.gsub(value, "~", "\n")
				self:SetAttribute(format(keyIndex, "macrotext"), value)
			end
		end
	end

	setupMouseWheelCast(self)

	self.clickCastRegistered = true
end

local pendingFrames = {}
function UF:CreateClickSets(self)
	if not C.db["UFs"]["RaidClickSets"] then return end

	if InCombatLockdown() then
		pendingFrames[self] = true
	else
		setupClickSets(self)
		pendingFrames[self] = nil
	end
end

function UF:DelayClickSets()
	if not next(pendingFrames) then return end

	for frame in next, pendingFrames do
		UF:CreateClickSets(frame)
	end
end

function UF:AddClickSetsListener()
	if not C.db["UFs"]["RaidClickSets"] then return end

	B:RegisterEvent("PLAYER_REGEN_ENABLED", UF.DelayClickSets)
end

local function UpdateAltPowerAnchor(element)
	if C.db["UFs"]["PartyAltPower"] then
		local self = element.__owner
		local horizon = C.db["UFs"]["PartyDirec"] > 2
		local relF = horizon and "TOP" or "LEFT"
		local relT = horizon and "BOTTOM" or "RIGHT"
		local xOffset = horizon and 0 or 5
		local yOffset = horizon and -5 or 0
		local parent = horizon and self.Power or self

		element:Show()
		element:ClearAllPoints()
		element:SetPoint(relF, parent, relT, xOffset, yOffset)
	else
		element:Hide()
	end
end

function UF:CreatePartyAltPower(self)
	local altPower = B.CreateFS(self, 16, "")
	self:Tag(altPower, "[altpower]")
	altPower.__owner = self
	UpdateAltPowerAnchor(altPower)

	self.altPower = altPower
	self.altPower.UpdateAnchor = UpdateAltPowerAnchor
end

function UF:UpdatePartyElements()
	for _, frame in pairs(oUF.objects) do
		if frame.raidType == "party" then
			if frame.altPower then
				frame.altPower:UpdateAnchor()
			end
		end
	end
end