
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
local isRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE

-- textures
local textureList = {
	empty = "Interface\\AdventureMap\\BrokenIsles\\AM_29",
	white = "Interface\\BUTTONS\\WHITE8X8",
	shine = "Interface\\ItemSocketingFrame\\UI-ItemSockets",
}
local shineCoords = {0.3984375, 0.4453125, 0.40234375, 0.44921875}
if isRetail then
	textureList.shine = "Interface\\Artifacts\\Artifacts"
	shineCoords = {0.8115234375, 0.9169921875, 0.8798828125, 0.9853515625}
end

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

-- default options
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

local ButtonDefaults = {
	frameLevel = fallbackLevel,
	throttle = 0.01,
	xOffset = 0,
	yOffset = 0,
}

local ProcDefaults = {
	frameLevel = fallbackLevel,
	duration = 1,
	xOffset = 0,
	yOffset = 0,
}

-- pools
local Parent = UIParent
local GlowTexPool = CreateTexturePool(Parent, "OVERLAY", 7)
local GlowFramePool = CreateFramePool("Frame", Parent)

-- helper: safely apply color to texture or list of textures
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

	-- 只有普通 Lua table 才 pairs 遍历
	if type(target) == "table" and getmetatable(target) == nil then
		for _, v in pairs(target) do
			apply(v)
		end
	else
		apply(target)
	end
end

-- Pause/Resume utilities applied to frames that may own animations
local function PauseAnims(f)
	if not f then return end

	if f.ProcStartAnim and f.ProcStartAnim.IsPlaying and f.ProcStartAnim:IsPlaying() then f.ProcStartAnim:Pause() end
	if f.ProcLoopAnim and f.ProcLoopAnim.IsPlaying and f.ProcLoopAnim:IsPlaying() then f.ProcLoopAnim:Pause() end
	if f.animIn and f.animIn.IsPlaying and f.animIn:IsPlaying() then f.animIn:Pause() end
	if f.animOut and f.animOut.IsPlaying and f.animOut:IsPlaying() then f.animOut:Pause() end
end

local function ResumeAnims(f)
	if not f then return end

	if f.ProcStartAnim and f.ProcStartAnim.IsPaused and f.ProcStartAnim:IsPaused() then f.ProcStartAnim:Play() end
	if f.ProcLoopAnim and f.ProcLoopAnim.IsPaused and f.ProcLoopAnim:IsPaused() then f.ProcLoopAnim:Play() end
	if f.animIn and f.animIn.IsPaused and f.animIn:IsPaused() then f.animIn:Play() end
	if f.animOut and f.animOut.IsPaused and f.animOut:IsPaused() then f.animOut:Play() end
end

local function HookPauseResume(f)
	if not f or f._pauseHooked then return end

	f:SetScript("OnHide", function(self) PauseAnims(self) end)
	f:SetScript("OnShow", function(self) ResumeAnims(self) end)
	f._pauseHooked = true
end

-- utility to create or reuse a glow frame attached to parent button
local function GetOrCreateFrame(button, name, frameLevel, xOffset, yOffset)
	local f
	if button[name] then
		f = button[name]
	else
		f = GlowFramePool:Acquire()
		button[name] = f
	end

	f:SetParent(button)
	f:SetFrameLevel(button:GetFrameLevel() + frameLevel)
	f:ClearAllPoints()
	f:SetPoint("TOPLEFT", button, "TOPLEFT", -xOffset, yOffset)
	f:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", xOffset, -yOffset)
	f:Show()

	HookPauseResume(f)

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
	if self.timer > 1 or self.timer < -1 then self.timer = self.timer % 1 end
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
	local f = GetOrCreateFrame(button, name, options.frameLevel, options.xOffset, options.yOffset)
	local w, h = button:GetSize()

	f.info = f.info or {}
	f.masks = f.masks or {}
	f.textures = f.textures or {}
	f.timer = f.timer or 0

	f.info.step = 1 / options.num
	f.info.period = options.period
	f.info.thickness = options.thickness
	f.info.length = math.min(math.floor((w + h) * (2 / options.num - 0.1)), math.min(w, h))

	-- primary mask (用于裁切边缘)
	if not f.masks[1] then
		f.masks[1] = f:CreateMaskTexture()
		f.masks[1]:SetTexture(textureList.empty, "CLAMPTOWHITE", "CLAMPTOWHITE")
		f.masks[1]:Show()
	end
	f.masks[1]:ClearAllPoints()
	f.masks[1]:SetPoint("TOPLEFT", f, "TOPLEFT", options.thickness, -options.thickness)
	f.masks[1]:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -options.thickness, options.thickness)

	-- create / update edge textures
	for i = 1, options.num do
		if not f.textures[i] then
			f.textures[i] = GlowTexPool:Acquire()
			f.textures[i]:SetTexture(textureList.white)
			f.textures[i]:SetTexCoord(0, 1, 0, 1)
			f.textures[i]:SetParent(f)
			f.textures[i]:SetDrawLayer("OVERLAY")
		end
		-- apply requested color (ApplyColor 能兼容 userdata / table)
		ApplyColor(f.textures[i], options.color)
		-- ensure mask applied
		if f.masks[1] and f.textures[i]:GetNumMaskTextures() < 1 then
			f.textures[i]:AddMaskTexture(f.masks[1])
		end
		f.textures[i]:Show()
	end

	-- release extras (如果 num 减少)
	while #f.textures > options.num do
		local t = table.remove(f.textures)
		GlowTexPool:Release(t)
	end

	-- start update
	pUpdate(f, 0)
	f:SetScript("OnUpdate", pUpdate)

	-- ensure hide/show pause behavior
	HookPauseResume(f)
