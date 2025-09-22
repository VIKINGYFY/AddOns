local _, ns = ...
local B, C, L, DB = unpack(ns)

local oUF = ns.oUF
local UF = B:RegisterModule("UnitFrames")
local AURA = B:GetModule("Auras")

-- Custom colors
oUF.colors.smooth = {1, 0, 0, .85, .8, .45, .1, .1, .1}
oUF.colors.debuff.none = {0, 0, 0}

B:RegisterEvent("PLAYER_LOGIN", function()
	if C.db["Skins"]["CustomBD"] then
		local colors = C.db["Skins"]["CustomBDColor"]
		oUF.colors.debuff.none = {colors.r, colors.g, colors.b}
	end
end)

local function ReplacePowerColor(name, index, color)
	oUF.colors.power[name] = color
	oUF.colors.power[index] = oUF.colors.power[name]
end
ReplacePowerColor("MANA", 0, {0, .4, 1})
ReplacePowerColor("SOUL_SHARDS", 7, {.58, .51, .79})
ReplacePowerColor("HOLY_POWER", 9, {.88, .88, .06})
ReplacePowerColor("CHI", 12, {0, 1, .59})
ReplacePowerColor("ARCANE_CHARGES", 16, {.41, .8, .94})

-- Various values
local function retVal(self, val1, val2, val3, val4, val5)
	local mystyle = self.mystyle

	if mystyle == "player" or mystyle == "target" then
		return val1
	elseif mystyle == "focus" then
		return val2
	elseif mystyle == "boss" or mystyle == "arena" then
		return val3
	else
		if mystyle == "nameplate" and val5 then
			return val5
		else
			return val4
		end
	end
end

-- Elements
local function UF_OnEnter(self)
	if not self.disableTooltip then
		UnitFrame_OnEnter(self)
	end
end

local function UF_OnLeave(self)
	if not self.disableTooltip then
		UnitFrame_OnLeave(self)
	end
end

function UF:UpdateClickState()
	self:RegisterForClicks(self.onKeyDown and "AnyDown" or "AnyUp")
	self.onKeyDown = nil
	self:UnregisterEvent("PLAYER_REGEN_ENABLED", UF.UpdateClickState, true)
end

function UF:CreateHeader(self, onKeyDown)
	local hl = self:CreateTexture(nil, "HIGHLIGHT")
	hl:SetAllPoints()
	hl:SetTexture("Interface\\PETBATTLES\\PetBattle-SelectedPetGlow")
	hl:SetTexCoord(0, 1, .5, 1)
	hl:SetVertexColor(.5, .5, .5)
	hl:SetBlendMode("ADD")
	self.hl = hl

	if InCombatLockdown() then
		self.onKeyDown = onKeyDown
		self:RegisterEvent("PLAYER_REGEN_ENABLED", UF.UpdateClickState, true)
	else
		self:RegisterForClicks(onKeyDown and "AnyDown" or "AnyUp")
	end
	self:HookScript("OnEnter", UF_OnEnter)
	self:HookScript("OnLeave", UF_OnLeave)
end

local function UpdateHealthColorByIndex(health, index)
	health.colorClass = (index == 2)
	health.colorReaction = (index == 2)
	health.colorSmooth = (index == 3)

	if health.SetColorTapping then
		health:SetColorTapping(index == 2)
	else
		health.colorTapping = (index == 2)
	end
	if health.SetColorDisconnected then
		health:SetColorDisconnected(index == 2)
	else
		health.colorDisconnected = (index == 2)
	end
	if index == 1 then
		health:SetStatusBarColor(.1, .1, .1, 1)
		health.bg:SetVertexColor(.9, .9, .9, 1)
	elseif index == 4 then
		health:SetStatusBarColor(0, 0, 0, 0)
	end
end

function UF:UpdateHealthBarColor(self, force)
	local mystyle, health = self.mystyle, self.Health

	if mystyle == "playerplate" then
		health.colorHealth = true
	elseif mystyle == "raid" then
		UpdateHealthColorByIndex(health, C.db["UFs"]["RaidHealthColor"])
	else
		UpdateHealthColorByIndex(health, C.db["UFs"]["HealthColor"])
	end

	if force then
		health:ForceUpdate()
	end
end

function UF.HealthPostUpdate(element, unit, cur, max)
	local self = element.__owner
	local mystyle = self.mystyle

	local useGradient, useGradientClass
	if mystyle == "playerplate" then
		-- do nothing
	elseif mystyle == "raid" then
		useGradient = C.db["UFs"]["RaidHealthColor"] >= 4
		useGradientClass = C.db["UFs"]["RaidHealthColor"] == 5
	else
		useGradient = C.db["UFs"]["HealthColor"] >= 4
		useGradientClass = C.db["UFs"]["HealthColor"] == 5
	end
	if useGradient then
		element.bg:SetVertexColor(self:ColorGradient(cur or 1, max or 1, 1,0,0, 1,1,0, 0,1,0))
	end
	if useGradientClass then
		local class = select(2, UnitClass(unit))
		local reaction = UnitReaction(unit, "player")

		local color
		if UnitIsTapDenied(unit) then
			color = self.colors.tapped
		elseif UnitIsPlayer(unit) or UnitInPartyIsAI(unit) then
			color = self.colors.class[class]
		elseif reaction then
			color = self.colors.reaction[reaction]
		end

		if color then
			element:GetStatusBarTexture():SetGradient("HORIZONTAL", CreateColor(color[1], color[2], color[3], 1), CreateColor(0, 0, 0, 0))
		end
	end
end

