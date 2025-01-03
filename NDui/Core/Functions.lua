local _, ns = ...
local B, C, L, DB = unpack(ns)
local cr, cg, cb = DB.r, DB.g, DB.b

-- Math
do
	-- Numberize
	function B.Numb(n)
		if NDuiADB["NumberFormat"] == 1 then
			if n >= 1e12 then
				return format("%.4ft", n / 1e12)
			elseif n >= 1e9 then
				return format("%.3fb", n / 1e9)
			elseif n >= 1e6 then
				return format("%.2fm", n / 1e6)
			elseif n >= 1e3 then
				return format("%.1fk", n / 1e3)
			else
				return format("%.0f", n)
			end
		elseif NDuiADB["NumberFormat"] == 2 then
			if n >= 1e12 then
				return format("%.3f"..FOURTH_NUMBER, n / 1e12)
			elseif n >= 1e8 then
				return format("%.2f"..THIRD_NUMBER, n / 1e8)
			elseif n >= 1e4 then
				return format("%.1f"..SECOND_NUMBER, n / 1e4)
			else
				return format("%.0f", n)
			end
		else
			return format("%.0f", n)
		end
	end

	function B:Round(number, idp)
		idp = idp or 1
		local mult = 10 ^ idp
		return math.floor(number * mult + .5) / mult
	end

	-- Cooldown calculation
	local day, hour, minute = 86400, 3600, 60
	function B.FormatTime(s, modRate)
		if s >= day then
			return format("%d"..DB.MyColor.."d", s/day + .5), s%day
		elseif s >= 2*hour then
			return format("%d"..DB.MyColor.."h", s/hour + .5), s%hour
		elseif s >= minute then
			if s < C.db["Actionbar"]["MmssTH"] then
				return format("%.1d:%.2d", s/minute, s%minute), s - math.floor(s)
			else
				return format("%d"..DB.MyColor.."m", s/minute + .5), s%minute
			end
		else
			if s < C.db["Actionbar"]["TenthTH"] then
				return format("|cffFF0000%.1f|r", s), (s - format("%.1f", s)) / (modRate or 1)
			else
				return format("|cffFFFF00%d|r", s + .5), (s - math.floor(s)) / (modRate or 1)
			end
		end
	end

	function B:CooldownOnUpdate(elapsed, raw)
		self.elapsed = (self.elapsed or 0) + elapsed
		if self.elapsed >= .1 then
			local timeLeft = self.expiration - GetTime()
			if timeLeft > 0 then
				local text = B.FormatTime(timeLeft)
				self.timer:SetText(text)
			else
				self:SetScript("OnUpdate", nil)
				self.timer:SetText("")
			end
			self.elapsed = 0
		end
	end

	-- GUID to npcID
	function B.GetNPCID(guid)
		local id = tonumber(string.match((guid or ""), "%-(%d-)%-%x-$"))
		return id
	end

	-- Table
	function B.CopyTable(source, target)
		for key, value in pairs(source) do
			if type(value) == "table" then
				if not target[key] then target[key] = {} end
				for k in pairs(value) do
					target[key][k] = value[k]
				end
			else
				target[key] = value
			end
		end
	end

	function B.SplitList(list, variable, cleanup)
		if cleanup then table.wipe(list) end
		for word in string.gmatch(variable, "%S+") do
			word = tonumber(word) or word -- use number if exists, needs review
			list[word] = true
		end
	end

	-- Atlas info
	function B:GetTextureStrByAtlas(info, sizeX, sizeY)
		local file = info and info.file
		if not file then return end

		local width, height, txLeft, txRight, txTop, txBottom = info.width, info.height, info.leftTexCoord, info.rightTexCoord, info.topTexCoord, info.bottomTexCoord
		local atlasWidth = width / (txRight-txLeft)
		local atlasHeight = height / (txBottom-txTop)

		return format("|T%s:%d:%d:0:0:%d:%d:%d:%d:%d:%d|t", file, (sizeX or 0), (sizeY or 0), atlasWidth, atlasHeight, atlasWidth*txLeft, atlasWidth*txRight, atlasHeight*txTop, atlasHeight*txBottom)
	end
end

-- Color
do
	function B.HexRGB(r, g, b, unit)
		if r then
			if type(r) == "table" then
				if r.r then r, g, b = r.r, r.g, r.b else r, g, b = unpack(r) end
			end
			if unit then
				return format("|cff%02x%02x%02x%s|r", r*255, g*255, b*255, unit)
			else
				return format("|cff%02x%02x%02x", r*255, g*255, b*255)
			end
		end
	end

	function B.ClassColor(class)
		local color = DB.ClassColors[class]
		if not color then return .5, .5, .5 end
		return color.r, color.g, color.b
	end

	function B.UnitColor(unit)
		local r, g, b = 1, 1, 1
		if UnitIsPlayer(unit) or UnitInPartyIsAI(unit) then
			local class = select(2, UnitClass(unit))
			if class then
				r, g, b = B.ClassColor(class)
			end
		elseif UnitIsTapDenied(unit) then
			r, g, b = .5, .5, .5
		else
			local reaction = UnitReaction(unit, "player")
			if reaction then
				local color = FACTION_BAR_COLORS[reaction]
				r, g, b = color.r, color.g, color.b
			end
		end
		return r, g, b
	end
end

-- Scan tooltip
do
	local iLvlDB = {}
	local itemLevelString = "^"..string.gsub(ITEM_LEVEL, "%%d", "")
	local enchantString = string.gsub(ENCHANTED_TOOLTIP_LINE, "%%s", "(.+)")
	local isUnknownString = {
		[TRANSMOGRIFY_TOOLTIP_APPEARANCE_UNKNOWN] = true,
		[TRANSMOGRIFY_TOOLTIP_ITEM_UNKNOWN_APPEARANCE_KNOWN] = true,
	}

	local slotData = {gems={},gemsColor={}}
	function B.GetItemLevel(link, arg1, arg2, fullScan)
		if fullScan then
			local data = C_TooltipInfo.GetInventoryItem(arg1, arg2)
			if not data then return end

			table.wipe(slotData.gems)
			table.wipe(slotData.gemsColor)
			slotData.iLvl = nil
			slotData.enchantText = nil

			local num = 0
			for i = 2, #data.lines do
				local lineData = data.lines[i]
				if not slotData.iLvl then
					local text = lineData.leftText
					local found = text and string.find(text, itemLevelString)
					if found then
						local level = string.match(text, "(%d+)%)?$")
						slotData.iLvl = tonumber(level) or 0
					end
				elseif data.id == 158075 then -- heart of azeroth
					if lineData.essenceIcon then
						num = num + 1
						slotData.gems[num] = lineData.essenceIcon
						slotData.gemsColor[num] = lineData.leftColor
					end
				else
					if lineData.enchantID then
						slotData.enchantText = string.match(lineData.leftText, enchantString)
					elseif lineData.gemIcon then
						num = num + 1
						slotData.gems[num] = lineData.gemIcon
					elseif lineData.socketType then
						num = num + 1
						slotData.gems[num] = format("Interface\\ItemSocketingFrame\\UI-EmptySocket-%s", lineData.socketType)
					end
				end
			end

			return slotData
		else
			if iLvlDB[link] then return iLvlDB[link] end

			local data
			if arg1 and type(arg1) == "string" then
				data = C_TooltipInfo.GetInventoryItem(arg1, arg2)
			elseif arg1 and type(arg1) == "number" then
				data = C_TooltipInfo.GetBagItem(arg1, arg2)
			else
				data = C_TooltipInfo.GetHyperlink(link, nil, nil, true)
			end
			if not data then return end

			for i = 2, 5 do
				local lineData = data.lines[i]
				if not lineData then break end
				local text = lineData.leftText
				local found = text and string.find(text, itemLevelString)
				if found then
					local level = string.match(text, "(%d+)%)?$")
					iLvlDB[link] = tonumber(level)
					break
				end
			end
			return iLvlDB[link]
		end
	end

	local pendingNPCs, nameCache, callbacks = {}, {}, {}
	local loadingStr = "..."
	local pendingFrame = CreateFrame("Frame")
	pendingFrame:Hide()
	pendingFrame:SetScript("OnUpdate", function(self, elapsed)
		self.elapsed = (self.elapsed or 0) + elapsed
		if self.elapsed > 1 then
			if next(pendingNPCs) then
				for npcID, count in pairs(pendingNPCs) do
					if count > 2 then
						nameCache[npcID] = UNKNOWN
						if callbacks[npcID] then
							callbacks[npcID](UNKNOWN)
						end
						pendingNPCs[npcID] = nil
					else
						local name = B.GetNPCName(npcID, callbacks[npcID])
						if name and name ~= loadingStr then
							pendingNPCs[npcID] = nil
						else
							pendingNPCs[npcID] = pendingNPCs[npcID] + 1
						end
					end
				end
			else
				self:Hide()
			end

			self.elapsed = 0
		end
	end)

	function B.GetNPCName(npcID, callback)
		local name = nameCache[npcID]
		if not name then
			name = loadingStr
			local data = C_TooltipInfo.GetHyperlink(format("unit:Creature-0-0-0-0-%d", npcID))
			local lineData = data and data.lines
			if lineData then
				name = lineData[1] and lineData[1].leftText
			end
			if name == loadingStr then
				if not pendingNPCs[npcID] then
					pendingNPCs[npcID] = 1
					pendingFrame:Show()
				end
			else
				nameCache[npcID] = name
			end
		end
		if callback then
			callback(name)
			callbacks[npcID] = callback
		end

		return name
	end

	function B.IsUnknownTransmog(bagID, slotID)
		local data = C_TooltipInfo.GetBagItem(bagID, slotID)
		local lineData = data and data.lines
		if not lineData then return end

		for i = #lineData, 1, -1 do
			local line = lineData[i]
			if line.price then return false end
			return line.leftText and isUnknownString[line.leftText]
		end
	end
