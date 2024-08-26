
-------------------------------------
-- 显示宝石和附魔信息
-- Author: M
-- DepandsOn: InspectUnit.lua
-------------------------------------
local B, C, L, DB = unpack(NDui)

local addon, ns = ...

local LibItemGem = LibStub:GetLibrary("LibItemGem.7000")
local LibSchedule = LibStub:GetLibrary("LibSchedule.7000")
local LibItemEnchant = LibStub:GetLibrary("LibItemEnchant.7000")

--0:optional
local EnchantParts = {
--	[1]  = {1, HEADSLOT},			-- 头部
--	[2]  = {1, NECKSLOT},			-- 颈部
--	[3]  = {1, SHOULDERSLOT},		-- 肩部
	[5]  = {1, CHESTSLOT},			-- 胸部
	[6]  = {1, WAISTSLOT},			-- 腰部
	[7]  = {1, LEGSSLOT},			-- 腿部
	[8]  = {1, FEETSLOT},			-- 脚部
	[9]  = {1, WRISTSLOT},			-- 腕部
--	[10] = {1, HANDSSLOT},			-- 手部
	[11] = {1, FINGER0SLOT},		-- 手指
	[12] = {1, FINGER1SLOT},		-- 手指
	[15] = {1, BACKSLOT},			-- 背部
	[16] = {1, MAINHANDSLOT},		-- 主手
	[17] = {1, SECONDARYHANDSLOT},	-- 副手
}