function UF:CreateHealthBar(self)
	local mystyle = self.mystyle

	local health = CreateFrame("StatusBar", nil, self)
	health:SetFrameLevel(self:GetFrameLevel() - 1)
	health:SetStatusBarTexture(DB.normTex)
	health:SetStatusBarColor(.1, .1, .1)
	health:SetPoint("TOPLEFT", self, "TOPLEFT")
	health:SetPoint("TOPRIGHT", self, "TOPRIGHT")

	local healthHeight
	if mystyle == "playerplate" then
		healthHeight = C.db["Nameplate"]["PPHealthHeight"]
	elseif mystyle == "raid" then
		if self.raidType == "party" then
			healthHeight = C.db["UFs"]["PartyHeight"]
		elseif self.raidType == "pet" then
			healthHeight = C.db["UFs"]["PartyPetHeight"]
		elseif self.raidType == "simple" then
			local scale = C.db["UFs"]["SMRScale"]/10
			healthHeight = 20*scale - 2*scale - C.mult
		else
			healthHeight = C.db["UFs"]["RaidHeight"]
		end
	else
		healthHeight = retVal(self, C.db["UFs"]["PlayerHeight"], C.db["UFs"]["FocusHeight"], C.db["UFs"]["BossHeight"], C.db["UFs"]["PetHeight"])
	end
	health:SetHeight(healthHeight)

	B.CreateBG(health):SetOutside(self)
	B.SmoothBar(health)

	local bg = health:CreateTexture(nil, "BORDER")
	bg:SetPoint("TOPLEFT", health:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
	bg:SetPoint("BOTTOMRIGHT", health, "BOTTOMRIGHT", 0, 0)
	bg:SetVertexColor(.9, .9, .9)
	bg:SetTexture(DB.normTex)
	bg.multiplier = .25

	self.Health = health
	self.Health.bg = bg
	self.Health.PostUpdate = UF.HealthPostUpdate

	UF:UpdateHealthBarColor(self)
end

UF.VariousTagIndex = {
	[1] = "",
	[2] = "currentpercent",
	[3] = "currentmaximum",
	[4] = "current",
	[5] = "percent",
	[6] = "loss",
	[7] = "losspercent",
	[8] = "absorb",
}

function UF:UpdateFrameHealthTag()
	local mystyle, hpval = self.mystyle, self.healthValue
	if mystyle == "raid" or mystyle == "nameplate" then return end

	local valueType
	if mystyle == "player" or mystyle == "target" then
		valueType = UF.VariousTagIndex[C.db["UFs"]["PlayerHPTag"]]
	elseif mystyle == "focus" then
		valueType = UF.VariousTagIndex[C.db["UFs"]["FocusHPTag"]]
	elseif mystyle == "boss" or mystyle == "arena" then
		valueType = UF.VariousTagIndex[C.db["UFs"]["BossHPTag"]]
	else
		valueType = UF.VariousTagIndex[C.db["UFs"]["PetHPTag"]]
	end

	self:Tag(hpval, "[VariousHP("..valueType..")]")
	hpval:UpdateTag()
end

function UF:UpdateFrameNameTag()
	local mystyle, name = self.mystyle, self.nameText
	if mystyle == "nameplate" then return end

	local nameColor = C.db["UFs"]["CustomNameColor"]
	local value = mystyle == "raid" and "RCCName" or "CCName"
	local colorTag = C.db["UFs"][value] and "[color]" or B.HexRGB(nameColor)

	if mystyle == "player" then
		self:Tag(name, colorTag.."[name][flags]")
	elseif mystyle == "target" or mystyle == "focus" then
		self:Tag(name, "[fulllevel] "..colorTag.."[name][flags]")
	elseif mystyle == "arena" then
		self:Tag(name, "[arenaspec] "..colorTag.."[name]")
	elseif self.raidType == "simple" and C.db["UFs"]["TeamIndex"] then
		self:Tag(name, "[group] "..colorTag.."[name]")
	else
		self:Tag(name, colorTag.."[name]")
	end

	name:UpdateTag()
end

function UF:UpdateRaidTextAnchor()
	if self.mystyle ~= "raid" then return end

	local health, name, hpval = self.Health, self.nameText, self.healthValue
	name:ClearAllPoints()
	hpval:ClearAllPoints()

	if C.db["UFs"]["RaidHPMode"] == 1 then
		name:SetJustifyH("CENTER")
		name:SetWidth(self:GetWidth() * .9)
		name:SetPoint("CENTER", health, "CENTER")

		hpval:SetJustifyH("CENTER")
		hpval:SetPoint("TOP", name, "BOTTOM")
	else
		if self.raidType == "pet" or self.raidType == "simple" then
			hpval:SetJustifyH("RIGHT")
			hpval:SetPoint("RIGHT", health, "RIGHT")

			name:SetJustifyH("LEFT")
			name:SetPoint("LEFT", health, "LEFT")
			name:SetPoint("RIGHT", hpval, "LEFT")
		else
			hpval:SetJustifyH("CENTER")
			hpval:SetPoint("TOP", health, "CENTER")

			name:SetJustifyH("CENTER")
			name:SetWidth(self:GetWidth() * .9)
			name:SetPoint("BOTTOM", health, "CENTER")
		end
	end
end

function UF:CreateHealthText(self)
	local mystyle, health = self.mystyle, self.Health

	local hpval = B.CreateFS(self, retVal(self, 13, 12, 12, 12, C.db["Nameplate"]["NameTextSize"]))
	hpval:SetJustifyH("RIGHT")
	hpval:ClearAllPoints()
	hpval:SetPoint("RIGHT", health, "RIGHT", -DB.margin, 0)
	self.healthValue = hpval

	if mystyle == "raid" then
		self:Tag(hpval, "[raidhp]")
		hpval:SetScale(C.db["UFs"]["RaidTextScale"])
	elseif mystyle == "nameplate" then
		hpval:ClearAllPoints()
		hpval:SetPoint("RIGHT", health, "RIGHT", 0, 0)
		hpval:SetJustifyH("RIGHT")
		self:Tag(hpval, "[VariousHP(currentpercent)]")
	end

	local name = B.CreateFS(self, retVal(self, 13, 12, 12, 12, C.db["Nameplate"]["NameTextSize"]))
	name:SetJustifyH("LEFT")
	name:ClearAllPoints()
	name:SetPoint("LEFT", health, "LEFT", DB.margin, 0)
	name:SetPoint("RIGHT", hpval, "LEFT", -DB.margin, 0)
	self.nameText = name

	if mystyle == "raid" then
		name:SetScale(C.db["UFs"]["RaidTextScale"])
	elseif mystyle == "nameplate" then
		name:ClearAllPoints()
		name:SetPoint("BOTTOMLEFT", health, "TOPLEFT", 0, DB.margin)
		name:SetPoint("BOTTOMRIGHT", health, "TOPRIGHT", 0, DB.margin)
		self:Tag(name, "[nplevel][name]")
	end

	UF.UpdateFrameNameTag(self)
	UF.UpdateFrameHealthTag(self)
	UF.UpdateRaidTextAnchor(self)
end

local function UpdatePowerColorByIndex(power, index)
	power.colorPower = (index == 2) or (index == 5)
	power.colorClass = (index ~= 2)
	power.colorReaction = (index ~= 2)

	if power.SetColorTapping then
		power:SetColorTapping(index ~= 2)
	else
		power.colorTapping = (index ~= 2)
	end
	if power.SetColorDisconnected then
		power:SetColorDisconnected(index ~= 2)
	else
		power.colorDisconnected = (index ~= 2)
	end
end

function UF:UpdatePowerBarColor(self, force)
	local mystyle, power = self.mystyle, self.Power

	if mystyle == "playerplate" then
		power.colorPower = true
	elseif mystyle == "raid" then
		UpdatePowerColorByIndex(power, C.db["UFs"]["RaidHealthColor"])
	else
		UpdatePowerColorByIndex(power, C.db["UFs"]["HealthColor"])
	end

	if force then
		power:ForceUpdate()
	end
end

local frequentUpdateCheck = {
	["player"] = true,
	["target"] = true,
	["focus"] = true,
	["PlayerPlate"] = true,
}
function UF:CreatePowerBar(self)
	local mystyle = self.mystyle

	local power = CreateFrame("StatusBar", nil, self)
	power:SetFrameLevel(self:GetFrameLevel() - 1)
	power:SetStatusBarTexture(DB.normTex)
	power:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT")
	power:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT")

	local powerHeight
	if mystyle == "playerplate" then
		powerHeight = C.db["Nameplate"]["PPPowerHeight"]
	elseif mystyle == "raid" then
		if self.raidType == "party" then
			powerHeight = C.db["UFs"]["PartyPowerHeight"]
		elseif self.raidType == "pet" then
			powerHeight = C.db["UFs"]["PartyPetPowerHeight"]
		elseif self.raidType == "simple" then
			powerHeight = 2*C.db["UFs"]["SMRScale"]/10
		else
			powerHeight = C.db["UFs"]["RaidPowerHeight"]
		end
	else
		powerHeight = retVal(self, C.db["UFs"]["PlayerPowerHeight"], C.db["UFs"]["FocusPowerHeight"], C.db["UFs"]["BossPowerHeight"], C.db["UFs"]["PetPowerHeight"])
	end
	power:SetHeight(powerHeight)
	power.wasHidden = powerHeight == 0

	B.CreateBDFrame(power, 0, nil, -1)
	B.SmoothBar(power)

	local bg = power:CreateTexture(nil, "BORDER")
	bg:SetTexture(DB.normTex)
	bg:SetAllPoints()
	bg.multiplier = .25

	self.Power = power
	self.Power.bg = bg

	power.frequentUpdates = frequentUpdateCheck[mystyle]
	UF:UpdatePowerBarColor(self)
end

function UF:CheckPowerBars()
	for _, frame in pairs(oUF.objects) do
		if frame.Power and frame.Power.wasHidden then
			frame:DisableElement("Power")
			if frame.powerText then frame.powerText:Hide() end
		end
	end
end

function UF:UpdateFramePowerTag()
	local mystyle = self.mystyle

	local valueType
	if mystyle == "player" or mystyle == "target" then
		valueType = UF.VariousTagIndex[C.db["UFs"]["PlayerMPTag"]]
	elseif mystyle == "focus" then
		valueType = UF.VariousTagIndex[C.db["UFs"]["FocusMPTag"]]
	else
		valueType = UF.VariousTagIndex[C.db["UFs"]["BossMPTag"]]
	end

	self:Tag(self.powerText, "[color][VariousMP("..valueType..")]")
	self.powerText:UpdateTag()
end

function UF:CreatePowerText(self)
	local mystyle, power = self.mystyle, self.Power

	local ppval = B.CreateFS(self, retVal(self, 13, 12, 12, 12))
	ppval:SetJustifyH("RIGHT")
	ppval:ClearAllPoints()
	ppval:SetPoint("RIGHT", power, "RIGHT", -DB.margin, 0)
	self.powerText = ppval

	if mystyle == "raid" then
		ppval:SetScale(C.db["UFs"]["RaidTextScale"])
	end

	UF.UpdateFramePowerTag(self)
end

local textScaleFrames = {
	["player"] = true,
	["target"] = true,
	["focus"] = true,
	["pet"] = true,
	["tot"] = true,
	["fot"] = true,
	["boss"] = true,
	["arena"] = true,
}
function UF:UpdateTextScale()
	local scale = C.db["UFs"]["UFTextScale"]
	for _, frame in pairs(oUF.objects) do
		local style = frame.mystyle
		if style and textScaleFrames[style] then
			frame.nameText:SetScale(scale)
			frame.healthValue:SetScale(scale)
			if frame.powerText then frame.powerText:SetScale(scale) end
			local castbar = frame.Castbar
			if castbar then
				if castbar.Text then castbar.Text:SetScale(scale) end
				if castbar.Time then castbar.Time:SetScale(scale) end
				if castbar.Lag then castbar.Lag:SetScale(scale) end
			end
			UF:UpdateHealthBarColor(frame, true)
			UF:UpdatePowerBarColor(frame, true)
			UF.UpdateFrameNameTag(frame)
		end
	end
end

function UF:UpdateRaidTextScale()
	local scale = C.db["UFs"]["RaidTextScale"]
	for _, frame in pairs(oUF.objects) do
		if frame.mystyle == "raid" then
			frame.nameText:SetScale(scale)
			frame.healthValue:SetScale(scale)
			frame.healthValue:UpdateTag()
			if frame.powerText then frame.powerText:SetScale(scale) end
			UF.UpdateRaidTextAnchor(frame)
			UF:UpdateHealthBarColor(frame, true)
			UF:UpdatePowerBarColor(frame, true)
			UF.UpdateFrameNameTag(frame)
			frame.disableTooltip = C.db["UFs"]["HideTip"]
		end
	end
end

function UF:CreatePortrait(self)
	local portrait = CreateFrame("PlayerModel", nil, self)
	portrait:SetFrameLevel(self:GetFrameLevel())
	portrait:SetAllPoints()
	portrait:SetAlpha(.2)

	self.Portrait = portrait
end

function UF:TogglePortraits()
	for _, frame in pairs(oUF.objects) do
		if frame.Portrait then
			if C.db["UFs"]["Portrait"] and not frame:IsElementEnabled("Portrait") then
				frame:EnableElement("Portrait")
				frame.Portrait:ForceUpdate()
			elseif not C.db["UFs"]["Portrait"] and frame:IsElementEnabled("Portrait") then
				frame:DisableElement("Portrait")
			end
		end
	end
end

local function postUpdateRole(element, role)
	if element:IsShown() then
		if role == "DAMAGER" and C.db["UFs"]["ShowRoleMode"] == 3 then
			element:Hide()
			return
		end
		B.ReskinSmallRole(element, role)
	end
end

function UF:CreateRestingIndicator(self)
	local frame = CreateFrame("Frame", "NDuiRestingFrame", self)
	frame:SetFrameLevel(self:GetFrameLevel())
	frame:SetSize(5, 5)
	frame:SetPoint("CENTER", self, "LEFT", -2, 4)
	frame:Hide()
	frame.str = {}

	local step, stepSpeed = 0, .33

	local stepMaps = {
		[1] = {true, false, false},
		[2] = {true, true, false},
		[3] = {true, true, true},
		[4] = {false, true, true},
		[5] = {false, false, true},
		[6] = {false, false, false},
	}

	local offsets = {
		[1] = {5, -5},
		[2] = {0, 0},
		[3] = {-5, 5},
	}

	for i = 1, 3 do
		local textFrame = CreateFrame("Frame", nil, frame)
		textFrame:SetAllPoints()
		textFrame:SetFrameLevel(self:GetFrameLevel() + i)
		local text = B.CreateFS(textFrame, (7+i*3), "z", "info", "CENTER", offsets[i][1], offsets[i][2])
		frame.str[i] = text
	end

	frame:SetScript("OnUpdate", function(self, elapsed)
		self.elapsed = (self.elapsed or 0) + elapsed
		if self.elapsed > stepSpeed then
			step = step + 1
			if step == 7 then step = 1 end

			for i = 1, 3 do
				frame.str[i]:SetShown(stepMaps[step][i])
			end

			self.elapsed = 0
		end
	end)

	frame:SetScript("OnHide", function()
		step = 6
	end)

	self.RestingIndicator = frame
end

function UF:CreateIcons(self)
	local mystyle = self.mystyle

	if mystyle == "player" then
		local combat = self:CreateTexture(nil, "OVERLAY")
		combat:SetPoint("CENTER", self, "BOTTOMLEFT")
		combat:SetSize(28, 28)
		combat:SetAtlas(DB.combatTex)
		self.CombatIndicator = combat
	elseif mystyle == "target" then
		local quest = self:CreateTexture(nil, "OVERLAY")
		quest:SetPoint("LEFT", self, "TOPLEFT")
		quest:SetSize(16, 16)
		self.QuestIndicator = quest
	end

	local phase = CreateFrame("Frame", nil, self)
	phase:SetFrameLevel(self:GetFrameLevel())
	phase:SetPoint("CENTER", self.Health, "CENTER")
	phase:SetSize(24, 24)
	phase:EnableMouse(true)
	local icon = phase:CreateTexture(nil, "OVERLAY")
	icon:SetAllPoints()
	phase.Icon = icon
	self.PhaseIndicator = phase

	if C.db["UFs"]["ShowRoleMode"] ~= 2 then
		local ri = self:CreateTexture(nil, "OVERLAY")
		ri:SetPoint("RIGHT", self, "TOPRIGHT")
		ri:SetSize(12, 12)
		ri.PostUpdate = postUpdateRole
		self.GroupRoleIndicator = ri
	end

	local li = self:CreateTexture(nil, "OVERLAY")
	li:SetPoint("LEFT", self, "TOPLEFT")
	li:SetSize(14, 14)
	self.LeaderIndicator = li

	local ai = self:CreateTexture(nil, "OVERLAY")
	ai:SetPoint("LEFT", self, "TOPLEFT")
	ai:SetSize(14, 14)
	self.AssistantIndicator = ai
end

function UF:CreateRaidMark(self)
	local mystyle = self.mystyle

	local ri = self:CreateTexture(nil, "OVERLAY")
	if mystyle == "nameplate" then
		ri:SetPoint("BOTTOMLEFT", self, "TOPRIGHT")
	else
		ri:SetPoint("CENTER", self, "TOP")
	end
	local size = retVal(self, 18, 14, 12, 12, 32)
	ri:SetSize(size, size)
	self.RaidTargetIndicator = ri
end

local function createBarMover(bar, text, value, anchor)
	local mover = B.Mover(bar, text, value, anchor, bar:GetWidth() + bar:GetHeight() + DB.margin, bar:GetHeight())
	bar:ClearAllPoints()
	bar:SetPoint("RIGHT", mover, "RIGHT", 0, 0)
	bar.mover = mover
end

local function updateSpellTarget(self, _, unit)
	UF.PostCastUpdate(self.Castbar, unit)
end

function UF:ToggleCastBarLatency(frame)
	frame = frame or _G.oUF_Player
	if not frame then return end

	frame:RegisterEvent("GLOBAL_MOUSE_UP", UF.OnCastSent, true) -- Fix quests with WorldFrame interaction
	frame:RegisterEvent("GLOBAL_MOUSE_DOWN", UF.OnCastSent, true)
	frame:RegisterEvent("CURRENT_SPELL_CAST_CHANGED", UF.OnCastSent, true)
end

local styleList = {
	["player"] = true,
	["target"] = true,
	["focus"] = true,
}

function UF:CreateCastBar(self)
	local mystyle = self.mystyle
	if mystyle ~= "nameplate" and not C.db["UFs"]["Castbars"] then return end

	local healthCastBar = C.db["Nameplate"]["HealthCastBar"]

	local cb = B.CreateSB(self, true, nil, "oUF_Castbar"..mystyle)
	cb:SetHeight(20)
	cb:SetWidth(self:GetWidth() - (cb:GetHeight() + DB.margin))
	cb.castTicks = {}

	if mystyle == "player" then
		cb:SetSize(C.db["UFs"]["PlayerCBWidth"], C.db["UFs"]["PlayerCBHeight"])
		createBarMover(cb, L["Player Castbar"], "PlayerCB", C.UFs.PlayerCB)
	elseif mystyle == "target" then
		cb:SetSize(C.db["UFs"]["TargetCBWidth"], C.db["UFs"]["TargetCBHeight"])
		createBarMover(cb, L["Target Castbar"], "TargetCB", C.UFs.TargetCB)
	elseif mystyle == "focus" then
		cb:SetSize(C.db["UFs"]["FocusCBWidth"], C.db["UFs"]["FocusCBHeight"])
		createBarMover(cb, L["Focus Castbar"], "FocusCB", C.UFs.FocusCB)
	elseif mystyle == "boss" or mystyle == "arena" then
		cb:ClearAllPoints()
		cb:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -DB.margin)
		cb:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -DB.margin)
		cb:SetHeight(10)
	elseif mystyle == "nameplate" then
		cb:ClearAllPoints()
		if healthCastBar then
			cb:SetAllPoints(self)
			cb:SetFrameLevel(self:GetFrameLevel() + 1)
			cb.bd:SetBackdropColor(0, 0, 0, 1)
		else
			cb:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -DB.margin)
			cb:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -DB.margin)
			cb:SetHeight(self:GetHeight())
		end
	end

	local cbTextSize = math.floor(cb:GetHeight() * (styleList[mystyle] and 0.6 or 1.2))
	local timer = B.CreateFS(cb, cbTextSize, "", false, "RIGHT", -DB.margin, 0)
	local name = B.CreateFS(cb, cbTextSize, "", false, "LEFT", DB.margin, 0)
	name:SetPoint("RIGHT", timer, "LEFT", -DB.margin, 0)

	if mystyle ~= "boss" and mystyle ~= "arena" then
		cb.Icon = cb:CreateTexture(nil, "ARTWORK")
		cb.Icon:SetSize(cb:GetHeight(), cb:GetHeight())
		cb.Icon:SetPoint("BOTTOMRIGHT", cb, "BOTTOMLEFT", -DB.margin, 0)
		B.ReskinIcon(cb.Icon, true)
	end

	if mystyle == "player" then
		local safeZone = cb:CreateTexture(nil, "OVERLAY")
		safeZone:SetTexture(DB.normTex)
		safeZone:SetVertexColor(1, 0, 0, .5)
		safeZone:SetPoint("TOPRIGHT")
		safeZone:SetPoint("BOTTOMRIGHT")
		cb.SafeZone = safeZone

		UF:ToggleCastBarLatency(self)
	elseif mystyle == "nameplate" then
		timer:ClearAllPoints()
		timer:SetPoint("RIGHT", cb, "RIGHT", 0, 0)

		name:ClearAllPoints()
		name:SetPoint("LEFT", cb, "LEFT", 0, 0)
		name:SetPoint("RIGHT", timer, "LEFT", -DB.margin, 0)

		local iconSize = cb:GetHeight() * 2 + (healthCastBar and 0 or DB.margin)
		cb.Icon:SetSize(iconSize, iconSize)

		cb.timeToHold = .5
		cb.glowFrame = B.CreateGlowFrame(cb.Icon)

		local spellTarget = B.CreateFS(cb, C.db["Nameplate"]["NameTextSize"]+4)
		spellTarget:ClearAllPoints()
		spellTarget:SetJustifyH("LEFT")
		spellTarget:SetPoint("TOPLEFT", cb, "BOTTOMLEFT", 0, -DB.margin)
		cb.spellTarget = spellTarget

		self:RegisterEvent("UNIT_TARGET", updateSpellTarget)
	end

	cb.Time = timer
	cb.Text = name
	cb.decimal = (styleList[mystyle] and "%.2f" or "%.1f")
	cb.OnUpdate = UF.OnCastbarUpdate
	cb.PostCastStart = UF.PostCastStart
	cb.PostCastUpdate = UF.PostCastUpdate
	cb.PostCastStop = UF.PostCastStop
	cb.PostCastFail = UF.PostCastFailed
	cb.PostCastInterruptible = UF.PostUpdateInterruptible
	cb.CreatePip = UF.CreatePip
	cb.PostUpdatePips = UF.PostUpdatePips

	self.Castbar = cb