end

-- Kill regions
do
	function B:Dummy()
		return
	end

	B.HiddenFrame = CreateFrame("Frame")
	B.HiddenFrame:Hide()

	function B:HideObject()
		if self.UnregisterAllEvents then
			self:UnregisterAllEvents()
			self:SetParent(B.HiddenFrame)
		else
			self.Show = self.Hide
		end
		self:Hide()
	end

	function B:HideOption()
		self:SetAlpha(0)
		self:SetScale(.0001)
	end

	local blizzTextures = {
		"AffixBorder",
		"ArtOverlayFrame",
		"BG",
		"BGBottom",
		"BGCenter",
		"BGLeft",
		"BGRight",
		"BGTop",
		"Background",
		"BackgroundOverlay",
		"Begin",
		"Bg",
		"Border",
		"BorderBottom",
		"BorderBottomLeft",
		"BorderBottomRight",
		"BorderBox",
		"BorderCenter",
		"BorderFrame",
		"BorderGlow",
		"BorderLeft",
		"BorderRight",
		"BorderTop",
		"BorderTopLeft",
		"BorderTopRight",
		"Bottom",
		"BottomBar",
		"BottomInset",
		"BottomLeft",
		"BottomLeftBorderDecoration",
		"BottomLeftTex",
		"BottomMid",
		"BottomMiddle",
		"BottomRight",
		"BottomRightBorderDecoration",
		"BottomRightTex",
		"BottomTex",
		"Center",
		"CircleMask",
		"Cover",
		"Delimiter1",
		"Delimiter2",
		"EmptyBackground",
		"End",
		"FilligreeOverlay",
		"GarrCorners",
		"IconMask",
		"IconRing",
		"InnerBorder",
		"Inset",
		"InsetFrame",
		"InsetLeft",
		"InsetRight",
		"Left",
		"LeftDisabled",
		"LeftHighlight",
		"LeftInset",
		"LeftSeparator",
		"LeftTex",
		"LogoBorder",
		"Mask",
		"Mid",
		"Middle",
		"MiddleDisabled",
		"MiddleHighlight",
		"MiddleLeft",
		"MiddleMid",
		"MiddleMiddle",
		"MiddleRight",
		"MiddleTex",
		"NameFrame",
		"NineSlice",
		"NormalTexture",
		"Overlay",
		"OverlayKit",
		"Portrait",
		"PortraitContainer",
		"PortraitOverlay",
		"Right",
		"RightDisabled",
		"RightHighlight",
		"RightInset",
		"RightSeparator",
		"RightTex",
		"Ring",
		"ScrollBarBottom",
		"ScrollBarMiddle",
		"ScrollBarTop",
		"ScrollDownBorder",
		"ScrollFrameBorder",
		"ScrollUpBorder",
		"ShadowOverlay",
		"Spark",
		"SparkGlow",
		"SpellBorder",
		"TabSpacer",
		"TabSpacer1",
		"TabSpacer2",
		"Top",
		"TopBar",
		"TopInset",
		"TopLeft",
		"TopLeftBorderDecoration",
		"TopLeftCorner",
		"TopLeftTex",
		"TopMid",
		"TopMiddle",
		"TopRight",
		"TopRightBorderDecoration",
		"TopRightTex",
		"TopTex",
		"Track",
		"_LeftSeparator",
		"_RightSeparator",
		"arrowDown",
		"arrowUp",
		"background",
		"bgLeft",
		"bgRight",
		"border",
		"bottomInset",
		"inset",
		"overlay",
		"portrait",
		"shadows",
		"topInset",
		"track",
		"trackBG",
	}

	function B:CleanTextures(kill, isOverride)
		if self.SetBackdrop then self:SetBackdrop(nil) end
		if self.SetPushedTexture then self:SetPushedTexture(0) end
		if self.SetCheckedTexture then self:SetCheckedTexture(0) end
		if self.SetDisabledTexture then self:SetDisabledTexture(0) end
		if self.SetHighlightTexture then self:SetHighlightTexture(0) end
		if self.SetNormalTexture and not isOverride then self:SetNormalTexture(0) end

		for _, texture in pairs(blizzTextures) do
			local blizzTexture = B.GetObject(self, texture)
			if blizzTexture then
				if blizzTexture:IsObjectType("Texture") then
					blizzTexture:SetTexture("")
					blizzTexture:SetAtlas("")
					blizzTexture:SetAlpha(0)
				else
					B.StripTextures(blizzTexture, kill)
				end
			end
		end
	end

	function B:StripTextures(kill)
		B.CleanTextures(self, kill)

		if self.GetRegions then
			for index, region in pairs {self:GetRegions()} do
				if region and region:IsObjectType("Texture") and not region.isIgnored then
					if kill and type(kill) == "boolean" then
						B.HideObject(region)
					elseif tonumber(kill) then
						if kill == 0 then
							region:SetAlpha(0)
						elseif kill ~= index then
							region:SetTexture("")
							region:SetAtlas("")
							region:SetAlpha(0)
						end
					else
						region:SetTexture("")
						region:SetAtlas("")
					end
				end
			end
		end
	end

	-- lock cvar command
	local lockedCVars = {}

	function B:LockCVar(name, value)
		lockedCVars[name] = value
		SetCVar(name, value)
	end

	function B:UpdateCVars(var, state)
		local lockedVar = lockedCVars[var]
		if lockedVar ~= nil and state ~= lockedVar then
			SetCVar(var, lockedVar)
			if DB.isDeveloper then
				print("CVar reset:", var, lockedVar)
			end
		end
	end
	B:RegisterEvent("CVAR_UPDATE", B.UpdateCVars)
end

