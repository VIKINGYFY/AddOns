local B, C, L, DB = unpack(LightAO)

local cr, cg, cb = DB.cr, DB.cg, DB.cb

do
	function B:CreateBD(alpha)
		self:SetBackdrop({bgFile = DB.bdTex, edgeFile = DB.bdTex, edgeSize = C.mult})
		self:SetBackdropColor(0, 0, 0, alpha or .5)
		self:SetBackdropBorderColor(0, 0, 0, 1)
	end

	function B:CreateSD()
		if self.Shadow then return end

		local frame = self
		if self:IsObjectType("Texture") then frame = self:GetParent() end
		local lvl = frame:GetFrameLevel()
		local offset = 4*C.mult
		local size = 4*C.mult

		self.Shadow = CreateFrame("Frame", nil, frame, "BackdropTemplate")
		self.Shadow:SetPoint("TOPLEFT", self, -offset, offset)
		self.Shadow:SetPoint("BOTTOMRIGHT", self, offset, -offset)
		self.Shadow:SetBackdrop({edgeFile = DB.glowTex, edgeSize = size})
		self.Shadow:SetBackdropBorderColor(0, 0, 0, 1)
		self.Shadow:SetFrameLevel(lvl == 0 and 1 or lvl - 1)

		return self.Shadow
	end

	function B:CreateTex()
		if self.Tex then return end

		local frame = self
		if self:IsObjectType("Texture")  then frame = self:GetParent() end

		self.Tex = frame:CreateTexture(nil, "BACKGROUND", nil, 1)
		self.Tex:SetAllPoints()
		self.Tex:SetTexture(DB.bgTex, true, true)
		self.Tex:SetHorizTile(true)
		self.Tex:SetVertTile(true)
		self.Tex:SetBlendMode("ADD")
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
		fs:SetFont(DB.Font[1], size, DB.Font[3])
		fs:SetText(text)
		fs:SetWordWrap(false)
		if color == "class" then
			fs:SetTextColor(cr, cg, cb)
		elseif color == "system" then
			fs:SetTextColor(1, .8, 0)
		end
		if anchor and x and y then
			fs:SetJustifyH(justifyList[anchor])
			fs:SetPoint(anchor, x, y)
		else
			fs:SetJustifyH("CENTER")
			fs:SetPoint("CENTER", 1, 0)
		end

		return fs
	end

	function B:CreateBDFrame(a)
		local frame = self
		if self:IsObjectType("Texture") then frame = self:GetParent() end
		local lvl = frame:GetFrameLevel()

		local bg = CreateFrame("Frame", nil, frame, "BackdropTemplate")
		bg:SetPoint("TOPLEFT", frame, -C.mult, C.mult)
		bg:SetPoint("BOTTOMRIGHT", frame, C.mult, -C.mult)
		bg:SetFrameLevel(lvl == 0 and 0 or lvl - 1)
		B.CreateBD(bg, a)

		return bg
	end

	function B:PixelIcon(texture, highlight)
		self.bg = B.CreateBDFrame(self)
		self.bg:SetAllPoints()
		self.Icon = self:CreateTexture(nil, "ARTWORK")
		self.Icon:SetTexCoord(.08, .92, .08, .92)
		self.Icon:SetPoint("TOPLEFT", self.bg, C.mult, -C.mult)
		self.Icon:SetPoint("BOTTOMRIGHT", self.bg, -C.mult, C.mult)
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
			self.HL:SetPoint("TOPLEFT", self.bg, C.mult, -C.mult)
			self.HL:SetPoint("BOTTOMRIGHT", self.bg, -C.mult, C.mult)
		end
	end

	function B:CreateButton(width, height, icon)
		local bu = CreateFrame("Button", nil, self, "BackdropTemplate")
		bu:SetSize(width, height)
		B.PixelIcon(bu, icon, true)

		return bu
	end

	function B.FormatNB(n)
		if type(n) == "number" then
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
			return n
		end
	end

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
		if not color then return 1, 1, 1 end
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

	-- Item Slot
	local typeCache = {}
	function B.GetItemType(itemInfo, bagID, slotID)
		local itemID, _, _, itemEquipLoc, _, itemClassID, itemSubClassID = C_Item.GetItemInfoInstant(itemInfo)
		if not itemID then return end
		if typeCache[itemInfo] then return typeCache[itemInfo] end

		local itemType
		if DB.EquipmentIDs[itemClassID] then
			itemType = DB.EquipmentTypes[itemEquipLoc] or _G[itemEquipLoc]
		elseif itemClassID == Enum.ItemClass.Consumable then
			itemType = DB.ConsumableTypes[itemSubClassID]
		elseif itemClassID == Enum.ItemClass.Container then
			itemType = DB.ContainerTypes[itemSubClassID]
		elseif itemClassID == Enum.ItemClass.ItemEnhancement then
			itemType = DB.ItemEnhancementTypes[itemSubClassID]
		elseif itemClassID == Enum.ItemClass.Recipe then
			itemType = DB.RecipeTypes[itemSubClassID]
		elseif itemClassID == Enum.ItemClass.Key then
			itemType = DB.KeyTypes[itemSubClassID]
		elseif itemClassID == Enum.ItemClass.Miscellaneous then
			itemType = DB.MiscellaneousTypes[itemSubClassID]
		elseif itemClassID == Enum.ItemClass.Profession then
			itemType = DB.ProfessionTypes[itemSubClassID]
		end

		local itemDate
		if bagID and slotID then
			itemDate = C_TooltipInfo.GetBagItem(bagID, slotID)
		else
			itemDate = C_TooltipInfo.GetHyperlink(itemInfo, nil, nil, true)
		end
		if itemDate then
			for i = 2, 8 do
				local lineData = itemDate.lines[i]
				if not lineData then break end

				local lineText = lineData.leftText
				if DB.ConduitTypes[lineText] then
					itemType = DB.ConduitTypes[lineText]
					break
				elseif DB.BindTypes[lineText] then
					itemType = DB.BindTypes[lineText]
					break
				end
			end
		end

		if C_ArtifactUI.GetRelicInfoByItemID(itemID) then
			itemType = RELICSLOT
		elseif C_Item.IsAnimaItemByID(itemID) then
			itemType = POWER_TYPE_ANIMA
		elseif C_ToyBox.GetToyInfo(itemID) then
			itemType = TOY
		end

		local _, spellID = C_Item.GetItemSpell(itemID)
		if DB.AncientMana[spellID] then
			itemType = "魔力"
		elseif DB.DeliverRelic[spellID] then
			itemType = "研究"
		elseif DB.Experience[spellID] then
			itemType = "经验"
		end

		--itemType = itemClassID.." "..itemSubClassID

		typeCache[itemInfo] = itemType
		return itemType
	end

	-- Item Stat
	local statCache = {}
	function B.GetItemStat(itemInfo)
		if statCache[itemInfo] then return statCache[itemInfo] end

		local itemStat = ""
		local stats = C_Item.GetItemStats(itemInfo)
		if stats then
			for stat, count in pairs(stats) do
				if DB.ItemStats[stat] then
					itemStat = itemStat.."-".._G[stat]
				end
				if string.find(stat, "EMPTY_SOCKET_") then
					itemStat = itemStat.."-"..L["Socket"]
				end
			end
		end

		statCache[itemInfo] = itemStat
		return itemStat
	end

	-- Item Extra
	local extraCache = {}
	function B.GetItemExtra(itemInfo)
		if extraCache[itemInfo] then return extraCache[itemInfo] end

		local itemExtra, hasStat
		local itemType = B.GetItemType(itemInfo)
		local itemStat = B.GetItemStat(itemInfo)
		local itemLevel = B.GetItemLevel(itemInfo)

		if itemLevel and itemType then
			itemExtra = "<"..itemLevel.."-"..itemType..itemStat..">"
		elseif itemLevel then
			itemExtra = "<"..itemLevel..itemStat..">"
		elseif itemType then
			itemExtra = "<"..itemType..itemStat..">"
		end

		if itemStat ~= "" then
			hasStat = true
		end

		extraCache[itemInfo] = itemExtra
		return itemExtra, hasStat
	end
end