end

function UF:CreateSparkleCastBar(self)
	local bar = CreateFrame("StatusBar", "oUF_SparkleCastbar"..self.mystyle, self.Power)
	bar:SetStatusBarTexture(0)
	bar:SetAllPoints()

	local spark = bar:CreateTexture(nil, "OVERLAY")
	spark:SetTexture(DB.sparkTex)
	spark:SetBlendMode("ADD")
	spark:SetPoint("TOP", bar:GetStatusBarTexture(), "TOPRIGHT", 0, 15)
	spark:SetPoint("BOTTOM", bar:GetStatusBarTexture(), "BOTTOMRIGHT", 0, -15)
	bar.Spark = spark

	self.Castbar = bar
end

function UF:ToggleCastBar(unit)
	if not self or not unit then return end

	if C.db["UFs"][unit.."CB"] and not self:IsElementEnabled("Castbar") then
		self:EnableElement("Castbar")
	elseif not C.db["UFs"][unit.."CB"] and self:IsElementEnabled("Castbar") then
		self:DisableElement("Castbar")
	end
end

local function reskinTimerBar(bar)
	bar:SetSize(280, 18)

	B.StripTextures(bar)
	B.CreateBG(bar, -1)

	local statusbar = B.GetObject(bar, "StatusBar")
	if statusbar then
		statusbar:SetAllPoints()
	else
		bar:SetStatusBarTexture(DB.normTex)
	end

	local text = B.GetObject(bar, "Text")
	B.UpdatePoint(text, "CENTER", bar, "CENTER")
