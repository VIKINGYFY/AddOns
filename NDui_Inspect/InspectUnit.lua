
-------------------------------------
-- 查看装备等级
-- Author: M
-------------------------------------
local B, C, L, DB = unpack(NDui)

local LibEvent = LibStub:GetLibrary("LibEvent-NDui-MOD")
local LibUnitInfo = LibStub:GetLibrary("LibUnitInfo-NDui-MOD")
local frameWidth, levelWidth = 160, 0

--裝備清單
local slots = {
	{ index = 1, slot = HEADSLOT, },
	{ index = 2, slot = NECKSLOT, },
	{ index = 3, slot = SHOULDERSLOT, },
	{ index = 5, slot = CHESTSLOT, },
	{ index = 6, slot = WAISTSLOT, },
	{ index = 7, slot = LEGSSLOT, },
	{ index = 8, slot = FEETSLOT, },
	{ index = 9, slot = WRISTSLOT, },
	{ index = 10, slot = HANDSSLOT, },
	{ index = 11, slot = FINGER0SLOT, },
	{ index = 12, slot = FINGER1SLOT, },
	{ index = 13, slot = TRINKET0SLOT, },
	{ index = 14, slot = TRINKET1SLOT, },
	{ index = 15, slot = BACKSLOT, },
	{ index = 16, slot = MAINHANDSLOT, },
	{ index = 17, slot = SECONDARYHANDSLOT, },
}

local stats = {
	{ key = "ITEM_MOD_CRIT_RATING_SHORT",    label = "|cffFF0000爆|r", value = 0  },
	{ key = "ITEM_MOD_HASTE_RATING_SHORT",   label = "|cffFFFF00急|r", value = 0  },
	{ key = "ITEM_MOD_MASTERY_RATING_SHORT", label = "|cff00FF00精|r", value = 0  },
	{ key = "ITEM_MOD_VERSATILITY",          label = "|cff00FFFF全|r", value = 0  },
}

