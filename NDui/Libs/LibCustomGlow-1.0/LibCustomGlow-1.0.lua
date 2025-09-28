
-- LibCustomGlow-Next.lua
-- Rewritten, simplified, and behavior-compatible implementation of glow effects
-- Supports: Pixel Glow, Auto Cast Glow, Action Button Glow, Proc Glow
-- API: lib.ShowOverlayGlow(button), lib.HideOverlayGlow(button)
-- Keeps Masque support and NDui GlowMode selection

local MAJOR_VERSION = "LibCustomGlow-1.0-NDui"
local MINOR_VERSION = 1
if not LibStub then error(MAJOR_VERSION .. " requires LibStub.") end

local lib, old = LibStub:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
if not lib then return end

local Masque = LibStub("Masque", true)
local fallbackLevel = 0

local shineCoords = {0.8115234375, 0.9169921875, 0.8798828125, 0.9853515625}
local textureList = {
	empty = "Interface\\AdventureMap\\BrokenIsles\\AM_29",
	white = "Interface\\BUTTONS\\WHITE8X8",
	shine = "Interface\\Artifacts\\Artifacts",
}

lib.glowList = {}
lib.startList = {}
lib.stopList = {}

local function ApplyDefaults(opts, defaults)
	return setmetatable(opts or {}, { __index = defaults })
end

local function RegisterGlow(name, startFunc, stopFunc)
	table.insert(lib.glowList, name)
	lib.startList[name] = startFunc
	lib.stopList[name] = stopFunc
end

local PixelDefaults = {
	frameLevel = fallbackLevel,
	num = 8,
	color = {1, 1, 0, 1},
	period = 4,
	thickness = 1,
	xOffset = 0,
	yOffset = 0,
}

local AutoCastDefaults = {
	frameLevel = fallbackLevel,
	num = 4,
	color = {1, 1, 0, 1},
	period = 4,
	scale = 1,
	xOffset = 0,
	yOffset = 0,
}

local ActionButtonDefaults = {
	frameLevel = fallbackLevel,
	xOffset = 0,
	yOffset = 0,
}

local ProcDefaults = {
	frameLevel = fallbackLevel,
	xOffset = 0,
	yOffset = 0,
}

local GlowTexPool = CreateTexturePool(UIParent, "OVERLAY")
local GlowFramePool = CreateFramePool("Frame", UIParent)

local function ApplyColor(target, color)
	if not target then return end

	local function apply(obj)
		if not obj then return end
		if color then
			pcall(obj.SetDesaturated, obj, true)
			pcall(obj.SetVertexColor, obj, color[1], color[2], color[3], color[4] or 1)
		else
			pcall(obj.SetDesaturated, obj, false)
			pcall(obj.SetVertexColor, obj, 1, 1, 1, 1)
		end
	end

	if type(target) == "table" and getmetatable(target) == nil then
		for _, v in pairs(target) do
			apply(v)
		end
	else
		apply(target)
	end
end

local function GetOrCreateFrame(button, name, xOffset, yOffset)
	local f
	if button[name] then
		f = button[name]
	else
		f = GlowFramePool:Acquire()
		button[name] = f
	end

	f:SetParent(button)
	f:SetFrameLevel(button:GetFrameLevel())

	f:ClearAllPoints()
	f:SetPoint("TOPLEFT", button, "TOPLEFT", -xOffset, yOffset)
	f:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", xOffset, -yOffset)
	f:Show()

	return f
end

-- -----------------------
-- Pixel Glow (edge moving)
-- -----------------------
local function pCalc1(progress, length, thickness, point)
	local coord
	if progress > point[3] or progress < point[0] then
		coord = 0
	elseif progress > point[2] then
		coord = length - thickness - (progress - point[2]) / (point[3] - point[2]) * (length - thickness)
	elseif progress > point[1] then
		coord = length - thickness
	else
		coord = (progress - point[0]) / (point[1] - point[0]) * (length - thickness)
	end

	return math.floor(coord + 0.5)
end

local function pCalc2(progress, length, thickness, point)
	local coord
	if progress > point[3] then
		coord = length - thickness - (progress - point[3]) / (point[0] + 1 - point[3]) * (length - thickness)
	elseif progress > point[2] then
		coord = length - thickness
	elseif progress > point[1] then
		coord = (progress - point[1]) / (point[2] - point[1]) * (length - thickness)
	elseif progress > point[0] then
		coord = 0
	else
		coord = length - thickness - (progress + 1 - point[3]) / (point[0] + 1 - point[3]) * (length - thickness)
	end

	return math.floor(coord + 0.5)
