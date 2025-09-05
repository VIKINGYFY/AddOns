
-------------------------------------
-- 显示宝石和附魔信息
-- Author: M
-- DepandsOn: InspectUnit.lua
-------------------------------------
local B, C, L, DB = unpack(NDui)

local LibItemInfo = LibStub:GetLibrary("LibItemInfo-NDui-MOD")

local INVSLOT_ENCHANT = {
	[INVSLOT_CHEST] = true,
	[INVSLOT_LEGS] = true,
	[INVSLOT_FEET] = true,
	[INVSLOT_WRIST] = true,
	[INVSLOT_FINGER1] = true,
	[INVSLOT_FINGER2] = true,
	[INVSLOT_BACK] = true,
	[INVSLOT_MAINHAND] = true,
	[INVSLOT_OFFHAND] = true,
}

local function CheckEnchantmentSlot(index, quality, mainType, subType)
	if INVSLOT_ENCHANT[index] then
		if quality == Enum.ItemQuality.Artifact and (index == INVSLOT_NECK or index == INVSLOT_MAINHAND or index == INVSLOT_OFFHAND) then
			return false
		end
		if index == INVSLOT_OFFHAND and (mainType == INVTYPE_HOLDABLE or subType == SHIELDSLOT) then
			return false
		end
		return true
	end
	return false
end

local INVSLOT_SOCKET_ITEMS = {
	[INVSLOT_NECK] = { 213777, 213777 },
	[INVSLOT_FINGER1] = { 213777, 213777 },
	[INVSLOT_FINGER2] = { 213777, 213777 },
}

local pvpMarker = gsub(PVP_ITEM_LEVEL_TOOLTIP, "%%d", "(.+)")
local function IsPVPEquipment(link)
	local tooltipData = C_TooltipInfo.GetHyperlink(link, nil, nil, true)
	if not tooltipData then return end

	for _, lineData in ipairs(tooltipData.lines) do
		if lineData and lineData.leftText then
			if string.find(lineData.leftText, pvpMarker) then
				return true
			end
		end
	end
	return false
end

local function GetItemAddableSockets(link, slot, itemLevel)
	if itemLevel < 584 then return end

	local socketItems = INVSLOT_SOCKET_ITEMS[slot]
	local isPVPItem = IsPVPEquipment(link)

	if isPVPItem or not socketItems then return end

	local items = {}
	local numSockets = C_Item.GetItemNumSockets(link)
	for i = numSockets + 1, #socketItems do
		table.insert(items, socketItems[i])
	end
	return items
end

--創建圖標框架
local function CreateIconFrame(frame, index)
	local icon = CreateFrame("Button", nil, frame)
	icon.index = index
	icon:Hide()
	icon:SetSize(16, 16)
	icon:SetScript("OnEnter", function(self)
		if self.link then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetHyperlink(self.link)
			GameTooltip:Show()
		elseif self.spellID then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetSpellByID(self.spellID)
			GameTooltip:Show()
		elseif self.name then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText(self.name)
			GameTooltip:Show()
		else
			GameTooltip:Hide()
		end
	end)
	icon:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	icon:SetScript("OnDoubleClick", function(self)
		if (self.link or self.name) then
			ChatFrame_OpenChat(self.link or self.name)
		end
	end)
	icon.bg = icon:CreateTexture(nil, "BACKGROUND")
	icon.bg:SetSize(16, 16)
	icon.bg:SetPoint("CENTER")
	icon.bg:SetTexture("Interface\\Masks\\CircleMaskScalable")

	icon.texture = icon:CreateTexture(nil, "BORDER")
	icon.texture:SetSize(12, 12)
	icon.texture:SetPoint("CENTER")
	icon.texture:SetMask("Interface\\Masks\\CircleMaskScalable")

	frame["xicon"..index] = icon

	return frame["xicon"..index]
end

--隱藏所有圖標框架
local function HideAllIconFrame(frame)
	local index = 1
	while frame["xicon"..index] do
		frame["xicon"..index].name = nil
		frame["xicon"..index].link = nil
		frame["xicon"..index].spellID = nil
		frame["xicon"..index]:Hide()

		index = index + 1
	end
end

--獲取可用的圖標框架
local function GetIconFrame(frame)
	local index = 1
	while frame["xicon"..index] do
		if not frame["xicon"..index]:IsShown() then
			return frame["xicon"..index]
		end
		index = index + 1
	end
	return CreateIconFrame(frame, index)
end