--創建圖標框架
local function CreateIconFrame(frame, index)
	local icon = CreateFrame("Button", nil, frame)
	icon.index = index
	icon:Hide()
	icon:SetSize(16, 16)
	icon:SetScript("OnEnter", function(self)
		if (self.itemLink) then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetHyperlink(self.itemLink)
			GameTooltip:Show()
		elseif (self.spellID) then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetSpellByID(self.spellID)
			GameTooltip:Show()
		elseif (self.title) then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText(self.title)
			GameTooltip:Show()
		else
			GameTooltip:Hide()
		end
	end)
	icon:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	icon:SetScript("OnDoubleClick", function(self)
		if (self.itemLink or self.title) then
			ChatEdit_ActivateChat(ChatEdit_ChooseBoxForSend())
			ChatEdit_InsertLink(self.itemLink or self.title)
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
	while (frame["xicon"..index]) do
		frame["xicon"..index].title = nil
		frame["xicon"..index].itemLink = nil
		frame["xicon"..index].spellID = nil
		frame["xicon"..index]:Hide()
		index = index + 1
	end
end

--獲取可用的圖標框架
local function GetIconFrame(frame)
	local index = 1
	while (frame["xicon"..index]) do
		if (not frame["xicon"..index]:IsShown()) then
			return frame["xicon"..index]
		end
		index = index + 1
	end
	return CreateIconFrame(frame, index)
end

-- Credit: ElvUI_WindTools
local function UpdateIconTexture(type, icon, data)
	if type == "itemId" then
		local item = Item:CreateFromItemID(data)
		item:ContinueOnItemLoad(
			function()
				local qualityColor = item:GetItemQualityColor()
				icon.bg:SetVertexColor(qualityColor.r, qualityColor.g, qualityColor.b)
				icon.texture:SetTexture(item:GetItemIcon())
				icon.itemLink = item:GetItemLink()
			end
		)
	elseif type == "itemLink" then
		local item = Item:CreateFromItemLink(data)
		item:ContinueOnItemLoad(
			function()
				local qualityColor = item:GetItemQualityColor()
				icon.bg:SetVertexColor(qualityColor.r, qualityColor.g, qualityColor.b)
				icon.texture:SetTexture(item:GetItemIcon())
				icon.itemLink = item:GetItemLink()
			end
		)
	elseif type == "spellId" then
		local spell = Spell:CreateFromSpellID(data)
		spell:ContinueOnSpellLoad(
			function()
				icon.texture:SetTexture(spell:GetSpellTexture())
				icon.spellID = spell:GetSpellID()
			end
		)
	end
end

--讀取並顯示圖標
local function ShowGemAndEnchant(frame, ItemLink, anchorFrame, itemframe)
	if (not ItemLink) then return 0 end
	local num, info, qty = LibItemGem:GetItemGemInfo(ItemLink)
	local icon
	for i, v in ipairs(info) do
		icon = GetIconFrame(frame)
		if (v.link) then
			UpdateIconTexture("itemLink", icon, v.link)
		else
			icon.bg:SetVertexColor(1, 1, 0)
			icon.texture:SetTexture("Interface\\Cursor\\Quest")
		end
		icon.title = v.name
		icon.itemLink = v.link
		icon:ClearAllPoints()
		icon:SetPoint("LEFT", anchorFrame, "RIGHT", 1, i == 1 and 1 or 0)
		icon:Show()
		anchorFrame = icon
	end
	local enchantItemID, enchantID = LibItemEnchant:GetEnchantItemID(ItemLink)
	local enchantSpellID = LibItemEnchant:GetEnchantSpellID(ItemLink)
	if (enchantItemID) then
		num = num + 1
		icon = GetIconFrame(frame)
		UpdateIconTexture("itemId", icon, enchantItemID)
		icon:ClearAllPoints()
		icon:SetPoint("LEFT", anchorFrame, "RIGHT", 1, num == 1 and 1 or 0)
		icon:Show()
		anchorFrame = icon
	elseif (enchantSpellID) then
		num = num + 1
		icon = GetIconFrame(frame)
		icon.bg:SetVertexColor(1,0.8,0)
		UpdateIconTexture("spellId", icon, enchantSpellID)
		icon:ClearAllPoints()
		icon:SetPoint("LEFT", anchorFrame, "RIGHT", 1, num == 1 and 1 or 0)
		icon:Show()
		anchorFrame = icon
	elseif (enchantID) then
		num = num + 1
		icon = GetIconFrame(frame)
		icon.title = "#" .. enchantID
		icon.bg:SetVertexColor(0.1, 0.1, 0.1)
		icon.texture:SetTexture("Interface\\FriendsFrame\\InformationIcon")
		icon:ClearAllPoints()
		icon:SetPoint("LEFT", anchorFrame, "RIGHT", 1, num == 1 and 1 or 0)
		icon:Show()
		anchorFrame = icon
	elseif (not enchantID and EnchantParts[itemframe.index] and EnchantParts[itemframe.index][1]) then
		local classID = select(12, C_Item.GetItemInfo(ItemLink))
		if not (qty == 6 and (itemframe.index==2 or itemframe.index==16 or itemframe.index==17)) and ((itemframe.index ~= INVSLOT_OFFHAND) or (classID == Enum.ItemClass.Weapon)) then
			num = num + 1
			icon = GetIconFrame(frame)
			icon.title = ENCHANTS .. ": " .. (_G[EnchantParts[itemframe.index][2]] or EnchantParts[itemframe.index][2])
			icon.bg:SetVertexColor(0, 1, 1)
			icon.texture:SetTexture("Interface\\Cursor\\Quest") --QuestRepeatable
			icon:ClearAllPoints()
			icon:SetPoint("LEFT", anchorFrame, "RIGHT", 1, num == 1 and 1 or 0)
			icon:Show()
			anchorFrame = icon
		end
	end
	return num * 18
end

--功能附着
hooksecurefunc("ShowInspectItemListFrame", function(unit, parent, itemLevel, maxLevel)
	local frame = parent.inspectFrame
	if (not frame) then return end
	local i = 1
	local itemframe
	local width, iconWidth = frame:GetWidth(), 0
	HideAllIconFrame(frame)
	while (frame["item"..i]) do
		itemframe = frame["item"..i]
		iconWidth = ShowGemAndEnchant(frame, itemframe.link, itemframe.nameString, itemframe)
		if (width < itemframe.width + iconWidth + 34) then
			width = itemframe.width + iconWidth + 34
		end
		i = i + 1
	end
	if (width > frame:GetWidth()) then
		frame:SetWidth(width)
	end
end)