end

local function pUpdate(self, elapsed)
	self.timer = (self.timer or 0) + elapsed / self.info.period
	if self.timer > 1 or self.timer < -1 then
		self.timer = self.timer % 1
	end

	local progress = self.timer
	local width, height = self:GetSize()
	if width ~= self.info.width or height ~= self.info.height then
		local perimeter = 2 * (width + height)
		if not (perimeter > 0) then return end
		self.info.width = width
		self.info.height = height
		self.info.pTLx = {
			[0] = (height + self.info.length / 2) / perimeter,
			[1] = (height + width + self.info.length / 2) / perimeter,
			[2] = (2 * height + width - self.info.length / 2) / perimeter,
			[3] = 1 - self.info.length / 2 / perimeter
		}
		self.info.pTLy = {
			[0] = (height - self.info.length / 2) / perimeter,
			[1] = (height + width + self.info.length / 2) / perimeter,
			[2] = (height * 2 + width + self.info.length / 2) / perimeter,
			[3] = 1 - self.info.length / 2 / perimeter
		}
		self.info.pBRx = {
			[0] = self.info.length / 2 / perimeter,
			[1] = (height - self.info.length / 2) / perimeter,
			[2] = (height + width - self.info.length / 2) / perimeter,
			[3] = (height * 2 + width + self.info.length / 2) / perimeter
		}
		self.info.pBRy = {
			[0] = self.info.length / 2 / perimeter,
			[1] = (height + self.info.length / 2) / perimeter,
			[2] = (height + width - self.info.length / 2) / perimeter,
			[3] = (height * 2 + width - self.info.length / 2) / perimeter
		}
	end

	if self:IsShown() then
		if self.masks and self.masks[1] and not self.masks[1]:IsShown() then
			self.masks[1]:Show()
			self.masks[1]:ClearAllPoints()
			self.masks[1]:SetPoint("TOPLEFT", self, "TOPLEFT", self.info.thickness, -self.info.thickness)
			self.masks[1]:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -self.info.thickness, self.info.thickness)
		end

		for k, line in pairs(self.textures) do
			line:ClearAllPoints()
			line:SetPoint("TOPLEFT", self, "TOPLEFT", pCalc1((progress + self.info.step * (k - 1)) % 1, width, self.info.thickness, self.info.pTLx), -pCalc2((progress + self.info.step * (k - 1)) % 1, height, self.info.thickness, self.info.pTLy))
			line:SetPoint("BOTTOMRIGHT", self, "TOPLEFT", self.info.thickness + pCalc2((progress + self.info.step * (k - 1)) % 1, width, self.info.thickness, self.info.pBRx), -height + pCalc1((progress + self.info.step * (k - 1)) % 1, height, self.info.thickness, self.info.pBRy))
		end
	end
end

function lib.PixelGlow_Start(button, options)
	if not button then return end
	options = ApplyDefaults(options, PixelDefaults)

	local name = "_PixelGlow"
	local f = GetOrCreateFrame(button, name, options.xOffset, options.yOffset)
	local w, h = button:GetSize()

	f.info = f.info or {}
	f.masks = f.masks or {}
	f.textures = f.textures or {}
	f.timer = f.timer or 0

	f.info.step = 1 / options.num
	f.info.period = options.period
	f.info.thickness = options.thickness
	f.info.length = math.min(math.floor((w + h) * (2 / options.num - 0.1)), math.min(w, h))

	if not f.masks[1] then
		f.masks[1] = f:CreateMaskTexture()
		f.masks[1]:SetTexture(textureList.empty, "CLAMPTOWHITE", "CLAMPTOWHITE")
		f.masks[1]:Show()
	end
	f.masks[1]:ClearAllPoints()
	f.masks[1]:SetPoint("TOPLEFT", f, "TOPLEFT", options.thickness, -options.thickness)
	f.masks[1]:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -options.thickness, options.thickness)

	for i = 1, options.num do
		if not f.textures[i] then
			f.textures[i] = GlowTexPool:Acquire()
			f.textures[i]:SetTexture(textureList.white)
			f.textures[i]:SetTexCoord(0, 1, 0, 1)
			f.textures[i]:SetParent(f)
			f.textures[i]:SetDrawLayer("OVERLAY")
		end
		if f.masks[1] and f.textures[i]:GetNumMaskTextures() < 1 then
			f.textures[i]:AddMaskTexture(f.masks[1])
		end

		ApplyColor(f.textures[i], options.color)
		f.textures[i]:Show()
	end

	while #f.textures > options.num do
		local t = table.remove(f.textures)
		GlowTexPool:Release(t)
	end

	pUpdate(f, 0)
	f:SetScript("OnUpdate", pUpdate)
