local _, ns = ...
local B, C, L, DB = unpack(ns)

-- Math
do
	-- Numberize
	function B.Numb(n)
		local v, t = math.abs(n)
		if NDuiADB["NumberFormat"] == 1 then
			if v >= 1e12 then
				t = format("%.4ft", v / 1e12)
			elseif v >= 1e9 then
				t = format("%.3fb", v / 1e9)
			elseif v >= 1e6 then
				t = format("%.2fm", v / 1e6)
			elseif v >= 1e3 then
				t = format("%.1fk", v / 1e3)
			else
				t = format("%.0f", v)
			end
		elseif NDuiADB["NumberFormat"] == 2 then
			if v >= 1e12 then
				t = format("%.3f"..FOURTH_NUMBER, v / 1e12)
			elseif v >= 1e8 then
				t = format("%.2f"..THIRD_NUMBER, v / 1e8)
			elseif v >= 1e4 then
				t = format("%.1f"..SECOND_NUMBER, v / 1e4)
			else
				t = format("%.0f", v)
			end
		else
			t = format("%.0f", v)
		end

		if n < 0 then
			return "-"..t
		else
			return t
		end
	end

	function B.Perc(p, idp)
		idp = idp or 1
		return format("%."..idp.."f%%", p)
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
		return tonumber(string.match((guid or ""), "%-(%d-)%-%x-$"))
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

	function B.GetColor(colors)
		return colors.r, colors.g, colors.b
	end

	function B.ClassColor(class)
		local color = DB.ClassColors[class]
		if not color then return .5, .5, .5 end

		return color.r, color.g, color.b
	end

	function B.UnitColor(unit)
		local r, g, b = .5, .5, .5
		if UnitIsTapDenied(unit) then
			r, g, b = .5, .5, .5
		elseif UnitIsPlayer(unit) or UnitInPartyIsAI(unit) then
			local class = select(2, UnitClass(unit))
			if class then
				r, g, b = B.ClassColor(class)
			end
		else
			local reaction = UnitReaction(unit, "player")
			if reaction then
				local color = FACTION_BAR_COLORS[reaction]
				r, g, b = color.r, color.g, color.b
			end
			--r, g, b = UnitSelectionColor(unit, true)
		end

		return r, g, b
	end
end

