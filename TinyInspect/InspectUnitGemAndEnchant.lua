
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
--	[6]  = {1, WAISTSLOT},			-- 腰部
	[7]  = {1, LEGSSLOT},			-- 腿部
	[8]  = {1, FEETSLOT},			-- 脚部
	[9]  = {1, WRISTSLOT},			-- 腕部
--	[10] = {1, HANDSSLOT},			-- 手部
	[11] = {1, FINGER0SLOT},		-- 手指1
	[12] = {1, FINGER1SLOT},		-- 手指2
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
		if (self.link) then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetHyperlink(self.link)
			GameTooltip:Show()
		elseif (self.spellID) then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetSpellByID(self.spellID)
			GameTooltip:Show()
		elseif (self.name) then
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
	while (frame["xicon"..index]) do
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
	if type == "itemID" then
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
	icon:ClearAllPoints()
	icon:SetPoint("LEFT", anchor, "RIGHT", index == 1 and DB.margin or 1, 0)
end

--讀取並顯示圖標
local function ShowGemAndEnchant(frame, itemFrame)
	local itemlink = itemFrame.link
	if not itemlink then return 0 end

	local total, info, quality = LibItemGem:GetItemGemInfo(itemlink)
	local anchorframe = itemFrame.itemInfo
	local icon
	for i, v in ipairs(info) do
		icon = GetIconFrame(frame)
		if v.link then
			UpdateIconTexture("itemLink", icon, v.link)
		else
			icon.bg:SetVertexColor(1, 1, 0)
			icon.texture:SetTexture("Interface\\Cursor\\Quest")
		end
		icon.name = v.name
		icon.link = v.link
		UpdateIconPoint(icon, anchorframe, i)
		icon:Show()
		anchorframe = icon
	end
	local enchantItemID, enchantID = LibItemEnchant:GetEnchantItemID(itemlink)
	local enchantSpellID = LibItemEnchant:GetEnchantSpellID(itemlink)
	if (enchantItemID) then
		total = total + 1
		icon = GetIconFrame(frame)
		UpdateIconTexture("itemID", icon, enchantItemID)
		UpdateIconPoint(icon, anchorframe, total)
		icon:Show()
		anchorframe = icon
	elseif (enchantSpellID) then
		total = total + 1
		icon = GetIconFrame(frame)
		icon.bg:SetVertexColor(1,0.8,0)
		UpdateIconTexture("spellID", icon, enchantSpellID)
		UpdateIconPoint(icon, anchorframe, total)
		icon:Show()
		anchorframe = icon
	elseif (enchantID) then
		total = total + 1
		icon = GetIconFrame(frame)
		icon.name = "#" .. enchantID
		icon.bg:SetVertexColor(0.1, 0.1, 0.1)
		icon.texture:SetTexture("Interface\\FriendsFrame\\InformationIcon")
		UpdateIconPoint(icon, anchorframe, total)
		icon:Show()
		anchorframe = icon
	elseif (not enchantID and EnchantParts[itemFrame.index] and EnchantParts[itemFrame.index][1]) then
		local classID = select(12, C_Item.GetItemInfo(itemlink))
		if not (quality == 6 and (itemFrame.index==2 or itemFrame.index==16 or itemFrame.index==17)) and ((itemFrame.index ~= INVSLOT_OFFHAND) or (classID == Enum.ItemClass.Weapon)) then
			total = total + 1
			icon = GetIconFrame(frame)
			icon.name = ENCHANTS .. ": " .. (_G[EnchantParts[itemFrame.index][2]] or EnchantParts[itemFrame.index][2])
			icon.bg:SetVertexColor(0, 1, 1)
			icon.texture:SetTexture("Interface\\Cursor\\Quest") --QuestRepeatable
			UpdateIconPoint(icon, anchorframe, total)
			icon:Show()
			anchorframe = icon
		end
	end

	return total * (16 + 1)
end

--功能附着
hooksecurefunc("ShowInspectItemListFrame", function(unit, parent)
	local frame = parent.inspectFrame
	if not frame then return end

	local i = 1
	local itemFrame
	local frameWidth, iconWidth = 0, 0
	HideAllIconFrame(frame)
	while (frame["item"..i]) do
		itemFrame = frame["item"..i]
		iconWidth = ShowGemAndEnchant(frame, itemFrame)
		frameWidth = math.max(frameWidth, itemFrame.width + iconWidth + DB.margin)

		i = i + 1
	end

	frame:SetWidth(frameWidth + 32)
end)