-- UI widgets
do
	-- HelpTip
	function B.HelpInfoAcknowledge(callbackArg)
		NDuiADB["Help"][callbackArg] = true
	end

	-- Dropdown menu
	B.EasyMenu = CreateFrame("Frame", "NDui_EasyMenu", UIParent, "UIDropDownMenuTemplate")

	-- Fontstring
	function B:SetFontSize(size)
		self:SetFont(DB.Font[1], size, DB.Font[3])
	end

	local justifyList = {
		["LEFT"] = "LEFT",
		["TOPLEFT"] = "LEFT",
		["BOTTOMLEFT"] = "LEFT",
		["RIGHT"] = "RIGHT",
		["TOPRIGHT"] = "RIGHT",
		["BOTTOMRIGHT"] = "RIGHT",
		["TOP"] = "CENTER",
		["CENTER"] = "CENTER",
		["BOTTOM"] = "CENTER",
	}

	function B:CreateFS(size, text, color, anchor, x, y)
		local fs = self:CreateFontString(nil, "OVERLAY")
		B.SetFontSize(fs, size)
		fs:SetText(text)
		fs:SetWordWrap(false)
		--fs:SetJustifyV("CENTER")
		fs:SetShadowColor(0, 0, 0, 0)

		if color and type(color) == "boolean" then
			fs:SetTextColor(cr, cg, cb)
		elseif color == "system" then
			fs:SetTextColor(1, .8, 0)
		end
		if anchor and x and y then
			fs:SetJustifyH(justifyList[anchor])
			B.UpdatePoint(fs, anchor, self, anchor, x, y)
		else
			fs:SetJustifyH("CENTER")
			B.UpdatePoint(fs, "CENTER", self, "CENTER", 1, 0)
		end

		return fs
	end

	-- Gametooltip
	local function Tooltip_OnLeave(self)
		GameTooltip:Hide()
	end

	local function Tooltip_OnEnter(self)
		GameTooltip:SetOwner(self, self.anchor)
		GameTooltip:ClearLines()
		if self.title then
			GameTooltip:AddLine(self.title)
		end
		if tonumber(self.text) then
			GameTooltip:SetSpellByID(self.text)
		elseif self.text then
			local r, g, b = 1, 1, 1
			if self.color == "class" then
				r, g, b = cr, cg, cb
			elseif self.color == "system" then
				r, g, b = 1, .8, 0
			elseif self.color == "info" then
				r, g, b = 0, 1, 1
			end
			GameTooltip:AddLine(self.text, r, g, b, 1)
		end
		GameTooltip:Show()
	end

	function B:AddTooltip(anchor, text, color, showTips)
		self.anchor = anchor
		self.text = text
		self.color = color
		if showTips then self.title = L["Tips"] end
		self:SetScript("OnEnter", Tooltip_OnEnter)
		self:SetScript("OnLeave", Tooltip_OnLeave)
	end

	function B:HideTooltip()
		GameTooltip:Hide()
	end

	-- Glow parent
	function B:CreateGlowFrame(size)
		local frame = CreateFrame("Frame", nil, self)
		frame:SetPoint("CENTER")
		frame:SetSize(size+8, size+8)
		frame:SetFrameLevel(frame:GetFrameLevel()+1)

		return frame
	end

	-- Gradient texture
	local orientationAbbr = {
		["V"] = "Vertical",
		["H"] = "Horizontal",
	}
	function B:SetGradient(orientation, r, g, b, a1, a2, width, height)
		orientation = orientationAbbr[orientation]
		if not orientation then return end

		local tex = self:CreateTexture(nil, "BACKGROUND")
		tex:SetTexture(DB.bdTex)
		tex:SetGradient(orientation, CreateColor(r, g, b, a1), CreateColor(r, g, b, a2))
		if width then tex:SetWidth(width) end
		if height then tex:SetHeight(height) end

		return tex
	end

	-- Background texture
	function B:CreateTex()
		if not C.db["Skins"]["BgTex"] then return end
		if self.__bgTex then return end

		local frame = self
		if self:IsObjectType("Texture") then frame = self:GetParent() end

		local tex = frame:CreateTexture(nil, "BACKGROUND", nil, 1)
		tex:SetAllPoints(self)
		tex:SetTexture(DB.bgTex, true, true)
		tex:SetHorizTile(true)
		tex:SetVertTile(true)
		tex:SetBlendMode("ADD")

		self.__bgTex = tex
	end

	-- Backdrop shadow
	function B:CreateSD(size, override)
		if not override and not C.db["Skins"]["Shadow"] then return end
		if self.__shadow then return end

		local frame = self
		if self:IsObjectType("Texture") then frame = self:GetParent() end

		local sdSize = size or 4
		local lvl = frame:GetFrameLevel()
		self.__shadow = CreateFrame("Frame", nil, frame, "BackdropTemplate")
		self.__shadow:SetOutside(self, sdSize, sdSize)
		self.__shadow:SetBackdrop({edgeFile = DB.glowTex, edgeSize = sdSize})
		self.__shadow:SetBackdropBorderColor(0, 0, 0, size and 1 or .5)
		self.__shadow:SetFrameLevel(lvl)

		return self.__shadow
	end
end