end

function UF:ReskinMirrorBars()
	hooksecurefunc(MirrorTimerContainer, "SetupTimer", function(self, timer)
		local bar = self:GetAvailableTimer(timer)
		if bar and not bar.styled then
			reskinTimerBar(bar)
			bar.styled = true
		end
	end)
end

function UF:ReskinTimerTrakcer(self)
	local function updateTimerTracker()
		for _, timer in pairs(TimerTracker.timerList) do
			if timer.bar and not timer.bar.styled then
				reskinTimerBar(timer.bar)

				timer.bar.styled = true
			end
		end
	end
	self:RegisterEvent("START_TIMER", updateTimerTracker, true)
end

-- Auras Relevant
local tL, tR, tT, tB = unpack(DB.TexCoord)
function UF:UpdateIconTexCoord(width, height)
	local ratio = height / width
	local mult = (1 - ratio) / 2
	self.Icon:SetTexCoord(tL, tR, tT + mult, tB - mult)
end

function UF.PostCreateButton(element, button)
	local fontSize = element.fontSize or element.size*.6

	button.Count = B.CreateFS(button, fontSize, "", false, "BOTTOMRIGHT", 6, -3)
	button.timer = B.CreateFS(button, fontSize)
	button.icbg = B.ReskinIcon(button.Icon, true)

	button.HL = button:CreateTexture(nil, "HIGHLIGHT")
	button.HL:SetColorTexture(1, 1, 1, .25)
	button.HL:SetInside(button.icbg)
	button.HL:SetBlendMode("ADD")

	button.Overlay:SetTexture(nil)
	button.Cooldown:SetReverse(true)
	button.Stealable:SetAtlas("bags-newitem")
	button.Stealable:SetOutside(button.icbg, 5, 5)

	if AURA then
		button:HookScript("OnMouseDown", AURA.RemoveSpellFromIgnoreList)
	end

	if element.disableCooldown then
		hooksecurefunc(button, "SetSize", UF.UpdateIconTexCoord)
		button.timer:SetJustifyH("LEFT")
		B.UpdatePoint(button.timer, "LEFT", button, "TOPLEFT", -2, 0)
		button.Count:SetJustifyH("RIGHT")
		B.UpdatePoint(button.Count, "RIGHT", button, "BOTTOMRIGHT", 2, 0)
	end
end

local filteredStyle = {
	["target"] = true,
	["nameplate"] = true,
	["boss"] = true,
	["arena"] = true,
}

UF.ReplacedSpellIcons = {
	[368078] = 348567, -- 移速
	[368079] = 348567, -- 移速
	[368103] = 648208, -- 急速
	[368243] = 237538, -- CD
	[373785] = 236293, -- S4，大魔王伪装
}

local dispellType = {
	["Magic"] = true,
	[""] = true,
}