end

function lib.PixelGlow_Stop(button)
	local name = "_PixelGlow"
	local f = button[name]
	if not f then return end

	button[name] = nil        -- 清除引用
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
	local f = GetOrCreateFrame(button, name, options.frameLevel, options.xOffset, options.yOffset)

	f.info = f.info or {}
	f.info.num = options.num
	f.info.period = options.period
	f.timer = f.timer or {0, 0, 0, 0}

	-- need num * 4 textures (4 rows)
	f.textures = f.textures or {}
	for i = 1, options.num * 4 do
		if not f.textures[i] then
			f.textures[i] = GlowTexPool:Acquire()
			f.textures[i]:SetTexture(textureList.shine)
			f.textures[i]:SetTexCoord(unpack(shineCoords))
			f.textures[i]:SetParent(f)
			f.textures[i]:SetDrawLayer("OVERLAY")
			if not isRetail then
				-- keep original behavior for non-retail
				pcall(f.textures[i].SetBlendMode, f.textures[i], "ADD")
			end
		end
		-- size pattern (original used sizes 7,6,5,4 scaled)
		local sizes = {7, 6, 5, 4}
		local row = math.floor((i - 1) / options.num) + 1
		local size = sizes[row] or sizes[#sizes]
		f.textures[i]:SetSize(size * options.scale, size * options.scale)

		-- THIS IS THE CRITICAL FIX: apply the requested color
		ApplyColor(f.textures[i], options.color)

		f.textures[i]:Show()
	end

	-- trim extras if any
	while #f.textures > options.num * 4 do
		local t = table.remove(f.textures)
		GlowTexPool:Release(t)
	end

	f:SetScript("OnUpdate", acUpdate)
	acUpdate(f, 0)

	HookPauseResume(f)
end

function lib.AutoCastGlow_Stop(button)
	local name = "_AutoCastGlow"
	local f = button[name]
	if not f then return end

	button[name] = nil        -- 清除引用
	GlowFramePool:Release(f)
end

-- -----------------------
-- Button Glow (action button sparkle)
-- -----------------------
local ButtonPool = CreateFramePool("Frame", Parent)
local ButtonTextures = { ["spark"] = true, ["innerGlow"] = true, ["innerGlowOver"] = true, ["outerGlow"] = true, ["outerGlowOver"] = true, ["ants"] = true }

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
	frame.spark:SetSize(fw, fh)
	frame.innerGlow:SetAlpha(1)
	frame.innerGlow:SetSize(fw / 2, fh / 2)
	frame.outerGlow:SetAlpha(0)
	frame.outerGlow:SetSize(fw * 2, fh * 2)
	frame.ants:SetAlpha(0)
	frame.ants:SetSize(fw, fh)
	frame:Show()
end

local function AnimIn_OnFinished(group)
	local frame = group:GetParent()
	local fw, fh = frame:GetSize()
	frame.spark:SetAlpha(0)
	frame.spark:SetSize(fw, fh)
	frame.innerGlow:SetAlpha(0)
	frame.innerGlow:SetSize(fw, fh)
	frame.outerGlow:SetAlpha(1)
	frame.outerGlow:SetSize(fw, fh)
	frame.ants:SetAlpha(1)
	frame.ants:SetSize(fw, fh)
end

local function InitButton(f)
	if not f.inited then
		f.ants = f:CreateTexture(nil, "OVERLAY")
		f.ants:SetPoint("CENTER")
		f.ants:SetAlpha(0)
		f.ants:SetTexture("Interface\\SpellActivationOverlay\\IconAlertAnts")

		f.spark = f:CreateTexture(nil, "BACKGROUND")
		f.spark:SetPoint("CENTER")
		f.spark:SetAlpha(0)
		f.spark:SetTexture("Interface\\SpellActivationOverlay\\IconAlert")
		f.spark:SetTexCoord(0.00781250, 0.61718750, 0.00390625, 0.26953125)

		f.innerGlow = f:CreateTexture(nil, "OVERLAY")
		f.innerGlow:SetPoint("CENTER")
		f.innerGlow:SetAlpha(0)
		f.innerGlow:SetTexture("Interface\\SpellActivationOverlay\\IconAlert")
		f.innerGlow:SetTexCoord(0.00781250, 0.50781250, 0.27734375, 0.52734375)

		f.outerGlow = f:CreateTexture(nil, "OVERLAY")
		f.outerGlow:SetPoint("CENTER")
		f.outerGlow:SetAlpha(0)
		f.outerGlow:SetTexture("Interface\\SpellActivationOverlay\\IconAlert")
		f.outerGlow:SetTexCoord(0.00781250, 0.50781250, 0.27734375, 0.52734375)

		f.animIn = f:CreateAnimationGroup()
		f.animIn.appear = {}
		f.animIn.fade = {}

		AddScale(f.animIn, "spark", 1, 0.2, 1.5, 1.5)
		AddAlpha(f.animIn, "spark", 1, 0.2, 0, 1, nil, true)
		AddScale(f.animIn, "innerGlow", 1, 0.3, 2, 2)
		AddScale(f.animIn, "outerGlow", 1, 0.3, 0.5, 0.5)
		AddScale(f.animIn, "spark", 1, 0.2, 0.7, 0.7, 0.2)
		AddAlpha(f.animIn, "spark", 1, 0.2, 1, 0, 0.2, false)
		AddAlpha(f.animIn, "innerGlow", 1, 0.2, 1, 0, 0.3, false)
		AddAlpha(f.animIn, "ants", 1, 0.2, 0, 1, 0.3, true)

		f.animIn:SetScript("OnPlay", AnimIn_OnPlay)
		f.animIn:SetScript("OnFinished", AnimIn_OnFinished)

		f.animOut = f:CreateAnimationGroup()
		f.animOut.appear = {}
		f.animOut.fade = {}

		AddAlpha(f.animOut, "ants", 1, 0.2, 1, 0, nil, false)
		AddAlpha(f.animOut, "outerGlow", 2, 0.2, 1, 0, nil, false)

		f.animOut:SetScript("OnFinished", function(self) ButtonPool:Release(self:GetParent()) end)

		f.inited = true
	end
end

local function SetupButton(f, options)
	f:SetScript("OnUpdate", function(self, elapsed)
		AnimateTexCoords(self.ants, 256, 256, 48, 48, 22, elapsed, options.throttle)
		local cooldown = self:GetParent().cooldown
		if cooldown and cooldown:IsShown() and cooldown:GetCooldownDuration() > 3000 then
			self:SetAlpha(0.5)
		else
			self:SetAlpha(1.0)
		end
	end)

	if Masque and Masque.UpdateSpellAlert and (not button.overlay or not issecurevariable(button, "overlay")) then
		local old_overlay = button.overlay
		button.overlay = f
		Masque:UpdateSpellAlert(button)
		button.overlay = old_overlay
	end

	HookPauseResume(f)
end

function lib.ButtonGlow_Start(button, options)
	if not button then return end
	options = ApplyDefaults(options, ButtonDefaults)

	local w, h = button:GetSize()
	local xOffset = options.xOffset + w
	local yOffset = options.yOffset + h

	local name, f = "_ButtonGlow"
	if button[name] then
		f = button[name]

		if f.animOut:IsPlaying() then
			f.animOut:Stop()
			f.animIn:Play()
		end
	else
		f = ButtonPool:Acquire()
		f:SetSize(w*1.5, h*1.5)
		InitButton(f)
		f.animIn:Play()

		button[name] = f
	end

	f:SetParent(button)
	f:SetFrameLevel(button:GetFrameLevel() + options.frameLevel)

	f:ClearAllPoints()
	f:SetPoint("TOPLEFT", button, "TOPLEFT", -xOffset*0.2, yOffset*0.2)
	f:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", xOffset*0.2, -yOffset*0.2)
	f.ants:ClearAllPoints()
	f.ants:SetPoint("TOPLEFT", f, "TOPLEFT", xOffset*0.1, -yOffset*0.1)
	f.ants:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -xOffset*0.1, yOffset*0.1)

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
		ButtonPool:Release(f)
	elseif button:IsVisible() then
		f.animOut:Play()
	else
		ButtonPool:Release(f)
	end