-- UI skins
do
	-- Setup backdrop
	C.frames = {}

	function B:SetBorderColor()
		if C.db["Skins"]["GreyBD"] then
			self:SetBackdropBorderColor(.5, .5, .5)
		else
			self:SetBackdropBorderColor(0, 0, 0)
		end
	end

	function B:CreateBD(alpha)
		self:SetBackdrop({bgFile = DB.bdTex, edgeFile = DB.bdTex, edgeSize = C.mult})
		self:SetBackdropColor(0, 0, 0, alpha or C.db["Skins"]["SkinAlpha"])
		B.SetBorderColor(self)

		if not alpha then table.insert(C.frames, self) end
	end

	function B:CreateGradient()
		local tex = self:CreateTexture(nil, "BORDER")
		tex:SetInside()
		tex:SetTexture(DB.bdTex)
		tex:SetVertexColor(.5, .5, .5, .25)

		return tex
	end

	-- Handle frame
	function B:CreateBDFrame(alpha, gradient)
		local frame = self
		if self:IsObjectType("Texture") then frame = self:GetParent() end

		local lvl = frame:GetFrameLevel()
		local bg = CreateFrame("Frame", nil, frame, "BackdropTemplate")
		bg:SetFrameLevel(lvl == 0 and 0 or lvl - 1)
		bg:SetOutside(self)

		B.CreateBD(bg, alpha)
		if gradient then
			self.__gradient = B.CreateGradient(bg)
		end

		return bg
	end

	function B:SetBD(x, y, x2, y2)
		local bg = B.CreateBDFrame(self)
		if x then
			B.UpdateSize(bg, x, y, x2, y2)
		end

		B.CreateSD(bg)
		B.CreateTex(bg)

		return bg
	end

	-- Handle icons
	local x1, x2, y1, y2 = unpack(DB.TexCoord)

	function B:ReskinIcon(shadow)
		self:SetTexCoord(x1, x2, y1, y2)

		local bg = B.CreateBDFrame(self, .25) -- exclude from opacity control
		if shadow then B.CreateSD(bg) end

		return bg
	end

	function B:PixelIcon(texture, highlight)
		self.bg = B.CreateBDFrame(self)
		self.bg:SetAllPoints()

		self.Icon = self:CreateTexture(nil, "ARTWORK")
		self.Icon:SetInside(self.bg)
		self.Icon:SetTexCoord(x1, x2, y1, y2)

		if texture then
			local atlas = string.match(texture, "Atlas:(.+)$")
			if atlas then
				self.Icon:SetAtlas(atlas)
			else
				self.Icon:SetTexture(texture)
			end
		end
		if highlight and type(highlight) == "boolean" then
			self:EnableMouse(true)
			self.HL = self:CreateTexture(nil, "HIGHLIGHT")
			self.HL:SetColorTexture(1, 1, 1, .25)
			self.HL:SetInside(self.bg)
		end
	end

	function B:AuraIcon(highlight)
		self.CD = CreateFrame("Cooldown", nil, self, "CooldownFrameTemplate")
		self.CD:SetInside()
		self.CD:SetReverse(true)

		B.PixelIcon(self, nil, highlight)
		B.CreateSD(self)
	end

	function B:CreateGear(name)
		local bu = CreateFrame("Button", name, self)
		bu:SetSize(24, 24)
		bu.Icon = bu:CreateTexture(nil, "ARTWORK")
		bu.Icon:SetAllPoints()
		bu.Icon:SetTexture(DB.gearTex)
		bu.Icon:SetTexCoord(0, .5, 0, .5)
		bu:SetHighlightTexture(DB.gearTex)
		bu:GetHighlightTexture():SetTexCoord(0, .5, 0, .5)

		return bu
	end

	function B:CreateHelpInfo(tooltip)
		local bu = CreateFrame("Button", nil, self)
		bu:SetSize(40, 40)
		bu.Icon = bu:CreateTexture(nil, "ARTWORK")
		bu.Icon:SetAllPoints()
		bu.Icon:SetTexture(616343)
		bu:SetHighlightTexture(616343)
		if tooltip then
			B.AddTooltip(bu, "ANCHOR_BOTTOMLEFT", tooltip, "info", true)
		end

		return bu
	end

	function B:CreateWatermark()
		local logo = self:CreateTexture(nil, "BACKGROUND")
		logo:SetPoint("BOTTOMRIGHT", 10, 0)
		logo:SetTexture(DB.logoTex)
		logo:SetTexCoord(0, 1, 0, .75)
		logo:SetSize(200, 75)
		logo:SetAlpha(.3)
	end

	local AtlasToQuality = {
		["error"] = 99,
		["uncollected"] = Enum.ItemQuality.Poor,
		["gray"] = Enum.ItemQuality.Poor,
		["white"] = Enum.ItemQuality.Common,
		["green"] = Enum.ItemQuality.Uncommon,
		["blue"] = Enum.ItemQuality.Rare,
		["purple"] = Enum.ItemQuality.Epic,
		["orange"] = Enum.ItemQuality.Legendary,
		["artifact"] = Enum.ItemQuality.Artifact,
		["account"] = Enum.ItemQuality.Heirloom,
	}
	local function updateIconBorderColorByAtlas(border, atlas)
		local atlasAbbr = atlas and string.match(atlas, "%-(%w+)$")
		local quality = atlasAbbr and AtlasToQuality[atlasAbbr]
		local color = DB.QualityColors[quality or 1]
		border.__owner.bg:SetBackdropBorderColor(color.r, color.g, color.b)
	end

	local function updateIconBorderColor(border, r, g, b)
		border.__owner.bg:SetBackdropBorderColor(r, g, b)
		border:Hide(true) -- fix icon border
	end
	local function resetIconBorderColor(border, texture)
		if not texture then
			border.__owner.bg:SetBackdropBorderColor(0, 0, 0)
		end
	end
	local function iconBorderShown(border, show)
		if not show then
			resetIconBorderColor(border)
		end
	end
	function B:ReskinIconBorder(needInit, useAtlas)
		self:SetAlpha(0)
		self.__owner = self:GetParent()
		if not self.__owner.bg then return end
		if useAtlas or self.__owner.useCircularIconBorder then -- for auction item display
			hooksecurefunc(self, "SetAtlas", updateIconBorderColorByAtlas)
			hooksecurefunc(self, "SetTexture", resetIconBorderColor)
			if needInit then
				self:SetAtlas(self:GetAtlas()) -- for border with color before hook
			end
		else
			hooksecurefunc(self, "SetVertexColor", updateIconBorderColor)
			if needInit then
				self:SetVertexColor(self:GetVertexColor()) -- for border with color before hook
			end
		end
		hooksecurefunc(self, "Hide", resetIconBorderColor)
		hooksecurefunc(self, "SetShown", iconBorderShown)
	end

	local CLASS_ICON_TCOORDS = CLASS_ICON_TCOORDS
	function B:ClassIconTexCoord(class)
		local tcoords = CLASS_ICON_TCOORDS[class]
		self:SetTexCoord(tcoords[1] + .022, tcoords[2] - .025, tcoords[3] + .022, tcoords[4] - .025)
	end

	-- Handle statusbar
	function B:CreateSB(spark, r, g, b)
		self:SetStatusBarTexture(DB.normTex)
		if r and g and b then
			self:SetStatusBarColor(r, g, b)
		else
			self:SetStatusBarColor(cr, cg, cb)
		end

		local bg = B.SetBD(self)
		self.__shadow = bg.__shadow

		if spark then
			self.Spark = self:CreateTexture(nil, "OVERLAY")
			self.Spark:SetTexture(DB.sparkTex)
			self.Spark:SetBlendMode("ADD")
			self.Spark:SetAlpha(1)
			self.Spark:SetPoint("TOPLEFT", self:GetStatusBarTexture(), "TOPRIGHT", -10, 10)
			self.Spark:SetPoint("BOTTOMRIGHT", self:GetStatusBarTexture(), "BOTTOMRIGHT", 10, -10)
		end
	end

	function B:CreateAndUpdateBarTicks(bar, ticks, numTicks)
		for i = 1, #ticks do
			ticks[i]:Hide()
		end

		if numTicks and numTicks > 0 then
			local width, height = bar:GetSize()
			local delta = width / numTicks
			for i = 1, numTicks-1 do
				if not ticks[i] then
					ticks[i] = bar:CreateTexture(nil, "OVERLAY")
					ticks[i]:SetTexture(DB.normTex)
					ticks[i]:SetVertexColor(0, 0, 0)
					ticks[i]:SetWidth(C.mult)
					ticks[i]:SetHeight(height)
				end
				ticks[i]:ClearAllPoints()
				ticks[i]:SetPoint("RIGHT", bar, "LEFT", delta * i, 0 )
				ticks[i]:Show()
			end
		end
	end

	-- Handle button
	local function Button_OnEnter(self)
		if not self:IsEnabled() then return end

		if self.__gradient then
			self.__gradient:SetVertexColor(cr, cg, cb, .25)
		else
			self.__bg:SetBackdropColor(cr, cg, cb, .25)
		end
	end
	local function Button_OnLeave(self)
		if self.__gradient then
			self.__gradient:SetVertexColor(.5, .5, .5, .25)
		else
			self.__bg:SetBackdropColor(0, 0, 0, 0)
		end
	end

	function B:ReskinButton(override)
		B.CleanTextures(self, 99, override)

		self.__bg = B.CreateBDFrame(self, 0, true)
		self.__bg:SetFrameLevel(self:GetFrameLevel())
		self.__bg:SetAllPoints()

		self:HookScript("OnEnter", Button_OnEnter)
		self:HookScript("OnLeave", Button_OnLeave)
	end

	local function Menu_OnEnter(self)
		self.bg:SetBackdropBorderColor(cr, cg, cb)
	end
	local function Menu_OnLeave(self)
		B.SetBorderColor(self.bg)
	end
	local function Menu_OnMouseUp(self)
		self.bg:SetBackdropColor(0, 0, 0, .25)
	end
	local function Menu_OnMouseDown(self)
		self.bg:SetBackdropColor(cr, cg, cb, .25)
	end

	function B:ReskinMenuButton()
		B.StripTextures(self)
		self.bg = B.SetBD(self)
		self:SetScript("OnEnter", Menu_OnEnter)
		self:SetScript("OnLeave", Menu_OnLeave)
		self:HookScript("OnMouseUp", Menu_OnMouseUp)
		self:HookScript("OnMouseDown", Menu_OnMouseDown)
	end

	-- Handle tabs
	function B:ReskinTab(noShadow)
		B.CleanTextures(self)
		self:DisableDrawLayer("BACKGROUND")

		local bg = B.CreateBDFrame(self)
		bg:SetPoint("TOPLEFT", 8, -2)
		bg:SetPoint("BOTTOMRIGHT", -8, 4)
		self.bg = bg

		B.ReskinHLTex(self, bg, true)
		B.ResetTabAnchor(self)

		if not noShadow then
			B.CreateSD(bg)
			B.CreateTex(bg)
		end
	end

	function B:ResetTabAnchor()
		local text = B.GetObject(self, "Text")
		if text then
			text:ClearAllPoints()
			text:SetPoint("CENTER", self, "CENTER", 0, 1)
		end
	end
	hooksecurefunc("PanelTemplates_SelectTab", B.ResetTabAnchor)
	hooksecurefunc("PanelTemplates_DeselectTab", B.ResetTabAnchor)

	-- Handle scrollframe
	local function Thumb_OnEnter(self)
		local thumb = self.thumb or self
		thumb.__gradient:SetVertexColor(cr, cg, cb, .25)
	end
	local function Thumb_OnLeave(self)
		local thumb = self.thumb or self
		thumb.__gradient:SetVertexColor(.5, .5, .5, .25)
	end

	local function updateScrollArrow(arrow)
		if not arrow.__texture then return end

		if arrow:IsEnabled() then
			arrow.__texture:SetAlpha(1)
		else
			arrow.__texture:SetAlpha(.5)
		end
	end
	local function updateTrimScrollArrow(self, atlas)
		local arrow = self.__owner
		if not arrow.__texture then return end

		if arrow:IsEnabled() then
			arrow.__texture:SetAlpha(1)
		else
			arrow.__texture:SetAlpha(.5)
		end
	end

	local function reskinScrollArrow(self, direction)
		if not self then return end

		self:SetSize(18, 18)
		B.StripTextures(self, 99)
		B.SetupTexture(self, direction)

		if self.Texture then
			self.Texture.__owner = self
			hooksecurefunc(self.Texture, "SetAtlas", updateTrimScrollArrow)
		else
			hooksecurefunc(self, "Enable", updateScrollArrow)
			hooksecurefunc(self, "Disable", updateScrollArrow)
		end
	end

	function B:ReskinScroll()
		B.StripTextures(self:GetParent(), 99)
		B.StripTextures(self, 99)

		local up, down = self:GetChildren()
		reskinScrollArrow(up, "up")
		reskinScrollArrow(down, "down")

		local thumb = self:GetThumbTexture()
		if thumb then
			B.StripTextures(thumb, 99)

			thumb.bg = B.CreateBDFrame(thumb, 0, true)
			B.UpdateSize(thumb.bg, 4, -1, -4, 1, thumb)
			self.thumb = thumb

			self:HookScript("OnEnter", Thumb_OnEnter)
			self:HookScript("OnLeave", Thumb_OnLeave)
		end
	end

	-- WowTrimScrollBar
	function B:ReskinTrimScroll()
		B.StripTextures(self)
		reskinScrollArrow(self.Back, "up")
		reskinScrollArrow(self.Forward, "down")

		local thumb = self:GetThumb()
		if thumb then
			thumb:DisableDrawLayer("ARTWORK")
			thumb:DisableDrawLayer("BACKGROUND")

			thumb.bg = B.CreateBDFrame(thumb, 0, true)

			thumb:HookScript("OnEnter", Thumb_OnEnter)
			thumb:HookScript("OnLeave", Thumb_OnLeave)
		end
	end

	-- Handle dropdown
	function B:ReskinDropDown()
		B.StripTextures(self, 99)

		local bg = B.CreateBDFrame(self, 0, true)
		B.UpdateSize(bg, 0, -2, 0, 2)

		local tex = self:CreateTexture(nil, "ARTWORK")
		tex:SetTexture(DB.arrowTex.."down")
		tex:SetPoint("RIGHT", bg, -3, 0)
		tex:SetSize(18, 18)
		self.__texture = tex

		self:HookScript("OnEnter", B.Texture_OnEnter)
		self:HookScript("OnLeave", B.Texture_OnLeave)
	end

	-- Handle close button
	function B:Texture_OnEnter()
		if DB.isDeveloper and not self.IsEnabled then
			print(self:GetDebugName())
		end
		if self.IsEnabled and self:IsEnabled() then
			if self.bg then
				self.bg:SetBackdropColor(cr, cg, cb, .25)
			else
				self.__texture:SetVertexColor(cr, cg, cb)
			end
		end
	end

	function B:Texture_OnLeave()
		if self.bg then
			self.bg:SetBackdropColor(0, 0, 0, .25)
		else
			self.__texture:SetVertexColor(1, 1, 1)
		end
	end

	local function resetCloseButtonAnchor(button)
		if button.isSetting then return end
		button.isSetting = true
		button:ClearAllPoints()
		button:SetPoint("TOPRIGHT", button.__owner, "TOPRIGHT", button.__xOffset, button.__yOffset)
		button.isSetting = nil
	end
	function B:ReskinClose(parent, xOffset, yOffset, override)
		parent = parent or self:GetParent()
		xOffset = xOffset or -6
		yOffset = yOffset or -6

		if not override then
			self:ClearAllPoints()
			self:SetPoint("TOPRIGHT", parent, "TOPRIGHT", xOffset, yOffset)
			self.__owner = parent
			self.__xOffset = xOffset
			self.__yOffset = yOffset
			hooksecurefunc(self, "SetPoint", resetCloseButtonAnchor)
		end

		self:SetSize(18, 18)

		B.StripTextures(self, 99)
		B.ReskinButton(self)
		B.SetupTexture(self, "close")

		self:SetDisabledTexture(DB.bdTex)
		local dis = self:GetDisabledTexture()
		dis:SetVertexColor(0, 0, 0, .5)
		dis:SetDrawLayer("OVERLAY")
		dis:SetInside(self.__bg)
	end

	-- Handle editbox
	function B:ReskinInput(height, width)
		B.CleanTextures(self)

		if height then self:SetHeight(height) end
		if width then self:SetWidth(width) end

		local bg = B.CreateBDFrame(self, 0, true)
		B.UpdateSize(bg, -3, 0, -3, 0)
		self.__bg = bg
	end

	-- Handle arrows
	function B:SetupArrow(direction)
		self:SetTexture(DB.arrowTex..direction)
	end

	function B:SetupTexture(direction)
		if self.__texture then return end

		local tex = self:CreateTexture(nil, "ARTWORK")
		tex:SetAllPoints()
		if direction == "close" then
			tex:SetTexture(DB.closeTex)
		else
			tex:SetTexture(DB.arrowTex..direction)
		end
		self.__texture = tex

		self:HookScript("OnEnter", B.Texture_OnEnter)
		self:HookScript("OnLeave", B.Texture_OnLeave)
	end

	function B:ReskinArrow(direction, size)
		self:SetSize(size or 18, size or 18)

		B.StripTextures(self, 99)
		B.ReskinButton(self)
		B.SetupTexture(self, direction)

		self:SetDisabledTexture(DB.bdTex)
		local dis = self:GetDisabledTexture()
		dis:SetVertexColor(0, 0, 0, .5)
		dis:SetDrawLayer("OVERLAY")
		dis:SetInside(self.__bg)
	end

	function B:ReskinFilterReset()
		B.StripTextures(self)
		B.UpdatePoint(self, "CENTER", self:GetParent(), "TOP", 0, 0)

		local tex = self:CreateTexture(nil, "ARTWORK")
		tex:SetTexture(DB.closeTex)
		tex:SetVertexColor(1, 0, 0)
		tex:SetAllPoints()
	end

	function B:ReskinFilterButton()
		B.StripTextures(self)
		B.ReskinButton(self)

		if self.Text then
			B.UpdatePoint(self.Text, "CENTER", self, "CENTER", 0, 0)
		end
		if self.ResetButton then
			B.ReskinFilterReset(self.ResetButton)
		end
		if self.Icon then
			self.Icon:SetTexture(DB.arrowTex.."right")
			self.Icon:SetPoint("RIGHT")
			self.Icon:SetSize(14, 14)
		end

		local tex = self:CreateTexture(nil, "ARTWORK")
		tex:SetTexture(DB.arrowTex.."right")
		tex:SetPoint("RIGHT", -3, 0)
		tex:SetSize(16, 16)
		self.__texture = tex
	end

	function B:ReskinNavBar()
		if self.navBarStyled then return end

		B.StripTextures(self, 99)

		local homeButton = self.homeButton
		B.ReskinButton(homeButton)

		local overflowButton = self.overflowButton
		B.ReskinButton(overflowButton)
		B.SetupTexture(overflowButton, "left")

		self.navBarStyled = true
	end

	-- Handle checkbox and radio
	function B:ReskinCheck(forceSaturation)
		B.StripTextures(self)

		local bg = B.CreateBDFrame(self, 0, true)
		bg:SetInside(self, 4, 4)
		self.bg = bg

		B.ReskinHLTex(self, bg, true)

		local check = self:GetCheckedTexture()
		check:SetAtlas("checkmark-minimal")
		check:SetDesaturated(true)
		check:SetTexCoord(0, 1, 0, 1)
		check:SetVertexColor(cr, cg, cb)

		self.forceSaturation = forceSaturation
	end

	function B:ReskinRadio()
		B.StripTextures(self)

		local bg = B.CreateBDFrame(self, 0, true)
		bg:SetInside(self, 2, 2)
		self.bg = bg

		self:SetCheckedTexture(DB.bdTex)
		local ch = self:GetCheckedTexture()
		ch:SetInside(bg)
		ch:SetVertexColor(cr, cg, cb, .5)

		self:HookScript("OnEnter", Menu_OnEnter)
		self:HookScript("OnLeave", Menu_OnLeave)
	end

	-- Color swatch
	function B:ReskinColorSwatch()
		local icon

		if self.Color then
			icon = self.Color
			icon:SetTexture(DB.bdTex)
		else
			self:SetNormalTexture(DB.bdTex)
			icon = self:GetNormalTexture()
		end

		icon:SetInside(nil, 2, 2)

		local bg = B.GetObject(self, "SwatchBg")
		bg:SetColorTexture(0, 0, 0, 1)
		bg:SetOutside(icon)

		--if self.InnerBorder then
	end

	-- Handle slider
	function B:ReskinSlider(vertical)
		B.StripTextures(self)

		local bg = B.CreateBDFrame(self, 0, true)
		B.UpdateSize(bg, 14, -2, -15, 3)

		local thumb = self:GetThumbTexture()
		thumb:SetTexture(DB.sparkTex)
		thumb:SetBlendMode("ADD")
		if vertical then thumb:SetRotation(math.rad(90)) end

		local bar = CreateFrame("StatusBar", nil, bg)
		bar:SetStatusBarTexture(DB.normTex)
		bar:SetStatusBarColor(1, .8, 0, .5)
		if vertical then
			bar:SetPoint("BOTTOMLEFT", bg, C.mult, C.mult)
			bar:SetPoint("BOTTOMRIGHT", bg, -C.mult, C.mult)
			bar:SetPoint("TOP", thumb, "CENTER")
			bar:SetOrientation("VERTICAL")
		else
			bar:SetPoint("TOPLEFT", bg, C.mult, -C.mult)
			bar:SetPoint("BOTTOMLEFT", bg, C.mult, C.mult)
			bar:SetPoint("RIGHT", thumb, "CENTER")
		end
	end

	local function reskinStepper(stepper, direction)
		stepper:SetSize(20, 20)

		B.StripTextures(stepper)
		B.SetupTexture(stepper, direction)
	end

	function B:ReskinStepperSlider(minimal)
		B.StripTextures(self)
		reskinStepper(self.Back, "left")
		reskinStepper(self.Forward, "right")
		self.Slider:DisableDrawLayer("ARTWORK")

		local thumb = self.Slider.Thumb
		thumb:SetTexture(DB.sparkTex)
		thumb:SetBlendMode("ADD")
		thumb:SetSize(20, 30)

		local bg = B.CreateBDFrame(self.Slider, 0, true)
		local offset = minimal and 10 or 13
		bg:SetPoint("TOPLEFT", 10, -offset)
		bg:SetPoint("BOTTOMRIGHT", -10, offset)
		local bar = CreateFrame("StatusBar", nil, bg)
		bar:SetStatusBarTexture(DB.normTex)
		bar:SetStatusBarColor(1, .8, 0, .5)
		bar:SetPoint("TOPLEFT", bg, C.mult, -C.mult)
		bar:SetPoint("BOTTOMLEFT", bg, C.mult, C.mult)
		bar:SetPoint("RIGHT", thumb, "CENTER")
	end

	-- Handle collapse
	local function updateCollapseTexture(texture, collapsed)
		local atlas = collapsed and "Soulbinds_Collection_CategoryHeader_Expand" or "Soulbinds_Collection_CategoryHeader_Collapse"
		texture:SetAtlas(atlas, true)
	end

	local function resetCollapseTexture(self, texture)
		if self.settingTexture then return end
		self.settingTexture = true
		self:SetNormalTexture(0)

		if texture and texture ~= "" then
			if string.find(texture, "Plus") or string.find(texture, "[Cc]losed") then
				self.__texture:DoCollapse(true)
			elseif string.find(texture, "Minus") or string.find(texture, "[Oo]pen") then
				self.__texture:DoCollapse(false)
			end
			self.bg:Show()
		else
			self.bg:Hide()
		end
		self.settingTexture = nil
	end

	function B:ReskinCollapse(isAtlas)
		B.CleanTextures(self)

		local bg = B.CreateBDFrame(self, 0, true)
		bg:SetSize(14, 14)
		B.UpdatePoint(bg, "LEFT", self:GetNormalTexture(), "LEFT", 0, 0)
		self.bg = bg

		self.__texture = bg:CreateTexture(nil, "OVERLAY")
		self.__texture:SetPoint("CENTER")
		self.__texture.DoCollapse = updateCollapseTexture

		self:HookScript("OnEnter", B.Texture_OnEnter)
		self:HookScript("OnLeave", B.Texture_OnLeave)
		if isAtlas then
			hooksecurefunc(self, "SetNormalAtlas", resetCollapseTexture)
		else
			hooksecurefunc(self, "SetNormalTexture", resetCollapseTexture)
		end
	end

	local buttonNames = {"MaximizeButton", "MinimizeButton"}
	function B:ReskinMinMax()
		for _, name in next, buttonNames do
			local button = self[name]
			if button then
				button:ClearAllPoints()
				button:SetPoint("CENTER", -3, 0)
				button:SetHitRectInsets(1, 1, 1, 1)
				B.ReskinArrow(button, "max")

				if name == "MaximizeButton" then
					button.__texture:SetTexture(DB.arrowTex.."max")
				else
					button.__texture:SetTexture(DB.arrowTex.."min")
				end
			end
		end
	end

	function B:ReskinSearchList()
		B.StripTextures(self)
		local bg = B.CreateBDFrame(self, .25)
		bg:SetInside()

		local icon = self.icon or self.Icon
		if icon then
			B.ReskinIcon(icon)
		end

		B.ReskinHLTex(self, bg, true)
	end

	function B:AffixesSetup()
		local list = self.AffixesContainer and self.AffixesContainer.Affixes or self.Affixes
		if not list then return end

		for _, frame in ipairs(list) do
			frame.Border:SetTexture("")
			frame.Portrait:SetTexture("")
			if not frame.bg then
				frame.bg = B.ReskinIcon(frame.Portrait)
			end

			if frame.info then
				frame.Portrait:SetTexture(CHALLENGE_MODE_EXTRA_AFFIX_INFO[frame.info.key].texture)
			elseif frame.affixID then
				local _, _, filedataid = C_ChallengeMode.GetAffixInfo(frame.affixID)
				frame.Portrait:SetTexture(filedataid)
			end
		end
	end

	-- Role Icons
	local GroupRoleTex = {
		TANK = "groupfinder-icon-role-micro-tank",
		HEALER = "groupfinder-icon-role-micro-heal",
		DAMAGER = "groupfinder-icon-role-micro-dps",
		DPS = "groupfinder-icon-role-micro-dps",
	}

	function B:ReskinSmallRole(role)
		self:SetTexCoord(0, 1, 0, 1)
		self:SetAtlas(GroupRoleTex[role])
	end

	function B:ReskinRole()
		if self.background then self.background:SetTexture("") end

		local cover = self.cover or self.Cover
		if cover then cover:SetTexture("") end

		local checkButton = self.checkButton or self.CheckButton or self.CheckBox or self.Checkbox
		if checkButton then
			checkButton:SetFrameLevel(self:GetFrameLevel() + 2)
			checkButton:SetPoint("BOTTOMLEFT", -2, -2)
			B.ReskinCheck(checkButton)
		end
	end