function UF.PostUpdateButton(element, button, unit, data)
	local duration, expiration, debuffType, isPlayerAura = data.duration, data.expirationTime, data.dispelName, data.isPlayerAura

	if duration then button.icbg:Show() end

	local style = element.__owner.mystyle
	if style == "nameplate" then
		button:SetSize(element.size, element.size * .5)
	else
		button:SetSize(element.size, element.size)
	end

	if element.desaturateDebuff and button.isHarmful and filteredStyle[style] and not isPlayerAura then
		button.Icon:SetDesaturated(true)
	else
		button.Icon:SetDesaturated(false)
	end

	if element.showDebuffType and button.isHarmful then
		local color = oUF.colors.debuff[debuffType] or oUF.colors.debuff.none
		button.icbg:SetBackdropBorderColor(color[1], color[2], color[3])
	else
		B.SetBorderColor(button.icbg)
	end

	if element.alwaysShowStealable and dispellType[debuffType] and not (UnitIsPlayer(unit) and button.isHarmful) then
		button.Stealable:Show()
	end

	if element.disableCooldown then
		if duration and duration > 0 then
			button.expiration = expiration
			button:SetScript("OnUpdate", B.CooldownOnUpdate)
			button.timer:Show()
		else
			button:SetScript("OnUpdate", nil)
			button.timer:Hide()
		end
	end

	local newTexture = UF.ReplacedSpellIcons[button.spellID]
	if newTexture then
		button.Icon:SetTexture(newTexture)
	end

	if element.bolsterInstanceID and element.bolsterInstanceID == button.auraInstanceID then
		button.Count:SetText(element.bolsterStacks)
	end
end

function UF.AurasPostUpdateInfo(element)
	element.hasTheDot = nil
	for _, data in pairs(element.allDebuffs) do
		if data.isPlayerAura and C.db["Nameplate"]["DotSpells"][data.spellId] then
			element.hasTheDot = true
			break
		end
	end
end

function UF.PostUpdateGapButton(_, _, button)
	if button.icbg and button.icbg:IsShown() then
		button.icbg:Hide()
	end
end

function UF.CustomFilter(element, unit, data)
	local style = element.__owner.mystyle
	local spellName, debuffType, isStealable, spellID, nameplateShowAll, isHarmful, isPlayerAura = data.name, data.dispelName, data.isStealable, data.spellId, data.nameplateShowAll, data.isHarmful, data.isPlayerAura

	if style == "nameplate" or style == "boss" or style == "arena" then
		if element.__owner.plateType == "NameOnly" then
			return UF.NameplateWhite[spellID]
		elseif UF.NameplateBlack[spellID] then
			return false
		elseif ((element.showStealableBuffs and isStealable) or (element.alwaysShowStealable and dispellType[debuffType])) and not (UnitIsPlayer(unit) and isHarmful) then
			return true
		elseif UF.NameplateWhite[spellID] then
			return true
		else
			local auraFilter = C.db["Nameplate"]["AuraFilter"]
			return (auraFilter == 3 and nameplateShowAll) or (auraFilter ~= 1 and isPlayerAura)
		end
	else
		return (element.onlyShowPlayer and isPlayerAura) or (not element.onlyShowPlayer and spellName)
	end
end

function UF.UnitCustomFilter(element, _, data)
	local value = element.__value
	if data.isHarmful then
		if C.db["UFs"][value.."DebuffType"] == 2 then
			return data.name
		elseif C.db["UFs"][value.."DebuffType"] == 3 then
			return data.isPlayerAura
		end
	else
		if C.db["UFs"][value.."BuffType"] == 2 then
			return data.name
		elseif C.db["UFs"][value.."BuffType"] == 3 then
			return data.isStealable
		end
	end
end

local function auraIconSize(w, n, s)
	return (w-(n-1)*s)/n
end

function UF:UpdateAuraContainer(parent, element, maxAuras)
	local width = parent:GetWidth()
	local iconsPerRow = element.iconsPerRow
	local maxLines = iconsPerRow and B:Round(maxAuras/iconsPerRow) or 2
	element.size = iconsPerRow and auraIconSize(width, iconsPerRow, element.spacing) or element.size
	element:SetWidth(width)
	element:SetHeight((element.size + element.spacing) * maxLines)

	local fontSize = element.fontSize or element.size*.6
	for i = 1, #element do
		local button = element[i]
		if button then
			if button.timer then B.SetFontSize(button.timer, fontSize) end
			if button.Count then B.SetFontSize(button.Count, fontSize) end
		end
	end
end

function UF:ConfigureAuras(element, type)
	local value = element.__value

	element.num = C.db["UFs"][value..type.."Type"] ~= 1 and C.db["UFs"][value.."Num"..type] or 0
	element.numBuffs = C.db["UFs"][value.."BuffType"] ~= 1 and C.db["UFs"][value.."NumBuff"] or 0
	element.numDebuffs = C.db["UFs"][value.."DebuffType"] ~= 1 and C.db["UFs"][value.."NumDebuff"] or 0
	element.iconsPerRow = C.db["UFs"][value..type.."PerRow"]
	element.showDebuffType = true
	element.desaturateDebuff = true
	element.showStealableBuffs = true
end

function UF:RefreshUFAuras(frame)
	if not frame then return end

	if frame.Auras then
		UF:ConfigureAuras(frame.Auras, "Auras")
		UF:UpdateAuraContainer(frame, frame.Auras, frame.Auras.numBuffs + frame.Auras.numDebuffs)
		UF:UpdateAuraDirection(frame, frame.Auras)
		frame.Auras:ForceUpdate()
	elseif frame.Buffs then
		UF:ConfigureAuras(frame.Buffs, "Buff")
		UF:UpdateAuraContainer(frame, frame.Buffs, frame.Buffs.num)
		frame.Buffs:ForceUpdate()
	elseif frame.Debuffs then
		UF:ConfigureAuras(frame.Debuffs, "Debuffs")
		UF:UpdateAuraContainer(frame, frame.Debuffs, frame.Debuffs.num)
		frame.Debuffs:ForceUpdate()
	end
end

function UF:UpdateUFAuras()
	UF:RefreshUFAuras(_G.oUF_Player)
	UF:RefreshUFAuras(_G.oUF_Target)
	UF:RefreshUFAuras(_G.oUF_Focus)
	UF:RefreshUFAuras(_G.oUF_ToT)
	UF:RefreshUFAuras(_G.oUF_Pet)

	for i = 1, 5 do
		UF:RefreshUFAuras(_G["oUF_Boss"..i])
		UF:RefreshUFAuras(_G["oUF_Arena"..i])
	end
end

function UF:ToggleUFAuras(frame, enable)
	if not frame then return end
	if enable then
		if not frame:IsElementEnabled("Auras") then
			frame:EnableElement("Auras")
		end
	else
		if frame:IsElementEnabled("Auras") then
			frame:DisableElement("Auras")
			frame.Auras:ForceUpdate()
		end
	end
end

function UF:ToggleAllAuras()
	local enable = C.db["UFs"]["ShowAuras"]
	UF:ToggleUFAuras(_G.oUF_Player, enable)
	UF:ToggleUFAuras(_G.oUF_Target, enable)
	UF:ToggleUFAuras(_G.oUF_Focus, enable)
	UF:ToggleUFAuras(_G.oUF_ToT, enable)
end

UF.AuraDirections = {
	[1] = {name = L["RIGHT_DOWN"], initialAnchor = "TOPLEFT", relAnchor = "BOTTOMLEFT", x = 0, y = -1, growthX = "RIGHT", growthY = "DOWN"},
	[2] = {name = L["RIGHT_UP"], initialAnchor = "BOTTOMLEFT", relAnchor = "TOPLEFT", x = 0, y = 1, growthX = "RIGHT", growthY = "UP"},
	[3] = {name = L["LEFT_DOWN"], initialAnchor = "TOPRIGHT", relAnchor = "BOTTOMRIGHT", x = 0, y = -1, growthX = "LEFT", growthY = "DOWN"},
	[4] = {name = L["LEFT_UP"], initialAnchor = "BOTTOMRIGHT", relAnchor = "TOPRIGHT", x = 0, y = 1, growthX = "LEFT", growthY = "UP"},
}

function UF:UpdateAuraDirection(self, element)
	local direc = C.db["UFs"][element.__value.."AuraDirec"]
	local value = UF.AuraDirections[direc]
	element.initialAnchor = value.initialAnchor
	element["growth-x"] = value.growthX
	element["growth-y"] = value.growthY
	element:ClearAllPoints()
	element:SetPoint(value.initialAnchor, self, value.relAnchor, value.x, value.y * DB.margin*2)
end