end

function lib.PixelGlow_Stop(button)
	local name = "_PixelGlow"
	local f = button[name]
	if not f then return end

	button[name] = nil
	GlowFramePool:Release(f)
end

-- -----------------------
-- Auto Cast Glow
-- -----------------------
local function acUpdate(self, elapsed)
	local width, height = self:GetSize()
	if width ~= self.info.width or height ~= self.info.height then
		if width * height == 0 then return end
		self.info.width = width
		self.info.height = height
		self.info.perimeter = 2 * (width + height)
		self.info.bottomlim = height * 2 + width
		self.info.rightlim = height + width
		self.info.space = self.info.perimeter / self.info.num
	end
	local texIndex = 0
	for k = 1, 4 do
		self.timer[k] = self.timer[k] + elapsed / (self.info.period * k)
		if self.timer[k] > 1 or self.timer[k] < -1 then self.timer[k] = self.timer[k] % 1 end
		for i = 1, self.info.num do
			texIndex = texIndex + 1
			local position = (self.info.space * i + self.info.perimeter * self.timer[k]) % self.info.perimeter
			if position > self.info.bottomlim then
				self.textures[texIndex]:SetPoint("CENTER", self, "BOTTOMRIGHT", -position + self.info.bottomlim, 0)
			elseif position > self.info.rightlim then
				self.textures[texIndex]:SetPoint("CENTER", self, "TOPRIGHT", 0, -position + self.info.rightlim)
			elseif position > self.info.height then
				self.textures[texIndex]:SetPoint("CENTER", self, "TOPLEFT", position - self.info.height, 0)
			else
				self.textures[texIndex]:SetPoint("CENTER", self, "BOTTOMLEFT", 0, position)
			end
		end
	end
end

