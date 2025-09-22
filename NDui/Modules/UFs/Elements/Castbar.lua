local _, ns = ...
local B, C, L, DB = unpack(ns)
local UF = B:GetModule("UnitFrames")

local CastbarCompleteColor = {0, 1, 0}
local CastbarFailColor = {1, 0, 0}

local channelingTicks = {
	[740] = 4, -- 宁静
	[755] = 5, -- 生命通道
	[5143] = 4, -- 奥术飞弹
	[12051] = 6, -- 唤醒
	[15407] = 6, -- 精神鞭笞
	[47757] = 3, -- 苦修
	[47758] = 3, -- 苦修
	[48045] = 6, -- 精神灼烧
	[64843] = 4, -- 神圣赞美诗
	[120360] = 15, -- 弹幕射击
	[198013] = 10, -- 眼棱
	[198590] = 5, -- 吸取灵魂
	[205021] = 5, -- 冰霜射线
	[205065] = 6, -- 虚空洪流
	[206931] = 3, -- 饮血者
	[212084] = 10, -- 邪能毁灭
	[234153] = 5, -- 吸取生命
	[257044] = 7, -- 急速射击
	[291944] = 6, -- 再生，赞达拉巨魔
	[314791] = 4, -- 变易幻能
	[324631] = 8, -- 血肉铸造，盟约
	[356995] = 3, -- 裂解，龙希尔
}

if DB.MyClass == "PRIEST" then
	local function updateTicks()
		local numTicks = 3
		if C_SpellBook.IsSpellKnown(193134) then numTicks = 4 end
		channelingTicks[47757] = numTicks
		channelingTicks[47758] = numTicks
	end
	B:RegisterEvent("PLAYER_LOGIN", updateTicks)
	B:RegisterEvent("PLAYER_TALENT_UPDATE", updateTicks)
end

function UF:OnCastbarUpdate(elapsed)
	if self.casting or self.channeling or self.empowering then
		local isCasting = self.casting or self.empowering
		local decimal = self.decimal

		local duration = isCasting and (self.duration + elapsed) or (self.duration - elapsed)
		if (isCasting and duration >= self.max) or (self.channeling and duration <= 0) then
			self.casting = nil
			self.channeling = nil
			self.empowering = nil
			return
		end

		if self.__owner.unit == "player" then
			if self.delay ~= 0 then
				self.Time:SetFormattedText(decimal..DB.Separator..decimal, duration, self.casting and self.max + self.delay or self.max - self.delay)
			else
				self.Time:SetFormattedText(decimal..DB.Separator..decimal, duration, self.max)
			end
		else
			if duration > 1e4 then
				self.Time:SetText("∞"..DB.Separator.."∞")
			else
				self.Time:SetFormattedText(decimal..DB.Separator..decimal, duration, self.casting and self.max + self.delay or self.max - self.delay)
			end
		end
		self.duration = duration
		self:SetValue(duration)
		self.Spark:SetPoint("TOP", self:GetStatusBarTexture(), "TOPRIGHT", 0, 15)
		self.Spark:SetPoint("BOTTOM", self:GetStatusBarTexture(), "BOTTOMRIGHT", 0, -15)
	elseif self.holdTime > 0 then
		self.holdTime = self.holdTime - elapsed
	else
		self.Spark:Hide()
		local alpha = self:GetAlpha() - .02
		if alpha > 0 then
			self:SetAlpha(alpha)
		else
			self.fadeOut = nil
			self:Hide()
		end
	end
end

function UF:OnCastSent()
	local element = self.Castbar
	if not element.SafeZone then return end
	element.__sendTime = GetTime()
end

local function ResetSpellTarget(self)
	if self.spellTarget then
		self.spellTarget:SetText("")
	end
end

local function UpdateSpellTarget(self, unit)
	if not self.spellTarget then return end

	local unitTarget = unit and unit.."target"
	if unitTarget and UnitExists(unitTarget) then
		self.spellTarget:SetText(B.GetUnitTarget(unitTarget))
	else
		ResetSpellTarget(self) -- when unit loses target
	end
end