-- Credit: ElvUI_WindTools
local function UpdateIconTexture(type, icon, data)
	icon.bg:SetVertexColor(1, 1, 0)
	icon.texture:SetTexture("Interface\\Cursor\\Quest")

	if type == "itemName" then
		icon.name = data
	elseif type == "itemID" then
		local item = Item:CreateFromItemID(data)
		item:ContinueOnItemLoad(
			function()
				local qualityColor = item:GetItemQualityColor()
				icon.bg:SetVertexColor(qualityColor.r, qualityColor.g, qualityColor.b)
				icon.texture:SetTexture(item:GetItemIcon())
				icon.link = item:GetItemLink()
			end
		)
	elseif type == "itemLink" then
		local item = Item:CreateFromItemLink(data)
		item:ContinueOnItemLoad(
			function()
				local qualityColor = item:GetItemQualityColor()
				icon.bg:SetVertexColor(qualityColor.r, qualityColor.g, qualityColor.b)
				icon.texture:SetTexture(item:GetItemIcon())
				icon.link = item:GetItemLink()
			end
		)
	elseif type == "spellID" then
		local spell = Spell:CreateFromSpellID(data)
		spell:ContinueOnSpellLoad(
			function()
				icon.texture:SetTexture(spell:GetSpellTexture())
				icon.spellID = spell:GetSpellID()
			end
		)
	end
end

local function UpdateIconPoint(icon, anchor, index)
	local x, y = DB.margin, 1
	if index > 1 then x, y = 1, 0 end

	icon:ClearAllPoints()
	icon:SetPoint("LEFT", anchor, "RIGHT", x, y)
end

--讀取並顯示圖標
local function ShowGemAndEnchant(frame, itemFrame)
	local itemlink = itemFrame.link
	if not itemlink then return 0 end

	local total, info = LibItemInfo:GetItemGemInfo(itemlink)
	local anchorframe = itemFrame.itemInfo
	local icon
	for i, v in ipairs(info) do
		icon = GetIconFrame(frame)
		UpdateIconTexture(v.link and "itemLink" or "itemName", icon, v.link or v.name)
		UpdateIconPoint(icon, anchorframe, i)
		icon:Show()
		anchorframe = icon
	end

	local socketItems = GetItemAddableSockets(itemlink, itemFrame.index, itemFrame.level)
	if socketItems then
		for _, socketItemId in ipairs(socketItems) do
			total = total + 1
			icon = GetIconFrame(frame)
			UpdateIconTexture("itemID", icon, socketItemId)
			UpdateIconPoint(icon, anchorframe, i)
			icon:Show()
			anchorframe = icon
		end
	end

	local enchantID, enchantItemID, enchantSpellID = LibItemInfo:GetItemEnchantInfo(itemlink)
	if enchantItemID then
		total = total + 1
		icon = GetIconFrame(frame)
		UpdateIconTexture("itemID", icon, enchantItemID)
		UpdateIconPoint(icon, anchorframe, total)
		icon:Show()
		anchorframe = icon
	elseif enchantSpellID then
		total = total + 1
		icon = GetIconFrame(frame)
		UpdateIconTexture("spellID", icon, enchantSpellID)
		UpdateIconPoint(icon, anchorframe, total)
		icon:Show()
		anchorframe = icon
	elseif enchantID then
		total = total + 1
		icon = GetIconFrame(frame)
		icon.name = "# " .. enchantID
		icon.bg:SetVertexColor(0, 1, 1)
		icon.texture:SetTexture("Interface\\FriendsFrame\\InformationIcon")
		UpdateIconPoint(icon, anchorframe, total)
		icon:Show()
		anchorframe = icon
	elseif not enchantID and CheckEnchantmentSlot(itemFrame.index, itemFrame.quality, itemFrame.mainType, itemFrame.subType) then
		total = total + 1
		icon = GetIconFrame(frame)
		icon.name = ENCHANTS .. ": " .. itemFrame.slot
		icon.bg:SetVertexColor(0, 1, 1)
		icon.texture:SetTexture("Interface\\Cursor\\Quest")
		UpdateIconPoint(icon, anchorframe, total)
		icon:Show()
		anchorframe = icon
	end

	return total * (16 + 1)
end

--功能附着
hooksecurefunc("ShowInspectItemListFrame", function(unit, parent)
	local frame = parent.inspectFrame
	if not frame then return end

	HideAllIconFrame(frame)

	local i = 1
	local itemFrame
	local frameWidth, iconWidth = 0, 0
	while frame["item"..i] do
		itemFrame = frame["item"..i]
		iconWidth = ShowGemAndEnchant(frame, itemFrame)
		frameWidth = math.max(frameWidth, itemFrame.width + iconWidth + DB.margin)

		i = i + 1
	end

	frame:SetWidth(frameWidth + 32)
end)