-- Scan tooltip
do
	local iLvlDB = {}
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
				if lineData.itemLevel then
					slotData.iLvl = lineData.itemLevel
				elseif lineData.enchantID then
					slotData.enchantText = string.match(lineData.leftText, enchantString)
				elseif lineData.essenceIcon then -- heart of azeroth
					num = num + 1
					slotData.gems[num] = lineData.essenceIcon
					slotData.gemsColor[num] = lineData.leftColor
				elseif lineData.gemIcon then
					num = num + 1
					slotData.gems[num] = lineData.gemIcon
					slotData.gemsColor[num] = lineData.leftColor
				elseif lineData.socketType then
					num = num + 1
					slotData.gems[num] = format("Interface\\ItemSocketingFrame\\UI-EmptySocket-%s", lineData.socketType)
				end
			end

			return slotData
		else
			if not iLvlDB[link] then
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
					if lineData and lineData.itemLevel then
						iLvlDB[link] = lineData.itemLevel
						break
					end
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
		"BlackBackgroundHoist",
		"Border",
		"BorderBottom",
		"BorderBottomLeft",
		"BorderBottomRight",
		"BorderBox",
		"BorderCenter",
		"BorderContainer",
		"BorderFrame",
		"BorderGlow",
		"BorderLeft",
		"BorderRight",
		"BorderShadow",
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
		"DecorLeft",
		"DecorRight",
		"Delimiter1",
		"Delimiter2",
		"EmptyBackground",
		"End",
		"FilligreeOverlay",
		"GarrCorners",
		"IconMask",
		"IconOverlay",
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
		"NewActionTexture",
		"NineSlice",
		"Overlay",
		"OverlayKit",
		"Portrait",
		"PortraitContainer",
		"PortraitOverlay",
		"RecipientOverlay",
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
		"SlotArt",
		"SlotBackground",
		"Spark",
		"SparkGlow",
		"SpellBorder",
		"TabSpacer",
		"TabSpacer1",
		"TabSpacer2",
		"TitleContainer",
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
		"TopTileStreaks",
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
		"style",
		"topInset",
		"track",
		"trackBG",
		"PushedTexture",
		"NormalTexture",
	}

	function B:CleanTextures(isOverride)
		if self.SetBackdrop then self:SetBackdrop(nil) end
		if self.SetPushedTexture then self:SetPushedTexture(0) end
		if self.SetCheckedTexture then self:SetCheckedTexture(0) end
		if self.SetDisabledTexture then self:SetDisabledTexture(0) end
		if self.SetHighlightTexture then self:SetHighlightTexture(0) end
		if self.SetNormalTexture and not isOverride then self:SetNormalTexture(0) end

		for _, texture in pairs(blizzTextures) do
			local blizzTexture = B.GetObject(self, texture)
			if blizzTexture and type(blizzTexture) == "table" then
				if blizzTexture:IsObjectType("MaskTexture") then
					blizzTexture:Hide()
				elseif blizzTexture:IsObjectType("Texture") then
					blizzTexture:SetTexture(nil)
					blizzTexture:SetAtlas(nil)
					blizzTexture:SetAlpha(0)
				else
					B.StripTextures(blizzTexture, 99)
				end
			end
		end
	end

	function B:StripTextures(kill)
		B.CleanTextures(self)

		if self.GetRegions then
			for index, region in pairs {self:GetRegions()} do
				if region and not region.isIgnored then
					if region:IsObjectType("MaskTexture") then
						region:Hide()
					elseif region:IsObjectType("Texture") then
						if kill and type(kill) == "boolean" then
							B.HideObject(region)
						elseif tonumber(kill) then
							if kill == 0 then
								region:SetAlpha(0)
							elseif kill ~= index then
								region:SetTexture(nil)
								region:SetAtlas(nil)
								region:SetAlpha(0)
							end
						else
							region:SetTexture(nil)
							region:SetAtlas(nil)
						end
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
		self:SetShadowColor(0, 0, 0, 0)
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

	local colorList = {
		["class"] = {DB.r, DB.g, DB.b},
		["system"] = {1, 1, 0},
		["info"] = {0, 1, 1},
		["red"] = {1, 0, 0},
		["green"] = {0, 1, 0},
		["blue"] = {0, 0, 1},
	}

	function B:CreateFS(size, text, color, anchor, x, y)
		local fs = self:CreateFontString(nil, "OVERLAY")
		fs:SetFont(DB.Font[1], size, DB.Font[3])
		fs:SetShadowColor(0, 0, 0, 0)
		fs:SetNonSpaceWrap(true)
		fs:SetWordWrap(false)
		fs:SetText(text)

		if color and type(color) == "boolean" then
			fs:SetTextColor(DB.r, DB.g, DB.b)
		elseif color then
			fs:SetTextColor(unpack(colorList[color]))
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
			if self.color then
				r, g, b = unpack(colorList[self.color])
			end
			GameTooltip:AddLine(self.text, r,g,b, 1)
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
	function B:CreateGlowFrame()
		local frame = self
		if self:IsObjectType("Texture") then frame = self:GetParent() end

		local glow = CreateFrame("Frame", nil, frame)
		glow:SetFrameLevel(frame:GetFrameLevel())
		glow:SetOutside(self, 3, 3)

		return glow
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

		local tex = frame:CreateTexture(nil, "BACKGROUND")
		tex:SetInside(self)
		tex:SetTexture(DB.bgTex, true, true)
		tex:SetHorizTile(true)
		tex:SetVertTile(true)
		tex:SetBlendMode("ADD")

		self.__bgTex = tex
	end

	-- Backdrop shadow
	function B:CreateSD(size, isOverride)
		if not isOverride and not C.db["Skins"]["Shadow"] then return end
		if self.__shadow then return end

		local frame = self
		if self:IsObjectType("Texture") then frame = self:GetParent() end

		local sdSize = size or 4
		local shadow = CreateFrame("Frame", nil, frame, "BackdropTemplate")
		shadow:SetOutside(self, sdSize, sdSize)
		shadow:SetFrameLevel(frame:GetFrameLevel())
		shadow:SetBackdrop({edgeFile = DB.glowTex, edgeSize = sdSize})
		shadow:SetBackdropBorderColor(0, 0, 0, size and 1 or .5)

		self.__shadow = shadow

		return self.__shadow
	end
end