end

-- -----------------------
-- Proc Glow (proc start + loop)
-- -----------------------
local ProcPool = CreateFramePool("Frame", Parent)

local function InitProc(f)
	if not f.inited then
		f.ProcStart = f:CreateTexture(nil, "OVERLAY")
		f.ProcStart:SetBlendMode("ADD")
		f.ProcStart:SetAtlas("UI-HUD-ActionBar-Proc-Start-Flipbook")
		f.ProcStart:SetAlpha(1)
		f.ProcStart:SetPoint("CENTER")

		f.ProcLoop = f:CreateTexture(nil, "OVERLAY")
		f.ProcLoop:SetAtlas("UI-HUD-ActionBar-Proc-Loop-Flipbook")
		f.ProcLoop:SetAlpha(0)
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
	-- 尝试安全地引用并设置 flipbookRepeat 的时长（如果存在）
	if f.ProcLoopAnim and f.ProcLoopAnim.flipbookRepeat then
		f.ProcLoopAnim.flipbookRepeat:SetDuration(options.duration)
	end

	local playing = (f.ProcStartAnim and f.ProcStartAnim:IsPlaying()) or (f.ProcLoopAnim and f.ProcLoopAnim:IsPlaying())
	if not playing and f._procState == "idle" then
		local w, h = f:GetSize()
		f.ProcStart:ClearAllPoints()
		f.ProcStart:SetPoint("CENTER", f, "CENTER")
		f.ProcStart:SetPoint("TOPLEFT", f, "CENTER", -(w / 42 * 75) / 1.4, (h / 42 * 75) / 1.4)
		f.ProcStart:SetPoint("BOTTOMRIGHT", f, "CENTER", (w / 42 * 75) / 1.4, -(h / 42 * 75) / 1.4)
		f.ProcStart:Show()
		f.ProcLoop:Hide()
		f.ProcStartAnim:Play()
		f._procState = "start"
	end

	-- OnHide: 隐藏时只暂停动画（真正清理由 Stop 函数负责）
	f:SetScript("OnHide", function(self)
		if self._procState ~= "idle" then
			PauseAnims(self)
		end
	end)

	-- OnShow: 恢复因 Hide 而暂停的动画
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

	HookPauseResume(f)