local auraUFs = {
	["player"] = "Player",
	["target"] = "Target",
	["tot"] = "ToT",
	["pet"] = "Pet",
	["focus"] = "Focus",
}
function UF:CreateAuras(self)
	local mystyle = self.mystyle

	local bu = CreateFrame("Frame", nil, self)
	bu:SetFrameLevel(self:GetFrameLevel())
	bu.gap = true
	bu.initialAnchor = "TOPLEFT"
	bu["growth-y"] = "DOWN"
	bu.spacing = DB.margin
	bu.tooltipAnchor = "ANCHOR_BOTTOMLEFT"
	if auraUFs[mystyle] then
		bu.__value = auraUFs[mystyle]
		UF:ConfigureAuras(bu, "Auras")
		UF:UpdateAuraDirection(self, bu)
		bu.FilterAura = UF.UnitCustomFilter
	elseif mystyle == "nameplate" then
		bu.initialAnchor = "BOTTOMLEFT"
		bu["growth-y"] = "UP"
		if C.db["Nameplate"]["TargetPower"] then
			bu:SetPoint("BOTTOMLEFT", self.nameText, "TOPLEFT", 0, DB.margin*2 + C.db["Nameplate"]["PPBarHeight"])
		else
			bu:SetPoint("BOTTOMLEFT", self.nameText, "TOPLEFT", 0, DB.margin)
		end
		bu.numTotal = C.db["Nameplate"]["maxAuras"]
		bu.iconsPerRow = C.db["Nameplate"]["perRow"]
		bu.showDebuffType = true
		bu.desaturateDebuff = true
		bu.showStealableBuffs = true
		bu.gap = false
		bu.disableMouse = true
		bu.disableCooldown = true
		bu.FilterAura = UF.CustomFilter
		if C.db["Nameplate"]["ColorByDot"] then
			bu.PostUpdateInfo = UF.AurasPostUpdateInfo
		end
	end

	UF:UpdateAuraContainer(self, bu, bu.numTotal or bu.numBuffs + bu.numDebuffs)
	bu.PostCreateButton = UF.PostCreateButton
	bu.PostUpdateButton = UF.PostUpdateButton
	bu.PostUpdateGapButton = UF.PostUpdateGapButton

	self.Auras = bu
end

function UF:CreateBuffs(self)
	local bu = CreateFrame("Frame", nil, self)
	bu:SetFrameLevel(self:GetFrameLevel())
	bu:SetPoint("BOTTOMLEFT", self.AlternativePower, "TOPLEFT", 0, DB.margin)
	bu.spacing = DB.margin
	bu.tooltipAnchor = "ANCHOR_TOPLEFT"
	bu.initialAnchor = "BOTTOMLEFT"
	bu["growth-x"] = "RIGHT"
	bu["growth-y"] = "UP"

	bu.__value = "Boss"
	UF:ConfigureAuras(bu, "Buff")
	UF:UpdateAuraContainer(self, bu, bu.num)

	bu.FilterAura = UF.UnitCustomFilter
	bu.PostCreateButton = UF.PostCreateButton
	bu.PostUpdateButton = UF.PostUpdateButton

	self.Buffs = bu
end

function UF:CreateDebuffs(self)
	local bu = CreateFrame("Frame", nil, self)
	bu:SetFrameLevel(self:GetFrameLevel())
	bu:SetPoint("TOPRIGHT", self, "TOPLEFT", -DB.margin, 0)
	bu.spacing = DB.margin
	bu.tooltipAnchor = "ANCHOR_TOPLEFT"
	bu.initialAnchor = "TOPRIGHT"
	bu["growth-x"] = "LEFT"
	bu["growth-y"] = "UP"

	bu.__value = "Boss"
	UF:ConfigureAuras(bu, "Debuff")
	UF:UpdateAuraContainer(self, bu, bu.num)

	bu.FilterAura = UF.UnitCustomFilter
	bu.PostCreateButton = UF.PostCreateButton
	bu.PostUpdateButton = UF.PostUpdateButton

	self.Debuffs = bu
end

-- Class Powers
function UF.PostUpdateClassPower(element, cur, max, diff, powerType, chargedPowerPoints)
	if not cur or cur == 0 then
		for i = 1, 7 do
			element[i].bg:Hide()
		end

		element.prevColor = nil
	else
		for i = 1, max do
			element[i].bg:Show()
		end

		element.thisColor = cur == max and 1 or 2
		if not element.prevColor or element.prevColor ~= element.thisColor then
			local r, g, b = 1, 0, 0
			if element.thisColor == 2 then
				local color = element.__owner.colors.power[powerType]
				r, g, b = color[1], color[2], color[3]
			end
			for i = 1, #element do
				element[i]:SetStatusBarColor(r, g, b)
			end
			element.prevColor = element.thisColor
		end
	end

	if diff then
		for i = 1, max do
			element[i]:SetWidth((element.__owner.ClassPowerBar:GetWidth() - (max-1)*DB.margin)/max)
		end
		for i = max + 1, 7 do
			element[i].bg:Hide()
		end
	end

	for i = 1, 7 do
		local bar = element[i]
		if not bar.chargeStar then break end

		bar.chargeStar:SetShown(chargedPowerPoints and tContains(chargedPowerPoints, i))
	end
end

function UF:OnUpdateRunes(elapsed)
	local duration = self.duration + elapsed
	self.duration = duration
	self:SetValue(duration)
	self.timer:SetText("")

	local remain = self.runeDuration - duration
	if remain > 0 then
		self.timer:SetText(B.FormatTime(remain))
	end
end

function UF.PostUpdateRunes(element, runemap)
	for index, runeID in pairs(runemap) do
		local rune = element[index]
		local start, duration, runeReady = GetRuneCooldown(runeID)
		if rune:IsShown() then
			if runeReady then
				rune:SetAlpha(1)
				rune:SetScript("OnUpdate", nil)
				rune.timer:SetText("")
			elseif start then
				rune:SetAlpha(.6)
				rune.runeDuration = duration
				rune:SetScript("OnUpdate", UF.OnUpdateRunes)
			end
		end
	end
end

function UF:CreateClassPower(self)
	local barWidth, barHeight = C.db["UFs"]["PlayerWidth"], C.db["UFs"]["PlayerPowerHeight"]
	local barPoint = {"BOTTOMLEFT", self, "TOPLEFT", 0, DB.margin}
	if self.mystyle == "playerplate" then
		barWidth, barHeight = C.db["Nameplate"]["PPWidth"], C.db["Nameplate"]["PPBarHeight"]
		barPoint = {"BOTTOMLEFT", self, "TOPLEFT", 0, DB.margin}
	elseif self.mystyle == "targetplate" then
		barWidth, barHeight = C.db["Nameplate"]["PlateWidth"], C.db["Nameplate"]["PPBarHeight"]
		barPoint = {"CENTER", self}
	end

	local isDK = DB.MyClass == "DEATHKNIGHT"
	local maxBar = isDK and 6 or 7
	local bar = CreateFrame("Frame", nil, self.Health)
	bar:SetFrameLevel(self:GetFrameLevel() - 1)
	bar:SetSize(barWidth, barHeight)
	bar:SetPoint(unpack(barPoint))

	local bars = {}
	for i = 1, maxBar do
		bars[i] = B.CreateSB(bar, nil, true)
		bars[i]:SetHeight(barHeight)
		bars[i]:SetWidth((barWidth - (maxBar-1)*DB.margin) / maxBar)
		if i == 1 then
			bars[i]:SetPoint("BOTTOMLEFT")
		else
			bars[i]:SetPoint("LEFT", bars[i-1], "RIGHT", DB.margin, 0)
		end

		if isDK then
			bars[i].timer = B.CreateFS(bars[i], 12)
		else
			local chargeStar = bar:CreateTexture(nil, "OVERLAY")
			chargeStar:SetAtlas(DB.starTex)
			chargeStar:SetSize(14, 14)
			chargeStar:SetPoint("CENTER", bars[i])
			chargeStar:Hide()
			bars[i].chargeStar = chargeStar
		end
	end

	if isDK then
		bars.colorSpec = true
		bars.sortOrder = "asc"
		bars.PostUpdate = UF.PostUpdateRunes
		bars.__max = 6
		self.Runes = bars
	else
		bars.PostUpdate = UF.PostUpdateClassPower
		self.ClassPower = bars
	end

	self.ClassPowerBar = bar
end