--創建面板
local function GetInspectItemListFrame(parent)
	if not parent.inspectFrame then
		local frame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
		local frameHeight = parent:GetHeight()
		frame:SetSize(frameWidth, frameHeight)
		frame:SetToplevel(true)

		frame.specIcon = frame:CreateTexture(nil, "BORDER")
		frame.specIcon:SetSize(42, 42)
		frame.specIcon:SetPoint("TOPLEFT", 16, -16)
		frame.iconBG = B.ReskinIcon(frame.specIcon)

		frame.unitName = B.CreateFS(frame, 18)
		frame.unitName:SetJustifyH("LEFT")
		B.UpdatePoint(frame.unitName, "BOTTOMLEFT", frame.specIcon, "RIGHT", 4, -2)

		frame.unitInfo = B.CreateFS(frame, 14)
		frame.unitInfo:SetJustifyH("LEFT")
		B.UpdatePoint(frame.unitInfo, "BOTTOMLEFT", frame.unitName, "BOTTOMRIGHT", 4, 0)

		frame.unitStas = B.CreateFS(frame, 14)
		frame.unitStas:SetJustifyH("LEFT")
		B.UpdatePoint(frame.unitStas, "TOPLEFT", frame.specIcon, "RIGHT", 5, -5)

		local itemFrame
		for i, v in ipairs(slots) do
			itemFrame = CreateFrame("Button", nil, frame, "BackdropTemplate")
			itemFrame:SetSize(120, (frameHeight-74)/#slots)
			itemFrame.index = v.index
			itemFrame.slot = v.slot

			if i == 1 then
				itemFrame:SetPoint("TOPLEFT", frame.specIcon, "BOTTOMLEFT", 0, -8)
			else
				itemFrame:SetPoint("TOPLEFT", frame["item"..(i-1)], "BOTTOMLEFT")
			end

			for index, stat in ipairs(stats) do
				local statFrame = CreateFrame("Frame", nil, itemFrame, "BackdropTemplate")
				statFrame:SetAlpha(.1)
				statFrame:SetSize(16, 16)
				statFrame:SetPoint("LEFT", (index-1)*(16+DB.margin), 0)
				statFrame.label = B.CreateFS(statFrame, 14, stat.label)
				statFrame.key = stat.key

				itemFrame["itemStats"..index] = statFrame
			end

			itemFrame.itemLevel = B.CreateFS(itemFrame, 16)
			itemFrame.itemLevel:SetJustifyH("CENTER")
			B.UpdatePoint(itemFrame.itemLevel, "LEFT", itemFrame.itemStats4, "RIGHT", DB.margin, 0)

			itemFrame.itemName = B.CreateFS(itemFrame, 16)
			itemFrame.itemName:SetJustifyH("LEFT")
			B.UpdatePoint(itemFrame.itemName, "LEFT", itemFrame.itemLevel, "RIGHT", DB.margin, 0)

			itemFrame.itemInfo = B.CreateFS(itemFrame, 16)
			itemFrame.itemInfo:SetJustifyH("LEFT")
			B.UpdatePoint(itemFrame.itemInfo, "LEFT", itemFrame.itemName, "RIGHT", DB.margin, 0)

			itemFrame:SetScript("OnEnter", function(self)
				if self.link then
					GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
					GameTooltip:SetInventoryItem(self:GetParent().unit, self.index)
					GameTooltip:Show()
				end
			end)
			itemFrame:SetScript("OnLeave", function(self)
				GameTooltip:Hide()
			end)
			itemFrame:SetScript("OnDoubleClick", function(self)
				if self.link then
					ChatFrame_OpenChat(self.link)
				end
			end)
			frame["item"..i] = itemFrame
			LibEvent:trigger("INSPECT_ITEMFRAME_CREATED", itemFrame)
		end

		frame.close = B.CreateButton(frame, 18, 18, true, DB.closeTex)
		frame.close:SetPoint("TOPRIGHT", -6, -6)
		frame.close:SetScript("OnClick", function(self) self:GetParent():Hide() end)

		frame.bg = B.SetBD(frame)

		parent:HookScript("OnHide", function(self) frame:Hide() end)
		parent.inspectFrame = frame

		LibEvent:trigger("INSPECT_FRAME_CREATED", frame, parent)
	end

	return parent.inspectFrame
end

--顯示面板
function ShowInspectItemListFrame(unit, parent, ilevel)
	if not parent:IsShown() then return end

	local frame = GetInspectItemListFrame(parent)
	frame.unit = unit

	frame.unitName:SetText("")
	frame.unitName:SetTextColor(1, 1, 1)
	frame.unitInfo:SetText("")
	frame.unitInfo:SetTextColor(1, 1, 1)
	frame.unitStas:SetText("")
	frame.unitStas:SetTextColor(1, 1, 1)

	frame.specIcon:SetTexture("")
	frame.specIcon:Hide()
	frame.iconBG:Hide()

	local _, specID, specName, specIcon
	if unit == "player" then
		specID = C_SpecializationInfo.GetSpecialization()
		_, specName, _, specIcon = C_SpecializationInfo.GetSpecializationInfo(specID)
	else
		specID = GetInspectSpecialization(unit)
		_, specName, _, specIcon = GetSpecializationInfoByID(specID)
	end

	if specIcon then
		frame.specIcon:SetTexture(specIcon)
		frame.specIcon:Show()
		frame.iconBG:Show()
	end

	local r, g, b = B.UnitColor(unit)
	frame.unitName:SetFormattedText("%s", UnitName(unit))
	frame.unitName:SetTextColor(r, g, b)
	frame.unitInfo:SetFormattedText("%s %s %.1f", specName, UnitLevel(unit), ilevel)
	frame.unitInfo:SetTextColor(0, 1, 1)

	for _, s in ipairs(stats) do
		s.value = 0
	end

	for i, v in ipairs(slots) do
		local level, link, quality, mainType, subType, itemID = LibUnitInfo:GetUnitItemInfo(unit, v.index)
		local itemFrame = frame["item"..i]
		itemFrame:SetWidth(0)
		itemFrame.level = level
		itemFrame.link = link
		itemFrame.quality = quality
		itemFrame.mainType = mainType
		itemFrame.subType = subType
		itemFrame.width = 0

		itemFrame.itemLevel:SetText("")
		itemFrame.itemLevel:SetTextColor(1, 1, 1)
		itemFrame.itemName:SetText("")
		itemFrame.itemInfo:SetText("")
		itemFrame.itemInfo:SetTextColor(1, 1, 1)

		for j = 1, 4 do
			itemFrame["itemStats"..j]:SetAlpha(.1)
		end

		if link and level then
			itemFrame.itemLevel:SetText(level)
			itemFrame.itemName:SetText(link)

			local itemSetSpellIDs = itemID and C_Item.GetSetBonusesForSpecializationByItemID(specID, itemID)
			if itemSetSpellIDs then
				itemFrame.itemLevel:SetTextColor(0, 1, 1)
			end

			local upgradeInfo = C_Item.GetItemUpgradeInfo(link)
			if upgradeInfo and upgradeInfo.trackString then
				local r, g, b = B.SmoothColor(upgradeInfo.currentLevel, upgradeInfo.maxLevel, true)
				itemFrame.itemInfo:SetText(format("[%s %s/%s]", upgradeInfo.trackString, upgradeInfo.currentLevel, upgradeInfo.maxLevel))
				itemFrame.itemInfo:SetTextColor(r, g, b)
			end

			local itemStats = C_Item.GetItemStats(link)
			if itemStats then
				for n = 1, 4 do
					if itemStats[itemFrame["itemStats"..n].key] then
						itemFrame["itemStats"..n]:SetAlpha(1)
					end
				end
				for _, s in ipairs(stats) do
					if itemStats[s.key] then
						s.value = s.value + itemStats[s.key]
					end
				end
			end

			frame.unitStas:SetFormattedText(
				"|cffFF0000%s: %s|r |cffFFFF00%s: %s|r |cff00FF00%s: %s|r |cff00FFFF%s: %s|r",
				_G[stats[1].key], B.Numb(stats[1].value), _G[stats[2].key], B.Numb(stats[2].value),
				_G[stats[3].key], B.Numb(stats[3].value), _G[stats[4].key], B.Numb(stats[4].value)
			)

			itemFrame:Show()
		else
			itemFrame:Hide()
		end

		levelWidth = math.max(levelWidth, itemFrame.itemLevel:GetStringWidth())
		itemFrame.itemLevel:SetWidth(math.ceil(levelWidth))

		itemFrame.width = math.ceil(itemFrame.itemStats1:GetWidth() * 4 + itemFrame.itemLevel:GetWidth() + itemFrame.itemName:GetWidth() + itemFrame.itemInfo:GetWidth() + DB.margin*6)
		itemFrame:SetWidth(itemFrame.width)
		frameWidth = math.max(frameWidth, itemFrame.width)

		LibEvent:trigger("INSPECT_ITEMFRAME_UPDATED", itemFrame)
	end

	frame:SetWidth(frameWidth + 32)
	frame.bg:SetBackdropBorderColor(r, g, b)
	frame:Show()

	LibEvent:trigger("INSPECT_FRAME_SHOWN", frame, parent, ilevel)

	return frame
end

--裝備變更時
LibEvent:attachEvent("UNIT_INVENTORY_CHANGED", function(self, unit)
	if InspectFrame and InspectFrame.unit and InspectFrame.unit == unit then
		ReInspect(unit)
	end
end)

--@see InspectCore.lua
LibEvent:attachTrigger("UNIT_INSPECT_READY, UNIT_REINSPECT_READY", function(self, data)
	if InspectFrame and InspectFrame.unit and UnitGUID(InspectFrame.unit) == data.guid then
		local frame = ShowInspectItemListFrame(InspectFrame.unit, InspectFrame, data.ilevel)
		LibEvent:trigger("INSPECT_FRAME_COMPARE", frame)
	end
end)

--設置邊框
LibEvent:attachTrigger("INSPECT_FRAME_SHOWN", function(self, frame, parent)
	B.UpdatePoint(frame, "LEFT", parent, "RIGHT", DB.margin, 0)
end)

--自己裝備列表
LibEvent:attachTrigger("INSPECT_FRAME_COMPARE", function(self, frame)
	if not frame then return end

	local ilevel = LibUnitInfo:GetUnitItemLevel("player")
	ShowInspectItemListFrame("player", frame, ilevel)
end)

LibEvent:attachEvent("PLAYER_EQUIPMENT_CHANGED", function(self)
	if CharacterFrame:IsShown() then
		local ilevel = LibUnitInfo:GetUnitItemLevel("player")
		ShowInspectItemListFrame("player", PaperDollFrame, ilevel)
	end
end)

PaperDollFrame:HookScript("OnShow", function(self)
	local ilevel = LibUnitInfo:GetUnitItemLevel("player")
	ShowInspectItemListFrame("player", self, ilevel)
end)