end

function lib.ProcGlow_Start(button, options)
	if not button then return end
	options = ApplyDefaults(options, ProcDefaults)

	local w, h = button:GetSize()
	local xOffset = options.xOffset + w * 0.2
	local yOffset = options.yOffset + h * 0.2

	local name, f = "_ProcGlow"
	if button[name] then
		f = button[name]
	else
		f = ProcPool:Acquire()
		f:SetSize(w*1.5, h*1.5)
		InitProc(f)
		button[name] = f
	end

	f:SetParent(button)
	f:SetFrameLevel(button:GetFrameLevel() + options.frameLevel)

	f:ClearAllPoints()
	f:SetPoint("TOPLEFT", button, "TOPLEFT", -xOffset, yOffset)
	f:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", xOffset, -yOffset)

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
	ProcPool:Release(f)
end

-- register
RegisterGlow("Pixel Glow", lib.PixelGlow_Start, lib.PixelGlow_Stop)
RegisterGlow("Auto Cast Glow", lib.AutoCastGlow_Start, lib.AutoCastGlow_Stop)
RegisterGlow("Action Button Glow", lib.ButtonGlow_Start, lib.ButtonGlow_Stop)
RegisterGlow("Proc Glow", lib.ProcGlow_Start, lib.ProcGlow_Stop)

-- NDui glue (keep behavior)
local LCG_GlowList = {
	[1] = "Pixel Glow",
	[2] = "Auto Cast Glow",
	[3] = "Action Button Glow",
	[4] = "Proc Glow"
}
local function GetGlowType()
	return LCG_GlowList[NDuiADB and NDuiADB.GlowMode or 3]
end
function lib.ShowOverlayGlow(button)
	lib.startList[GetGlowType()](button)
end
function lib.HideOverlayGlow(button)
	lib.stopList[GetGlowType()](button)
end

return lib