end

-- GUI elements
do
	function B:CreateButton(width, height, text, fontSize)
		local bu = CreateFrame("Button", nil, self, "BackdropTemplate")
		bu:SetSize(width, height)
		if type(text) == "boolean" then
			B.PixelIcon(bu, fontSize, true)
		else
			B.ReskinButton(bu)
			bu.text = B.CreateFS(bu, fontSize or 14, text, true)
		end

		return bu
	end

	function B:CreateCheckBox()
		local cb = CreateFrame("CheckButton", nil, self, "InterfaceOptionsBaseCheckButtonTemplate")
		cb:SetScript("OnClick", nil) -- reset onclick handler
		B.ReskinCheck(cb)

		cb.Type = "CheckBox"
		return cb
	end

	local function editBoxClearFocus(self)
		self:ClearFocus()
	end

	function B:CreateEditBox(width, height)
		local eb = CreateFrame("EditBox", nil, self)
		eb:SetSize(width, height)
		eb:SetAutoFocus(false)
		eb:SetTextInsets(5, 5, 0, 0)
		B.SetFontSize(eb, DB.Font[2]+2)
		eb.bg = B.CreateBDFrame(eb, 0, true)
		eb.bg:SetAllPoints()
		eb:SetScript("OnEscapePressed", editBoxClearFocus)
		eb:SetScript("OnEnterPressed", editBoxClearFocus)

		eb.Type = "EditBox"
		return eb
	end

	local function optOnClick(self)
		PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK)
		local opt = self.__owner.options
		for i = 1, #opt do
			if self == opt[i] then
				opt[i]:SetBackdropColor(1, .8, 0, .25)
				opt[i].selected = true
			else
				opt[i]:SetBackdropColor(0, 0, 0, .25)
				opt[i].selected = false
			end
		end
		self.__owner.Text:SetText(self.text)
		self:GetParent():Hide()
	end

	local function optOnEnter(self)
		if self.selected then return end
		self:SetBackdropColor(1, 1, 1, .25)
	end

	local function optOnLeave(self)
		if self.selected then return end
		self:SetBackdropColor(0, 0, 0)
	end

	local function buttonOnShow(self)
		self.__list:Hide()
	end

	local function buttonOnClick(self)
		PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK)
		B:TogglePanel(self.__list)
	end

	function B:CreateDropDown(width, height, data)
		local dd = CreateFrame("Frame", nil, self, "BackdropTemplate")
		dd:SetSize(width, height)
		B.CreateBD(dd)
		dd:SetBackdropBorderColor(1, 1, 1, .25)
		dd.Text = B.CreateFS(dd, 14, "", false, "LEFT", 5, 0)
		dd.Text:SetPoint("RIGHT", -5, 0)
		dd.options = {}

		local bu = CreateFrame("Button", nil, dd)
		bu:SetPoint("RIGHT", -5, 0)
		B.ReskinArrow(bu, "down")
		bu:SetSize(18, 18)
		local list = CreateFrame("Frame", nil, dd, "BackdropTemplate")
		list:SetPoint("TOP", dd, "BOTTOM", 0, -2)
		RaiseFrameLevel(list)
		B.CreateBD(list, 1)
		list:SetBackdropBorderColor(1, 1, 1, .25)
		list:Hide()
		bu.__list = list
		bu:SetScript("OnShow", buttonOnShow)
		bu:SetScript("OnClick", buttonOnClick)
		dd.button = bu

		local opt, index = {}, 0
		for i, j in pairs(data) do
			opt[i] = CreateFrame("Button", nil, list, "BackdropTemplate")
			opt[i]:SetPoint("TOPLEFT", 4, -4 - (i-1)*(height+2))
			opt[i]:SetSize(width - 8, height)
			B.CreateBD(opt[i])
			local text = B.CreateFS(opt[i], 14, j, false, "LEFT", 5, 0)
			text:SetPoint("RIGHT", -5, 0)
			opt[i].text = j
			opt[i].index = i
			opt[i].__owner = dd
			opt[i]:SetScript("OnClick", optOnClick)
			opt[i]:SetScript("OnEnter", optOnEnter)
			opt[i]:SetScript("OnLeave", optOnLeave)

			dd.options[i] = opt[i]
			index = index + 1
		end
		list:SetSize(width, index*(height+2) + 6)

		dd.Type = "DropDown"
		return dd
	end

	local function updatePicker()
		local swatch = ColorPickerFrame.__swatch
		local r, g, b = ColorPickerFrame:GetColorRGB()
		r = B:Round(r, 2)
		g = B:Round(g, 2)
		b = B:Round(b, 2)
		swatch.tex:SetVertexColor(r, g, b)
		swatch.color.r, swatch.color.g, swatch.color.b = r, g, b
	end

	local function cancelPicker()
		local swatch = ColorPickerFrame.__swatch
		local r, g, b = ColorPickerFrame:GetPreviousValues()
		swatch.tex:SetVertexColor(r, g, b)
		swatch.color.r, swatch.color.g, swatch.color.b = r, g, b
	end

	local function openColorPicker(self)
		local r, g, b = self.color.r, self.color.g, self.color.b
		ColorPickerFrame.__swatch = self
		ColorPickerFrame.swatchFunc = updatePicker
		ColorPickerFrame.previousValues = {r = r, g = g, b = b}
		ColorPickerFrame.cancelFunc = cancelPicker
		ColorPickerFrame.Content.ColorPicker:SetColorRGB(r, g, b)
		ColorPickerFrame:Show()
	end

	local function GetSwatchTexColor(tex)
		local r, g, b = tex:GetVertexColor()
		r = B:Round(r, 2)
		g = B:Round(g, 2)
		b = B:Round(b, 2)
		return r, g, b
	end

	local function resetColorPicker(swatch)
		local defaultColor = swatch.__default
		if defaultColor then
			ColorPickerFrame.Content.ColorPicker:SetColorRGB(defaultColor.r, defaultColor.g, defaultColor.b)
		end
	end

	local whiteColor = {r=1, g=1, b=1}
	function B:CreateColorSwatch(name, color)
		color = color or whiteColor

		local swatch = CreateFrame("Button", nil, self, "BackdropTemplate")
		swatch:SetSize(18, 18)
		B.CreateBD(swatch, 1)
		if name then
			swatch.text = B.CreateFS(swatch, 14, name, false, "LEFT", 26, 0)
		end
		local tex = swatch:CreateTexture(nil, "ARTWORK")
		tex:SetInside()
		tex:SetTexture(DB.bdTex)
		tex:SetVertexColor(color.r, color.g, color.b)
		tex.GetColor = GetSwatchTexColor

		swatch.tex = tex
		swatch.color = color
		swatch:SetScript("OnClick", openColorPicker)
		swatch:SetScript("OnDoubleClick", resetColorPicker)

		return swatch
	end

	local function updateSliderEditBox(self)
		local slider = self.__owner
		local minValue, maxValue = slider:GetMinMaxValues()
		local text = tonumber(self:GetText())
		if not text then return end
		text = math.min(maxValue, text)
		text = math.max(minValue, text)
		slider:SetValue(text)
		self:SetText(text)
		self:ClearFocus()
	end

	local function resetSliderValue(self)
		local slider = self.__owner
		if slider.__default then
			slider:SetValue(slider.__default)
		end
	end

	function B:CreateSlider(name, minValue, maxValue, step, x, y, width)
		local slider = CreateFrame("Slider", nil, self, "OptionsSliderTemplate")
		slider:SetPoint("TOPLEFT", x, y)
		slider:SetWidth(width or 200)
		slider:SetMinMaxValues(minValue, maxValue)
		slider:SetValueStep(step)
		slider:SetObeyStepOnDrag(true)
		slider:SetHitRectInsets(0, 0, 0, 0)
		B.ReskinSlider(slider)

		slider.Low:SetText(minValue)
		slider.Low:SetPoint("TOPLEFT", slider, "BOTTOMLEFT", 10, -2)
		slider.High:SetText(maxValue)
		slider.High:SetPoint("TOPRIGHT", slider, "BOTTOMRIGHT", -10, -2)
		slider.Text:ClearAllPoints()
		slider.Text:SetPoint("CENTER", 0, 25)
		slider.Text:SetText(name)
		slider.Text:SetTextColor(1, .8, 0)
		slider.value = B.CreateEditBox(slider, 50, 20)
		slider.value:SetPoint("TOP", slider, "BOTTOM")
		slider.value:SetJustifyH("CENTER")
		slider.value.__owner = slider
		slider.value:SetScript("OnEnterPressed", updateSliderEditBox)

		slider.clicker = CreateFrame("Button", nil, slider)
		slider.clicker:SetAllPoints(slider.Text)
		slider.clicker.__owner = slider
		slider.clicker:SetScript("OnDoubleClick", resetSliderValue)

		return slider
	end

	function B:TogglePanel(frame)
		if frame:IsShown() then
			frame:Hide()
		else
			frame:Show()
		end
	end