function UF:StaggerBar(self)
	if DB.MyClass ~= "MONK" then return end

	local barPoint = {"BOTTOM", self, "TOP", 0, DB.margin}
	local barWidth, barHeight = C.db["UFs"]["PlayerWidth"], C.db["UFs"]["PlayerPowerHeight"]
	if self.mystyle == "playerplate" then
		barWidth, barHeight = C.db["Nameplate"]["PPWidth"], C.db["Nameplate"]["PPBarHeight"]
	end

	local bar = B.CreateSB(self.Health, nil, true)
	bar:SetSize(barWidth, barHeight)
	bar:SetPoint(unpack(barPoint))

	local text = B.CreateFS(bar, 14)
	self:Tag(text, "[stagger]")

	B.SmoothBar(bar)

	self.Stagger = bar
end

function UF:ToggleUFClassPower()
	local playerFrame = _G.oUF_Player
	if not playerFrame then return end

	if C.db["UFs"]["ClassPower"] then
		if playerFrame.ClassPower then
			if not playerFrame:IsElementEnabled("ClassPower") then
				playerFrame:EnableElement("ClassPower")
				playerFrame.ClassPower:ForceUpdate()
			end
		end
		if playerFrame.Runes then
			if not playerFrame:IsElementEnabled("Runes") then
				playerFrame:EnableElement("Runes")
				playerFrame.Runes:ForceUpdate()
			end
		end
		if playerFrame.Stagger then
			if not playerFrame:IsElementEnabled("Stagger") then
				playerFrame:EnableElement("Stagger")
				playerFrame.Stagger:ForceUpdate()
			end
		end
	else
		if playerFrame.ClassPower then
			if playerFrame:IsElementEnabled("ClassPower") then
				playerFrame:DisableElement("ClassPower")
			end
		end
		if playerFrame.Runes then
			if playerFrame:IsElementEnabled("Runes") then
				playerFrame:DisableElement("Runes")
			end
		end
		if playerFrame.Stagger then
			if playerFrame:IsElementEnabled("Stagger") then
				playerFrame:DisableElement("Stagger")
			end
		end
	end
end

function UF:UpdateUFClassPower()
	local playerFrame = _G.oUF_Player
	if not playerFrame then return end

	local barWidth, barHeight = C.db["UFs"]["PlayerWidth"], C.db["UFs"]["PlayerPowerHeight"]
	local bars = playerFrame.ClassPower or playerFrame.Runes
	if bars then
		local bar = playerFrame.ClassPowerBar
		bar:SetSize(barWidth, barHeight)
		bar:SetPoint("BOTTOMLEFT", playerFrame, "TOPLEFT", 0, DB.margin)
		local max = bars.__max
		for i = 1, max do
			bars[i]:SetHeight(barHeight)
			bars[i]:SetWidth((barWidth - (max-1)*DB.margin) / max)
		end
	end

	if playerFrame.Stagger then
		playerFrame.Stagger:SetSize(barWidth, barHeight)
	end
end

function UF.PostUpdateAltPower(element, _, cur, _, max)
	if cur and max then
		element:SetStatusBarColor(B.SmoothColor(cur, max))
	end
end

function UF:CreateAltPower(self)
	local bar = B.CreateSB(self)
	bar:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, DB.margin)
	bar:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, DB.margin)
	bar:SetHeight(DB.margin*2)

	local text = B.CreateFS(bar, 14)
	self:Tag(text, "[altpower]")

	B.SmoothBar(bar)

	self.AlternativePower = bar
	self.AlternativePower.PostUpdate = UF.PostUpdateAltPower
end

function UF.PostUpdateAddPower(element, cur, max)
	if element.Text and max > 0 then
		local perc = cur/max * 100
		element:SetAlpha((perc < 100) and 1 or 0)
		element.Text:SetText(B.ColorPerc(perc, true))
	end
end

function UF:CreateAddPower(self)
	local bar = B.CreateSB(self, nil, true)
	bar:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, DB.margin)
	bar:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, DB.margin)
	bar:SetHeight(DB.margin*2)
	bar.colorPower = true

	local text = B.CreateFS(bar, 12)

	B.SmoothBar(bar)

	self.AdditionalPower = bar
	self.AdditionalPower.Text = text
	self.AdditionalPower.PostUpdate = UF.PostUpdateAddPower
	self.AdditionalPower.displayPairs = {
		["DRUID"] = {
			[1] = true,
			[3] = true,
			[8] = true,
		},
		["SHAMAN"] = {
			[11] = true,
		},
		["PRIEST"] = {
			[13] = true,
		}
	}
end

function UF:CreateExpRepBar(self)
	local bar = B.CreateSB(self, nil, nil, "NDuiExpRepBar")
	bar:SetPoint("TOPRIGHT", self, "TOPLEFT", -DB.margin, 0)
	bar:SetPoint("BOTTOMRIGHT", self, "BOTTOMLEFT", -DB.margin, 0)
	bar:SetWidth(DB.margin*2)
	bar:SetOrientation("VERTICAL")

	local rest = CreateFrame("StatusBar", nil, bar)
	rest:SetAllPoints()
	rest:SetStatusBarTexture(DB.normTex)
	rest:SetStatusBarColor(0, .5, 1, .5)
	rest:SetFrameLevel(bar:GetFrameLevel() - 1)
	rest:SetOrientation("VERTICAL")
	bar.restBar = rest

	B:GetModule("Misc"):SetupScript(bar)
end

function UF:PostUpdatePrediction(_, health, maxHealth, allIncomingHeal, allAbsorb)
	if not C.db["UFs"]["OverAbsorb"] then
		self.overAbsorbBar:Hide()
		return
	end

	local hasOverAbsorb
	local overAbsorbAmount = health + allIncomingHeal + allAbsorb - maxHealth
	if overAbsorbAmount > 0 then
		if overAbsorbAmount > maxHealth then
			hasOverAbsorb = true
			overAbsorbAmount = maxHealth
		end
		self.overAbsorbBar:SetMinMaxValues(0, maxHealth)
		self.overAbsorbBar:SetValue(overAbsorbAmount)
		self.overAbsorbBar:Show()
	else
		self.overAbsorbBar:Hide()
	end

	if hasOverAbsorb then
		self.overAbsorb:Show()
	else
		self.overAbsorb:Hide()
	end
end

function UF:CreatePrediction(self)
	local health = self.Health

	local myBar = CreateFrame("StatusBar", nil, health)
	myBar:SetPoint("TOP")
	myBar:SetPoint("BOTTOM")
	myBar:SetPoint("LEFT", health:GetStatusBarTexture(), "RIGHT")
	myBar:SetStatusBarTexture(DB.bdTex)
	myBar:SetStatusBarColor(0, 1, 0, .75)
	myBar:Hide()

	local otherBar = CreateFrame("StatusBar", nil, health)
	otherBar:SetPoint("TOP")
	otherBar:SetPoint("BOTTOM")
	otherBar:SetPoint("LEFT", myBar:GetStatusBarTexture(), "RIGHT")
	otherBar:SetStatusBarTexture(DB.bdTex)
	otherBar:SetStatusBarColor(1, 1, 0, .75)
	otherBar:Hide()

	local absorbBar = CreateFrame("StatusBar", nil, health)
	absorbBar:SetPoint("TOP")
	absorbBar:SetPoint("BOTTOM")
	absorbBar:SetPoint("LEFT", otherBar:GetStatusBarTexture(), "RIGHT")
	absorbBar:SetStatusBarTexture(DB.bdTex)
	absorbBar:SetStatusBarColor(0, 1, 1, .75)
	absorbBar:Hide()

	local overAbsorbBar = CreateFrame("StatusBar", nil, health)
	overAbsorbBar:SetAllPoints()
	overAbsorbBar:SetStatusBarTexture(DB.bdTex)
	overAbsorbBar:SetStatusBarColor(0, 1, 1, .75)
	overAbsorbBar:Hide()

	local healAbsorbBar = CreateFrame("StatusBar", nil, health)
	healAbsorbBar:SetPoint("TOP")
	healAbsorbBar:SetPoint("BOTTOM")
	healAbsorbBar:SetPoint("RIGHT", health:GetStatusBarTexture(), "RIGHT")
	healAbsorbBar:SetReverseFill(true)
	healAbsorbBar:SetStatusBarTexture(DB.bdTex)
	healAbsorbBar:SetStatusBarColor(1, 0, 1, .75)
	healAbsorbBar:Hide()

	local overAbsorb = health:CreateTexture(nil, "OVERLAY")
	overAbsorb:SetWidth(10)
	overAbsorb:SetTexture("Interface\\RaidFrame\\Shield-Overshield")
	overAbsorb:SetBlendMode("ADD")
	overAbsorb:SetPoint("TOP", health, "TOPRIGHT", 2, 2)
	overAbsorb:SetPoint("BOTTOM", health, "BOTTOMRIGHT", 2, -2)
	overAbsorb:Hide()

	local overHealAbsorb = health:CreateTexture(nil, "OVERLAY")
	overHealAbsorb:SetWidth(10)
	overHealAbsorb:SetTexture("Interface\\RaidFrame\\Absorb-Overabsorb")
	overHealAbsorb:SetBlendMode("ADD")
	overHealAbsorb:SetPoint("TOP", health, "TOPLEFT", -2, 2)
	overHealAbsorb:SetPoint("BOTTOM", health, "BOTTOMLEFT", -2, -2)
	overHealAbsorb:Hide()

	-- Register with oUF
	self.HealthPrediction = {
		myBar = myBar,
		otherBar = otherBar,
		absorbBar = absorbBar,
		healAbsorbBar = healAbsorbBar,
		overAbsorbBar = overAbsorbBar,
		overAbsorb = overAbsorb,
		overHealAbsorb = overHealAbsorb,
		maxOverflow = 1,
		PostUpdate = UF.PostUpdatePrediction,
	}
	self.predicFrame = frame