-- UI skins
do
	-- Setup backdrop
	C.frames = {}

	function B:SetBorderColor()
		if C.db["Skins"]["CustomBD"] then
			local color = C.db["Skins"]["CustomBDColor"]
			self:SetBackdropBorderColor(color.r, color.g, color.b)
			DB.QualityColors[-1] = {r = color.r, g = color.g, b = color.b}
		else
			self:SetBackdropBorderColor(0, 0, 0)
			DB.QualityColors[-1] = {r = 0, g = 0, b = 0}
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
		tex:SetInside(self)
		tex:SetColorTexture(.5, .5, .5, .25)

		return tex
	end

	-- Handle frame
	function B:CreateBDFrame(alpha, gradient, offset)
		local frame = self
		if self:IsObjectType("Texture") then frame = self:GetParent() end

		local bg = CreateFrame("Frame", nil, frame, "BackdropTemplate")
		bg:SetFrameLevel(frame:GetFrameLevel())
		bg:ClearAllPoints()

		local value = offset and offset * C.mult
		if value then
			bg:SetPoint("TOPLEFT", self, value, -value)
			bg:SetPoint("BOTTOMRIGHT", self, -value, value)
		else
			bg:SetAllPoints(self)
		end

		B.CreateBD(bg, alpha)
		if gradient then
			self.__gradient = B.CreateGradient(bg)
		end

		return bg
	end

	function B:CreateBG(x1, y1, x2, y2)
		local bg = B.CreateBDFrame(self)

		if self:IsObjectType("StatusBar") or self:IsObjectType("Texture") then
			B.UpdateSize(bg, -1)
		end

		if x1 then
			B.UpdateSize(bg, x1, y1, x2, y2)
		end

		B.CreateSD(bg)
		B.CreateTex(bg)

		return bg
	end

	-- Handle icons
	function B:ReskinIcon(isOutside)
		self:SetTexCoord(unpack(DB.TexCoord))

		if self.SetDrawLayer then
			self:SetDrawLayer("ARTWORK")
		end

		local bg = B.CreateBDFrame(self, .25, nil, -1)
		if isOutside then B.CreateSD(bg) end

		return bg
	end

	function B:PixelIcon(texture, highlight)
		self.bg = B.CreateBDFrame(self, .25)

		self.Icon = self:CreateTexture(nil, "ARTWORK")
		self.Icon:SetInside(self.bg)
		self.Icon:SetTexCoord(unpack(DB.TexCoord))

		if texture then
			local atlas = string.match(texture, "Atlas:(.+)$")
			if atlas then
				self.Icon:SetAtlas(atlas)
			else
				self.Icon:SetTexture(texture)
			end
		end
		if highlight and type(highlight) == "boolean" then
			self.HL = self:CreateTexture(nil, "HIGHLIGHT")
			self.HL:SetColorTexture(1, 1, 1, .25)
			self.HL:SetBlendMode("ADD")
			self.HL:SetInside(self.bg)
		end
	end

	function B:AuraIcon(highlight, noCooldown)
		B.PixelIcon(self, nil, highlight)
		B.CreateSD(self.bg)

		if not noCooldown then
			self.CD = CreateFrame("Cooldown", nil, self, "CooldownFrameTemplate")
			self.CD:SetFrameLevel(self:GetFrameLevel())
			self.CD:SetInside(self.bg)
			self.CD:SetReverse(true)
		end
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
		["error"] = -3,
		["uncollected"] = -4,
		["illusion"] = -4,
		["gray"] = Enum.ItemQuality.Poor,
		["white"] = Enum.ItemQuality.Common,
		["green"] = Enum.ItemQuality.Uncommon,
		["blue"] = Enum.ItemQuality.Rare,
		["purple"] = Enum.ItemQuality.Epic,
		["orange"] = Enum.ItemQuality.Legendary,
		["artifact"] = Enum.ItemQuality.Artifact,
		["account"] = Enum.ItemQuality.Heirloom,
		["epic"] = Enum.ItemQuality.Epic,
		["legendary"] = Enum.ItemQuality.Legendary,
	}
	local function updateIconBorderColorByAtlas(border, atlas)
		local atlasAbbr = atlas and string.match(atlas, "%-(%w+)$")
		local quality = atlasAbbr and AtlasToQuality[string.lower(atlasAbbr)]
		local color = DB.QualityColors[quality or -1]

		border.__owner.bg:SetBackdropBorderColor(color.r, color.g, color.b)
		if border.__owner.nf then
			border.__owner.nf:SetBackdropBorderColor(color.r, color.g, color.b)
		end
	end
	local function updateIconBorderColorByVertex(border, r, g, b)
		border.__owner.bg:SetBackdropBorderColor(r, g, b)
		if border.__owner.nf then
			border.__owner.nf:SetBackdropBorderColor(r, g, b)
		end
		border:Hide(true) -- fix icon border
	end
	local function resetIconBorderColor(border, texture)
		if not texture then
			B.SetBorderColor(border.__owner.bg)
			if border.__owner.nf then
				B.SetBorderColor(border.__owner.nf)
			end
		end
	end

	function B:ReskinBorder(needInit, useAtlas)
		if not self then return end

		self:SetAlpha(0)
		self.__owner = self:GetParent()

		if not self.__owner.bg then return end

		if useAtlas or self.__owner.useCircularIconBorder then -- for auction item display
			hooksecurefunc(self, "SetAtlas", updateIconBorderColorByAtlas)
			hooksecurefunc(self, "SetTexture", resetIconBorderColor)
			if needInit then
				self:SetAtlas(self:GetAtlas()) -- for border with color before hook
				self:SetTexture(self:GetTexture()) -- for border with color before hook
			end
		else
			hooksecurefunc(self, "SetVertexColor", updateIconBorderColorByVertex)
			if needInit then
				self:SetVertexColor(self:GetVertexColor()) -- for border with color before hook
			end
		end
		hooksecurefunc(self, "Hide", resetIconBorderColor)
		hooksecurefunc(self, "SetShown", resetIconBorderColor)
	end

	function B:ClassIconTexCoord(class)
		local tL, tR, tT, tB = unpack(CLASS_ICON_TCOORDS[class])
		self:SetTexCoord(tL + .025, tR - .025, tT + .025, tB - .025)
	end

	-- Handle statusbar
	function B:CreateSB(spark, bg, name)
		local bar = CreateFrame("StatusBar", name, self)
		bar:SetFrameLevel(self:GetFrameLevel())
		bar:SetStatusBarTexture(DB.normTex)
		bar:SetStatusBarColor(DB.r, DB.g, DB.b)

		bar.bd = B.CreateBG(bar)

		if bg then
			bar.bg = bar:CreateTexture(nil, "BORDER")
			bar.bg:SetTexture(DB.normTex)
			bar.bg:SetInside(bar.bd)
			bar.bg.multiplier = .25
		end

		if spark then
			bar.Spark = bar:CreateTexture(nil, "OVERLAY")
			bar.Spark:SetTexture(DB.sparkTex)
			bar.Spark:SetBlendMode("ADD")
			bar.Spark:SetAlpha(1)
			bar.Spark:SetPoint("TOP", bar:GetStatusBarTexture(), "TOPRIGHT", 0, 15)
			bar.Spark:SetPoint("BOTTOM", bar:GetStatusBarTexture(), "BOTTOMRIGHT", 0, -15)
		end

		return bar
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
					ticks[i]:SetColorTexture(0, 0, 0)
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
			self.__gradient:SetColorTexture(DB.r, DB.g, DB.b, .25)
		else
			self.__bg:SetBackdropColor(DB.r, DB.g, DB.b, .25)
		end
	end
	local function Button_OnLeave(self)
		if self.__gradient then
			self.__gradient:SetColorTexture(.5, .5, .5, .25)
		else
			self.__bg:SetBackdropColor(0, 0, 0, 0)
		end
	end

	function B:ReskinButton(isOverride, isOutside)
		B.CleanTextures(self, isOverride)

		self.__bg = B.CreateBDFrame(self, 0, true)
		if isOutside then B.CreateSD(self.__bg) end

		self:HookScript("OnEnter", Button_OnEnter)
		self:HookScript("OnLeave", Button_OnLeave)
	end

	local function Menu_OnEnter(self)
		self.bg:SetBackdropBorderColor(DB.r, DB.g, DB.b)
	end
	local function Menu_OnLeave(self)
		B.SetBorderColor(self.bg)
	end
	local function Menu_OnMouseUp(self)
		self.bg:SetBackdropColor(0, 0, 0, C.db["Skins"]["SkinAlpha"])
	end
	local function Menu_OnMouseDown(self)
		self.bg:SetBackdropColor(DB.r, DB.g, DB.b, .25)
	end

	function B:ReskinMenuButton()
		B.StripTextures(self)
		self.bg = B.CreateBG(self)
		self:SetScript("OnEnter", Menu_OnEnter)
		self:SetScript("OnLeave", Menu_OnLeave)
		self:HookScript("OnMouseUp", Menu_OnMouseUp)
		self:HookScript("OnMouseDown", Menu_OnMouseDown)
	end

	-- Handle tabs
	function B:ReskinTab(isInside)
		B.CleanTextures(self)
		self:DisableDrawLayer("BACKGROUND")

		local bg = isInside and B.CreateBDFrame(self, 0, true) or B.CreateBG(self)
		B.UpdateSize(bg, 8, -2, -8, 4)
		self.bg = bg

		B.ReskinHLTex(self, bg, true)
		B.ResetTabAnchor(self)
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
		thumb.__gradient:SetColorTexture(DB.r, DB.g, DB.b, .25)
	end
	local function Thumb_OnLeave(self)
		local thumb = self.thumb or self
		thumb.__gradient:SetColorTexture(.5, .5, .5, .25)
	end

	local function updateScrollArrow(self)
		local arrow = self.__owner or self
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
			hooksecurefunc(self.Texture, "SetAtlas", updateScrollArrow)
		else
			hooksecurefunc(self, "Enable", updateScrollArrow)
			hooksecurefunc(self, "Disable", updateScrollArrow)
		end
	end

	function B:ReskinScroll()
		B.StripTextures(self, 99)

		local thumb
		if self.GetThumb then
			local track = self.Track
			if track then
				track:DisableDrawLayer("ARTWORK")
			end

			thumb = self:GetThumb()
			thumb:DisableDrawLayer("ARTWORK")
			thumb:DisableDrawLayer("BACKGROUND")

			thumb.bg = B.CreateBDFrame(thumb, 0, true)
			thumb:HookScript("OnEnter", Thumb_OnEnter)
			thumb:HookScript("OnLeave", Thumb_OnLeave)

			self.Back:SetParent(thumb)
			self.Forward:SetParent(thumb)
			reskinScrollArrow(self.Back, "up")
			reskinScrollArrow(self.Forward, "down")
		else
			local parent = self:GetParent()
			if parent then
				B.StripTextures(parent, 99)
			end

			local up, down = self:GetChildren()
			reskinScrollArrow(up, "up")
			reskinScrollArrow(down, "down")

			thumb = self:GetThumbTexture()
			B.StripTextures(thumb, 99)

			thumb.bg = B.CreateBDFrame(thumb, 0, true)
			B.UpdateSize(thumb.bg, 4, -2, -4, 2, thumb)

			self.thumb = thumb
			self:HookScript("OnEnter", Thumb_OnEnter)
			self:HookScript("OnLeave", Thumb_OnLeave)
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
				self.bg:SetBackdropColor(DB.r, DB.g, DB.b, .25)
			else
				self.__texture:SetVertexColor(DB.r, DB.g, DB.b)
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
	function B:ReskinClose(parent, xOffset, yOffset, isOverride)
		parent = parent or self:GetParent()
		xOffset = xOffset or -6
		yOffset = yOffset or -6

		if not isOverride then
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

		local dis = self:GetDisabledTexture()
		dis:SetColorTexture(0, 0, 0, .5)
		dis:SetDrawLayer("OVERLAY")
		dis:SetInside(self.__bg)
	end

	-- Handle editbox
	function B:ReskinInput(height, width)
		self:DisableDrawLayer("BACKGROUND")
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

		local dis = self:GetDisabledTexture()
		dis:SetColorTexture(0, 0, 0, .5)
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
	function B:ReskinCheck(offset)
		B.StripTextures(self)

		self.bg = B.CreateBDFrame(self, 0, true, offset or 4)

		B.ReskinHLTex(self, self.bg, true)

		local check = self:GetCheckedTexture()
		check:SetAtlas("checkmark-minimal")
		check:SetDesaturated(true)
		check:SetTexCoord(0, 1, 0, 1)
		check:SetVertexColor(DB.r, DB.g, DB.b)
	end

	-- Color swatch
	function B:ReskinColorSwatch()
		local bg = B.GetObject(self, "SwatchBg")
		bg:SetColorTexture(0, 0, 0, 1)

		local icon
		if self.Color then
			self.Color:SetTexture(DB.bdTex)
			icon = self.Color
		else
			self:SetNormalTexture(DB.bdTex)
			icon = self:GetNormalTexture()
		end

		icon:SetInside(bg)
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
		bar:SetStatusBarColor(1, 1, 0, .5)
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

		local offset = minimal and 10 or 14
		local bg = B.CreateBDFrame(self.Slider, 0, true)
		B.UpdateSize(bg, 10, -offset, -10, offset)
		local bar = CreateFrame("StatusBar", nil, bg)
		bar:SetStatusBarTexture(DB.normTex)
		bar:SetStatusBarColor(1, 1, 0, .5)
		bar:SetPoint("TOPLEFT", bg, C.mult, -C.mult)
		bar:SetPoint("BOTTOMLEFT", bg, C.mult, C.mult)
		bar:SetPoint("RIGHT", thumb, "CENTER")
	end

	-- Handle collapse
	local function updateCollapseTexture(texture, collapsed)
		local atlas = collapsed and "ui-questtrackerbutton-secondary-expand" or "ui-questtrackerbutton-secondary-collapse"
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
		for _, name in pairs(buttonNames) do
			local button = self[name]
			if button then
				button:ClearAllPoints()
				button:SetPoint("CENTER", -3, 0)
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
		B.CreateBDFrame(self, .25)

		local icon = self.icon or self.Icon
		if icon then
			B.ReskinIcon(icon)
		end

		B.ReskinHLTex(self, bg, true)
	end

	function B:ReskinAffixes()
		local list = self.AffixesContainer and self.AffixesContainer.Affixes or self.Affixes
		if not list then return end

		for _, frame in pairs(list) do
			frame.Border:SetTexture(nil)
			frame.Portrait:SetTexture(nil)

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
		if self.background then self.background:SetTexture(nil) end

		local cover = self.cover or self.Cover
		if cover then cover:SetTexture(nil) end

		local checkButton = self.checkButton or self.CheckButton or self.CheckBox or self.Checkbox
		if checkButton then
			checkButton:SetFrameLevel(self:GetFrameLevel() + 1)
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

	function B:CreateCheckBox(system)
		local cb = CreateFrame("CheckButton", nil, self, "OptionsBaseCheckButtonTemplate")
		cb:SetScript("OnClick", nil) -- reset onclick handler
		B.ReskinCheck(cb)

		if system then
			cb.bg:SetBackdropBorderColor(1, 1, 0)
		end

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
		B.CreateBDFrame(eb, 0, true)
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
				opt[i]:SetBackdropColor(1, 1, 0, .25)
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
		self:SetBackdropColor(0, 0, 0, .25)
	end

	local function buttonOnShow(self)
		self.__list:Hide()
	end

	local function buttonOnClick(self)
		PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK)
		B:TogglePanel(self.__list)
	end

	function B:CreateDropDown(width, height, data, system)
		local dd = CreateFrame("Frame", nil, self, "BackdropTemplate")
		dd:SetSize(width, height)
		B.CreateBD(dd, 0)
		B.CreateGradient(dd)

		dd.Text = B.CreateFS(dd, 14, "", false, "LEFT", 5, 0)
		dd.Text:SetPoint("RIGHT", -5, 0)
		dd.options = {}

		local bu = CreateFrame("Button", nil, dd)
		bu:SetPoint("RIGHT", -5, 0)
		bu:SetSize(18, 18)
		B.ReskinArrow(bu, "down")

		local list = CreateFrame("Frame", nil, dd, "BackdropTemplate")
		list:SetPoint("TOP", dd, "BOTTOM", 0, -2)
		list:SetFrameLevel(dd:GetFrameLevel() + 3)
		list:Hide()
		B.CreateBD(list, 1)

		bu.__list = list
		bu:SetScript("OnShow", buttonOnShow)
		bu:SetScript("OnClick", buttonOnClick)
		dd.button = bu

		local opt, index = {}, 0
		for i, j in pairs(data) do
			opt[i] = CreateFrame("Button", nil, list, "BackdropTemplate")
			opt[i]:SetPoint("TOPLEFT", 4, -4 - (i-1)*(height+2))
			opt[i]:SetSize(width - 8, height)
			B.CreateBD(opt[i], .25)
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

		if system then
			dd:SetBackdropBorderColor(1, 1, 0)
			dd.button.__bg:SetBackdropBorderColor(1, 1, 0)
			dd.button.__list:SetBackdropBorderColor(1, 1, 0)
		end

		dd.Type = "DropDown"
		return dd
	end

	local function updatePicker()
		local swatch = ColorPickerFrame.__swatch
		local r, g, b = ColorPickerFrame:GetColorRGB()
		r = B:Round(r, 2)
		g = B:Round(g, 2)
		b = B:Round(b, 2)
		swatch.tex:SetColorTexture(r, g, b)
		swatch.color.r, swatch.color.g, swatch.color.b = r, g, b
	end

	local function cancelPicker()
		local swatch = ColorPickerFrame.__swatch
		local r, g, b = ColorPickerFrame:GetPreviousValues()
		swatch.tex:SetColorTexture(r, g, b)
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
		swatch.bg = B.CreateBD(swatch, .25)
		if name then
			swatch.text = B.CreateFS(swatch, 14, name, false, "LEFT", 26, 0)
		end
		local tex = swatch:CreateTexture(nil, "ARTWORK")
		tex:SetInside(swatch.bg)
		tex:SetColorTexture(color.r, color.g, color.b)
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
		B.ReskinSlider(slider)

		slider.Low:SetText(minValue)
		slider.Low:SetPoint("TOPLEFT", slider, "BOTTOMLEFT", 10, -2)
		slider.High:SetText(maxValue)
		slider.High:SetPoint("TOPRIGHT", slider, "BOTTOMRIGHT", -10, -2)
		slider.Text:ClearAllPoints()
		slider.Text:SetPoint("CENTER", 0, 25)
		slider.Text:SetText(name)
		slider.Text:SetTextColor(1, 1, 0)
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
		xOffset = xOffset and (xOffset * C.mult) or C.mult
		yOffset = yOffset and (yOffset * C.mult) or C.mult
		anchor = anchor or frame:GetParent()

		DisablePixelSnap(frame)
		frame:ClearAllPoints()
		frame:SetPoint("TOPLEFT", anchor, "TOPLEFT", xOffset, -yOffset)
		frame:SetPoint("BOTTOMRIGHT", anchor2 or anchor, "BOTTOMRIGHT", -xOffset, yOffset)
	end

	local function SetOutside(frame, anchor, xOffset, yOffset, anchor2)
		xOffset = xOffset and (xOffset * C.mult) or C.mult
		yOffset = yOffset and (yOffset * C.mult) or C.mult
		anchor = anchor or frame:GetParent()

		DisablePixelSnap(frame)
		frame:ClearAllPoints()
		frame:SetPoint("TOPLEFT", anchor, "TOPLEFT", -xOffset, yOffset)
		frame:SetPoint("BOTTOMRIGHT", anchor2 or anchor, "BOTTOMRIGHT", xOffset, -yOffset)
	end

	local function HideBackdrop(frame)
		if frame.NineSlice then frame.NineSlice:SetAlpha(0) end
		if frame.SetBackdrop then frame:SetBackdrop(nil) end
		if frame.background then frame.background:Hide() end
	end

	local function KillEditMode(object)
		object.HighlightSystem = B.Dummy
		object.ClearHighlight = B.Dummy
	end

	local function addapi(object)
		local mt = getmetatable(object).__index
		if not object.SetInside then mt.SetInside = SetInside end
		if not object.SetOutside then mt.SetOutside = SetOutside end
		if not object.HideBackdrop then mt.HideBackdrop = HideBackdrop end
		if not object.KillEditMode then mt.KillEditMode = KillEditMode end
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
	addapi(object:CreateTexture(nil, "ARTWORK"))
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
		local frameName = self.GetDebugName and self:GetDebugName()
		return self[key] or (frameName and _G[frameName..key])
	end

	function B:PT(name)
		if self.GetRegions then
			for index, region in pairs {self:GetRegions()} do
				local regionName = region:GetDebugName()
				if name and string.find(regionName, name) then
					print("Regions:", index, regionName)
					break
				else
					print("Regions:", index, regionName)
				end
			end
		end

		if self.GetChildren then
			for index, child in pairs {self:GetChildren()} do
				local childName = child:GetDebugName()
				if name and string.find(childName, name) then
					print("Regions:", index, childName)
					break
				else
					print("Regions:", index, childName)
				end
			end
		end
	end

	function B.UpdateButton(f1, f2)
		if not f1 then return end

		local ic = B.GetObject(f1, "Icon") or B.GetObject(f1, "icon") or f1
		if ic then
			ic:SetInside(f2)
			ic:SetTexCoord(unpack(DB.TexCoord))

			if ic.SetDrawLayer then
				ic:SetDrawLayer("ARTWORK")
			end
		end

		local cd = B.GetObject(f1, "Cooldown") or B.GetObject(f1, "cooldown")
		if cd then
			cd:SetInside(f2)
		end

		local ac = B.GetObject(f1, "AutoCastOverlay")
		if ac then
			ac:SetInside(f2)
		end
	end

	function B.UpdatePoint(f1, p1, f2, p2, x, y)
		if not f1 then return end

		f1:ClearAllPoints()
		f1:SetPoint(p1, f2, p2, x, y)
	end

	function B.UpdateSize(f1, x1, y1, x2, y2, f2)
		if not f1 then return end

		local x_1 = x1 and x1 * C.mult
		local y_1 = y1 and y1 * C.mult
		local x_2 = x2 and x2 * C.mult
		local y_2 = y2 and y2 * C.mult
		local f = f1:GetParent()

		f1:ClearAllPoints()
		if x_1 and not (y_1 and x_2 and y_2) then
			f1:SetPoint("TOPLEFT", f2 or f, x_1, -x_1)
			f1:SetPoint("BOTTOMRIGHT", f2 or f, -x_1, x_1)
		else
			f1:SetPoint("TOPLEFT", f2 or f, x_1, y_1)
			f1:SetPoint("BOTTOMRIGHT", f2 or f, x_2, y_2)
		end
	end

	local headers = {"Header", "header"}
	local closes = {"CloseButton", "Close"}
	function B:ReskinFrame(killType)
		B.StripTextures(self, killType or 99)

		local bg = B.CreateBG(self)
		for _, key in pairs(headers) do
			local frameHeader = B.GetObject(self, key)
			if frameHeader and type(frameHeader) == "table" then
				B.StripTextures(frameHeader)
				B.UpdatePoint(frameHeader, "TOP", bg, "TOP", 0, 5)
			end
		end
		for _, key in pairs(closes) do
			local frameClose = B.GetObject(self, key)
			if frameClose and type(frameClose) == "table" then
				B.ReskinClose(frameClose, bg)
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

	function B:ReskinStatusBar(noCC, isOutside)
		B.StripTextures(self)
		if isOutside then
			self.bg = B.CreateBG(self)
		else
			self.bg = B.CreateBDFrame(self, .25, nil, -1)
		end

		self:SetStatusBarTexture(DB.normTex)
		if not noCC then
			self:SetStatusBarColor(DB.r, DB.g, DB.b, DB.alpha)
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

	function B:ReskinTooltip()
		if not self then
			if DB.isDeveloper then print("Unknown tooltip spotted.") end
			return
		end

		if self:IsForbidden() then return end
		self:SetScale(C.db["Tooltip"]["Scale"])

		local sb, ch = self.StatusBar, self.CompareHeader
		if not self.tipStyled then
			self:HideBackdrop()
			self.bg = B.CreateBG(self)

			if sb then
				sb:ClearAllPoints()
				sb:SetPoint("BOTTOMLEFT", self, "TOPLEFT", C.mult, DB.margin)
				sb:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -C.mult, DB.margin)
				sb:SetHeight(DB.margin*2)

				B.ReskinStatusBar(sb, true, true)
			end

			if ch then
				B.StripTextures(ch)
				B.UpdatePoint(ch, "BOTTOM", self, "TOP", 0, DB.margin)
				B.CreateBG(ch):SetBackdropBorderColor(0, 1, 1)
			end

			self.tipStyled = true
		end

		B.SetBorderColor(self.bg)
		if sb and sb.bg then
			B.SetBorderColor(sb.bg)
		end

		local data = self.GetTooltipData and self:GetTooltipData()
		if data then
			local link = data.guid and C_Item.GetItemLinkByGUID(data.guid) or data.hyperlink
			if link then
				local quality = C_Item.GetItemQualityByID(link)
				if quality then
					local r, g, b = C_Item.GetItemQualityColor(quality)
					self.bg:SetBackdropBorderColor(r, g, b)
				end
			end

			local unit = data.guid and UnitTokenFromGUID(data.guid)
			if unit then
				local r, g, b = B.UnitColor(unit)
				self.bg:SetBackdropBorderColor(r, g, b)

				if sb and sb.bg then
					sb.bg:SetBackdropBorderColor(r, g, b)
				end
			end

			if ch then
				self.bg:SetBackdropBorderColor(0, 1, 1)
			end
		end
	end

	function B:ReskinTabButton()
		if not self then return end

		self.Icon.isIgnored = true
		B.StripTextures(self)

		local bg = B.CreateBG(self, 1, -4, -5, 4)

		if self.SelectedTexture then
			self.SelectedTexture:SetDrawLayer("BACKGROUND")
			B.ReskinHLTex(self.SelectedTexture, bg, true, true)

			local hl = self:CreateTexture(nil, "HIGHLIGHT")
			hl:SetColorTexture(1, 1, 1, .25)
			hl:SetInside(bg)
		else
			B.ReskinHLTex(self, bg)
			B.ReskinCPTex(self, bg)
		end
	end

	function B:ReskinSideTab()
		if not self or not self.GetNormalTexture then return end

		self:SetSize(32, 32)

		local region = self:GetRegions()
		local normal = self:GetNormalTexture()
		local icon = B.GetObject(self, "Icon") or B.GetObject(self, "icon")
		if region ~= normal then region:Hide() end

		local icbg = B.ReskinIcon(icon or normal, true)
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

				if i == 1 then
					B.UpdatePoint(tabs, "TOPLEFT", frameName, "BOTTOMLEFT", 15, 1)
				else
					B.UpdatePoint(tabs, "LEFT", _G[tab..(i-1)], "RIGHT", -15, 0)
				end
			end
		end
	end

	function B:ReskinBBTex(relativeTo)
		if not self then return end

		self:SetDrawLayer("BORDER")
		self:SetColorTexture(1, 1, 0)

		self:ClearAllPoints()
		self:SetAllPoints(relativeTo)
	end

	function B:ReskinHLTex(relativeTo, classColor, isVertex)
		if not self then return end

		local r, g, b = 1, 1, 1
		if classColor then r, g, b = DB.r, DB.g, DB.b end

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
			tex:SetBlendMode("ADD")

			if isVertex then
				tex:SetVertexColor(r, g, b, .25)
			else
				tex:SetColorTexture(r, g, b, .25)
			end

			if relativeTo then
				tex:SetInside(relativeTo)
			end
		end
	end

	function B:ReskinCPTex(relativeTo, isOverride)
		if not self then return end

		if self.SetCheckedTexture then
			self:SetCheckedTexture(0)
			local checked = self:GetCheckedTexture()
			if checked and not checked.bubg then
				local bubg = B.CreateBDFrame(checked, 0)
				bubg:EnableMouse(false)
				bubg:ClearAllPoints()
				bubg:SetAllPoints(relativeTo)
				bubg:SetBackdropBorderColor(0, 1, 1)
				bubg:SetFrameLevel(relativeTo:GetFrameLevel() + 1)
				bubg:Hide()

				checked:HookScript("OnShow", function() bubg:Show() end)
				checked:HookScript("OnHide", function() bubg:Hide() end)

				checked.bubg = bubg
			end
		end

		if not self:IsObjectType("CheckButton") or isOverride then
			if self.SetPushedTexture then
				self:SetPushedTexture(0)
				local pushed = self:GetPushedTexture()
				if pushed and not pushed.bubg then
					local bubg = B.CreateBDFrame(pushed, 0)
					bubg:EnableMouse(false)
					bubg:ClearAllPoints()
					bubg:SetAllPoints(relativeTo)
					bubg:SetBackdropBorderColor(1, 1, 1)
					bubg:SetFrameLevel(relativeTo:GetFrameLevel() + 1)
					bubg:Hide()

					pushed:HookScript("OnShow", function() bubg:Show() end)
					pushed:HookScript("OnHide", function() bubg:Hide() end)

					pushed.bubg = bubg
				end
			end
		end
	end

	function B:ReskinText(r, g, b, a, size)
		if not self then return end

		self:SetTextColor(r, g, b, a or 1)

		if self.SetShadowColor then
			self:SetShadowColor(0, 0, 0, 0)
		end

		if size then
			if tonumber(size) then
				B.SetFontSize(size)
			else
				self:SetFontObject(size)
			end
		end
	end

	function B:ReskinNameFrame(frame, mult)
		if not self then return end

		local nf = B.GetObject(self, "NameFrame")
		if nf then nf:Hide() end

		local bg = B.CreateBDFrame(self, .25)
		bg:ClearAllPoints()
		bg:SetPoint("TOPLEFT", frame, "TOPRIGHT", DB.margin, 0)
		bg:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", DB.margin, 0)
		bg:SetPoint("RIGHT", self, "RIGHT", DB.margin*(mult or -1), 0)

		return bg
	end

	function B:ReskinRMTColor(r)
		if r == 0 then
			B.ReskinText(self, 1, 0, 0)
		elseif r == .2 then
			B.ReskinText(self, 0, 1, 0)
		end
	end

	B.AffixesSetup = B.ReskinAffixes
	B.Reskin = B.ReskinButton
	B.ReskinEditBox = B.ReskinInput
	B.ReskinIconBorder = B.ReskinBorder
	B.ReskinPortraitFrame = B.ReskinFrame
	B.ReskinRadio = B.ReskinCheck
	B.ReskinTrimScroll = B.ReskinScroll
	B.SetBD = B.CreateBG
	B.StyleSearchButton = B.ReskinSearchList
end