end

-- Add API
do
	local function WatchPixelSnap(frame, snap)
		if (frame and not frame:IsForbidden()) and frame.PixelSnapDisabled and snap then
			frame.PixelSnapDisabled = nil
		end
	end

	local function DisablePixelSnap(frame)
		if (frame and not frame:IsForbidden()) and not frame.PixelSnapDisabled then
			if frame.SetSnapToPixelGrid then
				frame:SetSnapToPixelGrid(false)
				frame:SetTexelSnappingBias(0)
			elseif frame.GetStatusBarTexture then
				local texture = frame:GetStatusBarTexture()
				if type(texture) == "table" and texture.SetSnapToPixelGrid then
					texture:SetSnapToPixelGrid(false)
					texture:SetTexelSnappingBias(0)
				end
			end

			frame.PixelSnapDisabled = true
		end
	end

	local function SetInside(frame, anchor, xOffset, yOffset, anchor2)
		xOffset = xOffset or C.mult
		yOffset = yOffset or C.mult
		anchor = anchor or frame:GetParent()

		DisablePixelSnap(frame)
		frame:ClearAllPoints()
		frame:SetPoint("TOPLEFT", anchor, "TOPLEFT", xOffset, -yOffset)
		frame:SetPoint("BOTTOMRIGHT", anchor2 or anchor, "BOTTOMRIGHT", -xOffset, yOffset)
	end

	local function SetOutside(frame, anchor, xOffset, yOffset, anchor2)
		xOffset = xOffset or C.mult
		yOffset = yOffset or C.mult
		anchor = anchor or frame:GetParent()

		DisablePixelSnap(frame)
		frame:ClearAllPoints()
		frame:SetPoint("TOPLEFT", anchor, "TOPLEFT", -xOffset, yOffset)
		frame:SetPoint("BOTTOMRIGHT", anchor2 or anchor, "BOTTOMRIGHT", xOffset, -yOffset)
	end

	local function HideBackdrop(frame)
		if frame.NineSlice then frame.NineSlice:SetAlpha(0) end
		if frame.SetBackdrop then frame:SetBackdrop(nil) end
	end

	local function addapi(object)
		local mt = getmetatable(object).__index
		if not object.SetInside then mt.SetInside = SetInside end
		if not object.SetOutside then mt.SetOutside = SetOutside end
		if not object.HideBackdrop then mt.HideBackdrop = HideBackdrop end
		if not object.DisabledPixelSnap then
			if mt.SetTexture then hooksecurefunc(mt, "SetTexture", DisablePixelSnap) end
			if mt.SetTexCoord then hooksecurefunc(mt, "SetTexCoord", DisablePixelSnap) end
			if mt.CreateTexture then hooksecurefunc(mt, "CreateTexture", DisablePixelSnap) end
			if mt.SetVertexColor then hooksecurefunc(mt, "SetVertexColor", DisablePixelSnap) end
			if mt.SetColorTexture then hooksecurefunc(mt, "SetColorTexture", DisablePixelSnap) end
			if mt.SetSnapToPixelGrid then hooksecurefunc(mt, "SetSnapToPixelGrid", WatchPixelSnap) end
			if mt.SetStatusBarTexture then hooksecurefunc(mt, "SetStatusBarTexture", DisablePixelSnap) end
			mt.DisabledPixelSnap = true
		end
	end

	local handled = {["Frame"] = true}
	local object = CreateFrame("Frame")
	addapi(object)
	addapi(object:CreateTexture())
	addapi(object:CreateMaskTexture())

	object = EnumerateFrames()
	while object do
		if not object:IsForbidden() and not handled[object:GetObjectType()] then
			addapi(object)
			handled[object:GetObjectType()] = true
		end

		object = EnumerateFrames(object)
	end