function lib.AutoCastGlow_Start(button, options)
	if not button then return end
	options = ApplyDefaults(options, AutoCastDefaults)

	local name = "_AutoCastGlow"
	local f = GetOrCreateFrame(button, name, options.xOffset, options.yOffset)

	f.info = f.info or {}
	f.textures = f.textures or {}
	f.timer = f.timer or {0, 0, 0, 0}

	f.info.num = options.num
	f.info.period = options.period

	for i = 1, options.num * 4 do
		if not f.textures[i] then
			f.textures[i] = GlowTexPool:Acquire()
			f.textures[i]:SetTexture(textureList.shine)
			f.textures[i]:SetTexCoord(unpack(shineCoords))
			f.textures[i]:SetParent(f)
			f.textures[i]:SetDrawLayer("OVERLAY")
		end

		local sizes = {7, 6, 5, 4}
		local row = math.floor((i - 1) / options.num) + 1
		local size = sizes[row] or sizes[#sizes]
		ApplyColor(f.textures[i], options.color)
		f.textures[i]:SetSize(size * options.scale, size * options.scale)
		f.textures[i]:Show()
	end

	while #f.textures > options.num * 4 do
		local t = table.remove(f.textures)
		GlowTexPool:Release(t)
	end

	acUpdate(f, 0)
	f:SetScript("OnUpdate", acUpdate)
end

function lib.AutoCastGlow_Stop(button)
	local name = "_AutoCastGlow"
	local f = button[name]
	if not f then return end

	button[name] = nil
	GlowFramePool:Release(f)
end

-- -----------------------
-- Button Glow (action button sparkle)
-- -----------------------
local function AddScale(group, target, order, duration, x, y, delay)
	local scale = group:CreateAnimation("Scale")
	scale:SetChildKey(target)
	scale:SetOrder(order)
	scale:SetDuration(duration)
	scale:SetScale(x, y)
	if delay then
		scale:SetStartDelay(delay)
	end
end

local function AddAlpha(group, target, order, duration, fromA, toA, delay, appear)
	local alpha = group:CreateAnimation("Alpha")
	alpha:SetChildKey(target)
	alpha:SetOrder(order)
	alpha:SetDuration(duration)
	alpha:SetFromAlpha(fromA)
	alpha:SetToAlpha(toA)
	if delay then
		alpha:SetStartDelay(delay)
	end
	if appear then
		table.insert(group.appear, alpha)
	else
		table.insert(group.fade, alpha)
	end
end

local function AnimIn_OnPlay(group)
	local frame = group:GetParent()
	local fw, fh = frame:GetSize()
	frame.spark:SetAlpha(1)
	frame.innerGlow:SetAlpha(1)
	frame.outerGlow:SetAlpha(0)
	frame.ants:SetAlpha(0)
	frame:Show()
end

local function AnimIn_OnFinished(group)
	local frame = group:GetParent()
	local fw, fh = frame:GetSize()
	frame.spark:SetAlpha(0)
	frame.innerGlow:SetAlpha(0)
	frame.outerGlow:SetAlpha(1)
	frame.ants:SetAlpha(1)
end

local function AnimOut_OnFinished(group)
	local frame = group:GetParent()
	GlowFramePool:Release(frame)
end

local function InitButton(f)
	if not f.inited then
		f.ants = f:CreateTexture(nil, "OVERLAY", nil, 1)
		f.ants:SetPoint("CENTER", f, "CENTER")
		f.ants:SetAlpha(0)
		f.ants:SetTexture("Interface\\SpellActivationOverlay\\IconAlertAnts")

		f.spark = f:CreateTexture(nil, "BACKGROUND")
		f.spark:SetPoint("TOPLEFT", f, "TOPLEFT")
		f.spark:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT")
		f.spark:SetAlpha(0)
		f.spark:SetTexture("Interface\\SpellActivationOverlay\\IconAlert")
		f.spark:SetTexCoord(0.00781250, 0.61718750, 0.00390625, 0.26953125)

		f.innerGlow = f:CreateTexture(nil, "OVERLAY")
		f.innerGlow:SetPoint("TOPLEFT", f, "TOPLEFT")
		f.innerGlow:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT")
		f.innerGlow:SetAlpha(0)
		f.innerGlow:SetTexture("Interface\\SpellActivationOverlay\\IconAlert")
		f.innerGlow:SetTexCoord(0.00781250, 0.50781250, 0.27734375, 0.52734375)

		f.outerGlow = f:CreateTexture(nil, "OVERLAY")
		f.outerGlow:SetPoint("TOPLEFT", f, "TOPLEFT")
		f.outerGlow:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT")
		f.outerGlow:SetAlpha(0)
		f.outerGlow:SetTexture("Interface\\SpellActivationOverlay\\IconAlert")
		f.outerGlow:SetTexCoord(0.00781250, 0.50781250, 0.27734375, 0.52734375)

		f.animIn = f:CreateAnimationGroup()
		f.animIn.appear = {}
		f.animIn.fade = {}

		AddScale(f.animIn, "spark",     1, 0.2, 1.5, 1.5)
		AddAlpha(f.animIn, "spark",     1, 0.2, 0, 1, 0.2, true)
		AddScale(f.animIn, "innerGlow", 1, 0.2, 2, 2)
		AddAlpha(f.animIn, "innerGlow", 1, 0.2, 1, 0, 0.2, false)
		AddScale(f.animIn, "outerGlow", 1, 0.2, 0.5, 0.5)
		AddAlpha(f.animIn, "outerGlow", 1, 0.2, 1, 0, 0.2, false)
		AddScale(f.animIn, "spark",     1, 0.2, 1, 1)
		AddAlpha(f.animIn, "spark",     1, 0.2, 1, 0, 0.2, false)
		AddScale(f.animIn, "ants",      1, 0.2, 1, 1)
		AddAlpha(f.animIn, "ants",      1, 0.2, 0, 1, 0.2, true)

		f.animIn:SetScript("OnPlay", AnimIn_OnPlay)
		f.animIn:SetScript("OnFinished", AnimIn_OnFinished)

		f.animOut = f:CreateAnimationGroup()
		f.animOut.appear = {}
		f.animOut.fade = {}

		AddAlpha(f.animOut, "ants",      1, 0.2, 1, 0, nil, false)
		AddAlpha(f.animOut, "innerGlow", 2, 0.2, 1, 0, nil, false)
		AddAlpha(f.animOut, "outerGlow", 2, 0.2, 1, 0, nil, false)

		f.animOut:SetScript("OnFinished", AnimOut_OnFinished)

		f.inited = true
	end
end

local function SetupButton(f, options)
	f:SetScript("OnUpdate", function(self, elapsed)
		AnimateTexCoords(self.ants, 256, 256, 48, 48, 22, elapsed, 0.01)
	end)

	f:SetScript("OnHide", function(self)
		if self.animIn and self.animIn:IsPlaying() then
			self.animIn:Pause()
		end
		if self.animOut and self.animOut:IsPlaying() then
			self.animOut:Pause()
		end
	end)

	f:SetScript("OnShow", function(self)
		if self.animIn and self.animIn:IsPaused() then
			self.animIn:Play()
		end
		if self.animOut and self.animOut:IsPaused() then
			self.animOut:Play()
		end
	end)

	if Masque and Masque.UpdateSpellAlert and (not button.overlay or not issecurevariable(button, "overlay")) then
		local old_overlay = button.overlay
		button.overlay = f
		Masque:UpdateSpellAlert(button)
		button.overlay = old_overlay
	end
end

function lib.ButtonGlow_Start(button, options)
	if not button then return end
	options = ApplyDefaults(options, ActionButtonDefaults)

	local w, h = button:GetSize()
	local x = options.xOffset + w * 0.2
	local y = options.yOffset + h * 0.2

	local name, f = "_ButtonGlow"
	if button[name] then
		f = button[name]

		if f.animOut:IsPlaying() then
			f.animOut:Stop()
			f.animIn:Play()
		end
	else
		f = GlowFramePool:Acquire()
		InitButton(f)
		f:SetSize(w*1.4, h*1.4)
		f.ants:SetSize(w*1.4*0.9, h*1.4*0.9)
		f.animIn:Play()
		button[name] = f
	end

	f:SetParent(button)
	f:SetFrameLevel(button:GetFrameLevel())

	f:ClearAllPoints()
	f:SetPoint("TOPLEFT", button, "TOPLEFT", -x, y)
	f:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", x, -y)

	SetupButton(f, options)

	f:Show()
end

function lib.ButtonGlow_Stop(button)
	local name = "_ButtonGlow"
	local f = button[name]
	if not f then return end

	button[name] = nil
	if f.animOut:IsPlaying() then
		-- let it finish
	elseif f.animIn:IsPlaying() then
		f.animIn:Stop()
		GlowFramePool:Release(f)
	elseif button:IsVisible() then
		f.animOut:Play()
	else
		GlowFramePool:Release(f)
	end
end

-- -----------------------
-- Proc Glow (proc start + loop)
-- -----------------------
local function InitProc(f)
	if not f.inited then
		f.ProcStart = f:CreateTexture(nil, "OVERLAY")
		f.ProcStart:SetPoint("CENTER", f, "CENTER")
		f.ProcStart:SetAlpha(0)
		f.ProcStart:SetAtlas("UI-HUD-ActionBar-Proc-Start-Flipbook")

		f.ProcLoop = f:CreateTexture(nil, "OVERLAY")
		f.ProcLoop:SetAlpha(0)
		f.ProcLoop:SetAtlas("UI-HUD-ActionBar-Proc-Loop-Flipbook")
		f.ProcLoop:ClearAllPoints()
		f.ProcLoop:SetPoint("TOPLEFT", f, "TOPLEFT")
		f.ProcLoop:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT")

		f.ProcLoopAnim = f:CreateAnimationGroup()
		f.ProcLoopAnim:SetLooping("REPEAT")
		f.ProcLoopAnim:SetToFinalAlpha(true)
		local a = f.ProcLoopAnim:CreateAnimation("Alpha")
		a:SetChildKey("ProcLoop")
		a:SetFromAlpha(1)
		a:SetToAlpha(1)
		a:SetDuration(.001)
		a:SetOrder(0)
		local fb = f.ProcLoopAnim:CreateAnimation("FlipBook")
		fb:SetChildKey("ProcLoop")
		fb:SetDuration(1)
		fb:SetOrder(0)
		fb:SetFlipBookRows(6)
		fb:SetFlipBookColumns(5)
		fb:SetFlipBookFrames(30)

		f.ProcStartAnim = f:CreateAnimationGroup()
		f.ProcStartAnim:SetToFinalAlpha(true)
		local a2 = f.ProcStartAnim:CreateAnimation("Alpha")
		a2:SetChildKey("ProcStart")
		a2:SetDuration(.001)
		a2:SetOrder(0)
		a2:SetFromAlpha(1)
		a2:SetToAlpha(1)
		local fb2 = f.ProcStartAnim:CreateAnimation("FlipBook")
		fb2:SetChildKey("ProcStart")
		fb2:SetDuration(0.7)
		fb2:SetOrder(1)
		fb2:SetFlipBookRows(6)
		fb2:SetFlipBookColumns(5)
		fb2:SetFlipBookFrames(30)
		local a3 = f.ProcStartAnim:CreateAnimation("Alpha")
		a3:SetChildKey("ProcStart")
		a3:SetDuration(.001)
		a3:SetOrder(2)
		a3:SetFromAlpha(1)
		a3:SetToAlpha(0)

		f.ProcStartAnim:SetScript("OnFinished", function(self)
			local p = self:GetParent()
			p.ProcStart:Hide()
			p.ProcLoop:Show()
			p.ProcLoopAnim:Play()
			p._procState = "loop"
		end)

		f._procState = "idle"

		f.inited = true
	end
end

local function SetupProc(f, options)
	local playing = (f.ProcStartAnim and f.ProcStartAnim:IsPlaying()) or (f.ProcLoopAnim and f.ProcLoopAnim:IsPlaying())
	if not playing and f._procState == "idle" then
		local w, h = f:GetSize()
		f.ProcStart:SetSize((w / 42 * 150) / 1.4, (h / 42 * 150) / 1.4)
		f.ProcStart:Show()
		f.ProcLoop:Hide()
		f.ProcStartAnim:Play()
		f._procState = "start"
	end

	f:SetScript("OnHide", function(self)
		if self._procState ~= "idle" then
			if self.ProcStartAnim and self.ProcStartAnim:IsPlaying() then
				self.ProcStartAnim:Pause()
			end
			if self.ProcLoopAnim and self.ProcLoopAnim:IsPlaying() then
				self.ProcLoopAnim:Pause()
			end
		end
	end)

	f:SetScript("OnShow", function(self)
		if self._procState == "start" then
			if self.ProcStartAnim and self.ProcStartAnim:IsPaused() then
				self.ProcStartAnim:Play()
			end
		elseif self._procState == "loop" then
			if self.ProcLoopAnim and self.ProcLoopAnim:IsPaused() then
				self.ProcLoopAnim:Play()
			end
		end
	end)
end

function lib.ProcGlow_Start(button, options)
	if not button then return end
	options = ApplyDefaults(options, ProcDefaults)

	local w, h = button:GetSize()
	local x = options.xOffset + w * 0.2
	local y = options.yOffset + h * 0.2

	local name, f = "_ProcGlow"
	if button[name] then
		f = button[name]
	else
		f = GlowFramePool:Acquire()
		InitProc(f)
		button[name] = f
	end

	f:SetParent(button)
	f:SetFrameLevel(button:GetFrameLevel())

	f:ClearAllPoints()
	f:SetPoint("TOPLEFT", button, "TOPLEFT", -x, y)
	f:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", x, -y)

	SetupProc(f, options)
	f:Show()
end

function lib.ProcGlow_Stop(button)
	local name = "_ProcGlow"
	local f = button[name]
	if not f then return end

	button[name] = nil
	if f.ProcStartAnim and f.ProcStartAnim:IsPlaying() then f.ProcStartAnim:Stop() end
	if f.ProcLoopAnim and f.ProcLoopAnim:IsPlaying() then f.ProcLoopAnim:Stop() end
	if f.ProcStart then f.ProcStart:Hide() end
	if f.ProcLoop then f.ProcLoop:Hide() end

	f._procState = "idle"
	GlowFramePool:Release(f)
end

RegisterGlow("Action Button Glow", lib.ButtonGlow_Start, lib.ButtonGlow_Stop)
RegisterGlow("Auto Cast Glow", lib.AutoCastGlow_Start, lib.AutoCastGlow_Stop)
RegisterGlow("Pixel Glow", lib.PixelGlow_Start, lib.PixelGlow_Stop)
RegisterGlow("Proc Glow", lib.ProcGlow_Start, lib.ProcGlow_Stop)

local LCG_GlowList = {
	[1] = "Action Button Glow",
	[2] = "Auto Cast Glow",
	[3] = "Pixel Glow",
	[4] = "Proc Glow"
}
local function GetGlowType()
	return LCG_GlowList[NDuiADB and NDuiADB.GlowMode or 1]
end
function lib.ShowOverlayGlow(button)
	lib.startList[GetGlowType()](button)
end
function lib.HideOverlayGlow(button)
	lib.stopList[GetGlowType()](button)
end

return lib