local function UpdateCastBarColor(self, unit)
	local color = C.db["UFs"]["CastingColor"]
	if unit == "player" then
		color = DB.ClassColors[DB.MyClass]
	elseif not UnitIsUnit(unit, "player") and self.notInterruptible then
		color = C.db["UFs"]["NotInterruptColor"]
	end
	self:SetStatusBarColor(color.r, color.g, color.b)
end

function UF:PostCastStart(unit)
	self:SetAlpha(1)
	self.Spark:Show()

	local safeZone = self.SafeZone

	if unit == "vehicle" or UnitInVehicle("player") then
		if safeZone then
			safeZone:Hide()
		end
	elseif unit == "player" then
		if safeZone then
			local sendTime = self.__sendTime
			local timeDiff = sendTime and math.min((GetTime() - sendTime), self.max)
			if timeDiff and timeDiff ~= 0 then
				safeZone:SetWidth(self:GetWidth() * timeDiff / self.max)
				safeZone:Show()
			else
				safeZone:Hide()
			end
			self.__sendTime = nil
		end

		local numTicks = 0
		if self.channeling then
			numTicks = channelingTicks[self.spellID] or 0
		end
		B:CreateAndUpdateBarTicks(self, self.castTicks, numTicks)
	end

	UpdateCastBarColor(self, unit)

	if self.__owner.mystyle == "nameplate" then
		-- Major spells
		if C.db["Nameplate"]["CastbarGlow"] and UF.MajorSpells[self.spellID] then
			B.ShowOverlayGlow(self.glowFrame)
		else
			B.HideOverlayGlow(self.glowFrame)
		end

		-- Spell target
		UpdateSpellTarget(self, unit)
	end
end

function UF:PostCastUpdate(unit)
	UpdateSpellTarget(self, unit)
end

function UF:PostUpdateInterruptible(unit)
	UpdateCastBarColor(self, unit)
end

function UF:PostCastStop()
	if not self.fadeOut then
		self:SetStatusBarColor(unpack(CastbarCompleteColor))
		self.fadeOut = true
	end
	self:Show()
	ResetSpellTarget(self)
end

function UF:PostCastFailed()
	self:SetStatusBarColor(unpack(CastbarFailColor))
	self:SetValue(self.max)
	self.fadeOut = true
	self:Show()
	ResetSpellTarget(self)
end

UF.PipColors = {
	[1] = {  0,   1,  0, .25},
	[2] = {.25, .75,  0, .25},
	[3] = {.50, .50,  0, .25},
	[4] = {.75, .25,  0, .25},
	[5] = {  1,   0,  0, .25},
}
function UF:CreatePip(stage)
	local _, height = self:GetSize()

	local pip = CreateFrame("Frame", nil, self, "CastingBarFrameStagePipTemplate")
	pip:SetFrameLevel(self:GetFrameLevel())
	pip.BasePip:SetColorTexture(0, 0, 0)
	pip.BasePip:SetWidth(C.mult)
	pip.BasePip:SetHeight(height)

	pip.tex = pip:CreateTexture(nil, "ARTWORK")
	pip.tex:SetTexture(DB.normTex)
	pip.tex:SetVertexColor(unpack(UF.PipColors[stage]))

	return pip
end

function UF:PostUpdatePips(numStages)
	local pips = self.Pips
	local numStages = self.numStages

	for stage = 1, numStages do
		local pip = pips[stage]
		pip.tex:SetAlpha(.25) -- reset pip alpha
		pip.duration = self.stagePoints[stage]

		if stage == numStages then
			local firstPip = pips[1]
			local anchor = pips[numStages]
			firstPip.tex:SetPoint("BOTTOMRIGHT", self)
			firstPip.tex:SetPoint("TOPLEFT", anchor.BasePip, "TOPRIGHT")
		end

		if stage ~= 1 then
			local anchor = pips[stage-1]
			pip.tex:SetPoint("BOTTOMRIGHT", pip.BasePip, "BOTTOMLEFT")
			pip.tex:SetPoint("TOPLEFT", anchor.BasePip, "TOPRIGHT")
		end
	end
end