end

-- 自定义
do
	function B:GetObject(key)
		local frameName = self.GetName and self:GetName()
		return self[key] or (frameName and _G[frameName..key])
	end

	function B:PrintTextures(name)
		if self.GetRegions then
			for index, region in pairs {self:GetRegions()} do
				local regionName = region:GetDebugName()
				if string.find(regionName, name) then
					print("Regions:", index, regionName)
					break
				end
			end
		else
			for index, child in pairs {self:GetChildren()} do
				local childName = child:GetDebugName()
				if string.find(childName, name) then
					print("Children:", index, childName)
					break
				end
			end
		end
	end

	function B.UpdatePoint(f1, p1, f2, p2, x, y)
		if not f1 then return end

		f1:ClearAllPoints()
		f1:SetPoint(p1, f2, p2, x, y)
	end

	function B.UpdateSize(f1, x1, y1, x2, y2, f2)
		if not f1 then return end

		local f = f1:GetParent()
		f1:ClearAllPoints()
		f1:SetPoint("TOPLEFT", f2 or f, x1, y1)
		f1:SetPoint("BOTTOMRIGHT", f2 or f, x2, y2)
	end

	local headers = {"Header", "header"}
	local portraits = {"Portrait", "portrait"}
	local closes = {"CloseButton", "Close"}
	function B:ReskinFrame(killType)
		if killType == "none" then
			B.CleanTextures(self)
		else
			B.StripTextures(self, killType or 99)
		end

		local bg = B.SetBD(self, 0, 0, 0, 0)
		for _, key in pairs(headers) do
			local frameHeader = B.GetObject(self, key)
			if frameHeader then
				B.StripTextures(frameHeader)
				B.UpdatePoint(frameHeader, "TOP", bg, "TOP", 0, 5)
			end
		end
		for _, key in pairs(portraits) do
			local framePortrait = B.GetObject(self, key)
			if framePortrait then framePortrait:SetAlpha(0) end
		end
		for _, key in pairs(closes) do
			local closeButton = B.GetObject(self, key)
			if closeButton and closeButton:IsObjectType("Button") then
				B.ReskinClose(closeButton, bg)
			end
		end

		return bg
	end

	local barWords = {
		"Label",
		"label",
		"Rank",
		"RankText",
		"rankText",
		"Text",
		"text",
	}

	function B:ReskinStatusBar(noCC, shadow)
		B.StripTextures(self)
		if shadow then
			B.SetBD(self)
		else
			B.CreateBDFrame(self, .25)
		end

		self:SetStatusBarTexture(DB.normTex)
		if not noCC then
			self:SetStatusBarColor(cr, cg, cb, C.alpha)
		end

		for _, key in pairs(barWords) do
			local text = B.GetObject(self, key)
			if text then
				text:SetJustifyH("CENTER")
				text:ClearAllPoints()
				text:SetPoint("CENTER", self, "CENTER", 1, 0)
			end
		end
	end

	function B:ReskinTTStatusBar()
		self.StatusBar:ClearAllPoints()
		self.StatusBar:SetPoint("BOTTOMLEFT", self, "TOPLEFT", C.mult, C.margin)
		self.StatusBar:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -C.mult, C.margin)
		self.StatusBar:SetHeight(6)

		B.ReskinStatusBar(self.StatusBar, true, true)
	end

	function B:ReskinTooltip()
		if not self then
			if DB.isDeveloper then print("Unknown tooltip spotted.") end
			return
		end
		if self:IsForbidden() then return end
		self:SetScale(C.db["Tooltip"]["Scale"])

		if not self.tipStyled then
			self:HideBackdrop()
			self:DisableDrawLayer("BACKGROUND")
			self.bg = B.SetBD(self, 0, 0, 0, 0)
			self.bg:SetFrameLevel(self:GetFrameLevel())
			B.SetBorderColor(self.bg)

			if self.StatusBar then
				B.ReskinTTStatusBar(self)
			end

			self.tipStyled = true
		end

		B.SetBorderColor(self.bg)

		if not C.db["Tooltip"]["ItemQuality"] then return end

		local data = self.GetTooltipData and self:GetTooltipData()
		if data then
			local link = data.guid and C_Item.GetItemLinkByGUID(data.guid) or data.hyperlink
			if link then
				local quality = select(3, C_Item.GetItemInfo(link))
				local color = DB.QualityColors[quality or 1]
				if color then
					self.bg:SetBackdropBorderColor(color.r, color.g, color.b)
				end
			end
		end
	end

	function B:ReskinSideTab()
		if not self or not self.GetNormalTexture then return end

		self:SetSize(32, 32)
		self:GetRegions():Hide()

		local icon = self:GetNormalTexture()
		local icbg = B.ReskinIcon(icon)
		B.ReskinHLTex(self, icbg)
		B.ReskinCPTex(self, icbg)
	end

	function B:ReskinFrameTab(index, tabName)
		local frameName = self:GetDebugName()
		local tab = frameName and frameName.."Tab"

		if tabName then tab = frameName and frameName..tabName end
		if not tab then return end

		for i = 1, index do
			local tabs = _G[tab..i]
			if tabs then
				if not tabs.styled then
					B.ReskinTab(tabs)

					tabs.styled = true
				end

				tabs:ClearAllPoints()
				if i == 1 then
					tabs:Point("TOPLEFT", frameName, "BOTTOMLEFT", 15, 1)
				else
					tabs:Point("LEFT", _G[tab..(i-1)], "RIGHT", -15, 0)
				end
			end
		end
	end

	function B:ReskinBGBorder(relativeTo, classColor)
		if not self then return end

		self:SetTexture(DB.bdTex)
		self:SetDrawLayer("BACKGROUND")

		if classColor then
			self:SetVertexColor(cr, cg, cb)
		end

		self:ClearAllPoints()
		self:SetAllPoints(relativeTo)
	end

	function B:ReskinHLTex(relativeTo, classColor, isColorTex)
		if not self then return end

		local r, g, b = 1, 1, 1
		if classColor then r, g, b = cr, cg, cb end

		local tex
		if self.SetHighlightTexture then
			self:SetHighlightTexture(DB.bdTex)
			tex = self:GetHighlightTexture()
		elseif self.SetNormalTexture then
			self:SetNormalTexture(DB.bdTex)
			tex = self:GetNormalTexture()
		elseif self.SetTexture then
			self:SetTexture(DB.bdTex)
			tex = self
		end

		if tex then
			if isColorTex then
				tex:SetColorTexture(r, g, b, .25)
			else
				tex:SetVertexColor(r, g, b, .25)
			end

			if relativeTo then
				tex:SetInside(relativeTo)
			end
		end
	end

	function B:ReskinCPTex(relativeTo)
		if not self then return end

		local checked = self.GetCheckedTexture and self:GetCheckedTexture()
		if checked then
			checked:SetVertexColor(1, 1, 1)
			B.ReskinBGBorder(checked, relativeTo)
		end

		local pushed = self.GetPushedTexture and self:GetPushedTexture()
		if pushed then
			pushed:SetVertexColor(0, 1, 1)
			B.ReskinBGBorder(pushed, relativeTo)
		end
	end

	function B:ReskinText(r, g, b, a, size)
		if not self then return end

		self:SetTextColor(r, g, b, a or 1)

		if size then
			if tonumber(size) then
				self:SetFontSize(size)
			else
				self:SetFontObject(size)
			end
		end
	end

	B.ReskinPortraitFrame = B.ReskinFrame
	B.StyleSearchButton = B.ReskinSearchList
	B.ReskinEditBox = B.ReskinInput
	B.Reskin = B.ReskinButton
end