end

function UF:ToggleAddPower()
	local frame = _G.oUF_Player
	if not frame then return end

	if C.db["UFs"]["AddPower"] then
		if not frame:IsElementEnabled("AdditionalPower") then
			frame:EnableElement("AdditionalPower")
			frame.AdditionalPower:ForceUpdate()
		end
	elseif frame:IsElementEnabled("AdditionalPower") then
		frame:DisableElement("AdditionalPower")
	end
end

function UF:ToggleSwingBars()
	local frame = _G.oUF_Player
	if not frame then return end

	if C.db["UFs"]["SwingBar"] then
		if not frame:IsElementEnabled("Swing") then
			frame:EnableElement("Swing")
		end
	elseif frame:IsElementEnabled("Swing") then
		frame:DisableElement("Swing")
	end
end

function UF:CreateSwing(self)
	local width, height = C.db["UFs"]["SwingWidth"], C.db["UFs"]["SwingHeight"]

	local bar = CreateFrame("Frame", nil, self)
	bar:SetFrameLevel(self:GetFrameLevel())
	bar:SetSize(width, height)

	bar.mover = B.Mover(bar, L["UFs SwingBar"], "Swing", {"TOP", self.Castbar.mover, "BOTTOM", 0, -DB.margin*2})
	bar:ClearAllPoints()
	bar:SetPoint("CENTER", bar.mover, "CENTER")

	local two = B.CreateSB(bar, true)
	two:SetAllPoints()
	two:Hide()

	local main = B.CreateSB(bar, true)
	main:SetAllPoints()
	main:Hide()

	local off = B.CreateSB(bar, true)
	off:SetSize(width, height)
	off:Hide()

	if C.db["UFs"]["OffOnTop"] then
		B.UpdatePoint(off, "BOTTOM", bar, "TOP", 0, DB.margin)
	else
		B.UpdatePoint(off, "TOP", bar, "BOTTOM", 0, -DB.margin)
	end

	bar.Text = B.CreateFS(bar, 12)
	bar.Text:SetShown(C.db["UFs"]["SwingTimer"])
	bar.TextMH = B.CreateFS(main, 12)
	bar.TextMH:SetShown(C.db["UFs"]["SwingTimer"])
	bar.TextOH = B.CreateFS(off, 12)
	bar.TextOH:SetShown(C.db["UFs"]["SwingTimer"])

	self.Swing = bar
	self.Swing.Twohand = two
	self.Swing.Mainhand = main
	self.Swing.Offhand = off
	self.Swing.hideOoc = true
end

local scrolls = {}
function UF:UpdateScrollingFont()
	local fontSize = C.db["UFs"]["FCTFontSize"]
	local frameSize = 10 * (fontSize + DB.margin) - DB.margin
	for _, scroll in pairs(scrolls) do
		B.SetFontSize(scroll, fontSize)
		scroll:SetSize(frameSize, frameSize)
	end
end

function UF:CreateFCT(self)
	if not C.db["UFs"]["CombatText"] then return end

	local fcf = CreateFrame("Frame", "$parentCombatTextFrame", UIParent)
	fcf:SetSize(32, 32)
	if self.mystyle == "player" then
		B.Mover(fcf, L["CombatText"], "PlayerCombatText", {"BOTTOM", self, "TOPLEFT", 0, 120})
	else
		B.Mover(fcf, L["CombatText"], "TargetCombatText", {"BOTTOM", self, "TOPRIGHT", 0, 120})
	end

	local scrolling = CreateFrame("ScrollingMessageFrame", "$parentCombatTextScrollingFrame", fcf)
	scrolling:SetFrameLevel(fcf:GetFrameLevel())
	scrolling:SetSpacing(DB.margin)
	scrolling:SetMaxLines(20)
	scrolling:SetFadeDuration(.2)
	scrolling:SetTimeVisible(3)
	scrolling:SetJustifyH("CENTER")
	scrolling:SetPoint("BOTTOM", fcf, "BOTTOM")
	fcf.Scrolling = scrolling
	table.insert(scrolls, scrolling)

	self.FloatingCombatFeedback = fcf

	-- Default CombatText
	SetCVar("enableFloatingCombatText", 0)
end

function UF:CreatePVPClassify(self)
	local bu = self:CreateTexture(nil, "ARTWORK")
	bu:SetSize(30, 30)
	bu:SetPoint("LEFT", self, "RIGHT", 5, -2)

	self.PvPClassificationIndicator = bu
end

local function updatePartySync(self)
	local hasJoined = C_QuestSession.HasJoined()
	if hasJoined then
		self.QuestSyncIndicator:Show()
	else
		self.QuestSyncIndicator:Hide()
	end
end

function UF:CreateQuestSync(self)
	local sync = self:CreateTexture(nil, "OVERLAY")
	sync:SetPoint("CENTER", self, "BOTTOM", 0, 0)
	sync:SetSize(28, 28)
	sync:SetAtlas("QuestSharing-DialogIcon")
	sync:Hide()

	self.QuestSyncIndicator = sync
	self:RegisterEvent("QUEST_SESSION_LEFT", updatePartySync, true)
	self:RegisterEvent("QUEST_SESSION_JOINED", updatePartySync, true)
	self:RegisterEvent("PLAYER_ENTERING_WORLD", updatePartySync, true)
end

-- Demonic Gateway
local GatewayTexs = {
	[59262] = 607512, -- green
	[59271] = 607513, -- purple
}
local function DGI_UpdateGlow()
	local frame = _G.oUF_Focus
	if not frame then return end

	local element = frame.DemonicGatewayIndicator
	if element:IsShown() and IsItemInRange(37727, "focus") then
		B.ShowOverlayGlow(element.glowFrame)
	else
		B.HideOverlayGlow(element.glowFrame)
	end
end

local function DGI_Visibility()
	local frame = _G.oUF_Focus
	if not frame then return end

	local element = frame.DemonicGatewayIndicator
	local guid = UnitGUID("focus")
	local npcID = guid and B.GetNPCID(guid)
	local isGate = npcID and GatewayTexs[npcID]

	element:SetTexture(isGate)
	element:SetShown(isGate)
	element.updater:SetShown(isGate)
	DGI_UpdateGlow()
end

local function DGI_OnUpdate(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed > .1 then
		DGI_UpdateGlow()

		self.elapsed = 0
	end
end

function UF:DemonicGatewayIcon(self)
	local icon = self:CreateTexture(nil, "ARTWORK")
	icon:SetPoint("CENTER")
	icon:SetSize(22, 22)
	icon:SetTexture(607512) -- 607513 for purple
	icon:SetTexCoord(unpack(DB.TexCoord))
	icon.glowFrame = B.CreateGlowFrame(self)

	local updater = CreateFrame("Frame")
	updater:SetScript("OnUpdate", DGI_OnUpdate)
	updater:Hide()

	self.DemonicGatewayIndicator = icon
	self.DemonicGatewayIndicator.updater = updater
	B:RegisterEvent("PLAYER_FOCUS_CHANGED", DGI_Visibility)
end