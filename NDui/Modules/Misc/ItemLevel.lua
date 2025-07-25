local _, ns = ...
local B, C, L, DB = unpack(ns)
local M = B:GetModule("Misc")
local TT = B:GetModule("Tooltip")

local inspectSlots = {
	"Head",
	"Neck",
	"Shoulder",
	"Shirt",
	"Chest",
	"Waist",
	"Legs",
	"Feet",
	"Wrist",
	"Hands",
	"Finger0",
	"Finger1",
	"Trinket0",
	"Trinket1",
	"Back",
	"MainHand",
	"SecondaryHand",
}

function M:GetSlotAnchor(index)
	if not index then return end

	if index <= 5 or index == 9 or index == 15 then
		return "BOTTOMLEFT", 40, 20
	elseif index == 16 then
		return "BOTTOMRIGHT", -40, 2
	elseif index == 17 then
		return "BOTTOMLEFT", 40, 2
	else
		return "BOTTOMRIGHT", -40, 20
	end
end

function M:CreateItemTexture(slot, relF, x, y)
	local icon = slot:CreateTexture(nil, "ARTWORK")
	icon:SetPoint(relF, x, y)
	icon:SetSize(14, 14)
	icon:SetTexCoord(unpack(DB.TexCoord))
	icon.bg = B.ReskinIcon(icon)
	icon.bg:Hide()

	return icon
end

function M:ItemString_Expand()
	self:SetWidth(0)
end

function M:ItemString_Collapse()
	self:SetWidth(100)
end

function M:CreateItemString(frame, strType)
	if frame.fontCreated then return end

	for index, slot in pairs(inspectSlots) do
		if index ~= 4 then
			local slotFrame = _G[strType..slot.."Slot"]
			slotFrame.iLvlText = B.CreateFS(slotFrame, DB.Font[2]+1, "", false, "BOTTOM", 0, 0)
			slotFrame.iSlotText = B.CreateFS(slotFrame, DB.Font[2]+1, "", false, "TOP", 1, -1)

			local relF, x, y = M:GetSlotAnchor(index)
			slotFrame.enchantText = B.CreateFS(slotFrame, DB.Font[2]+1, "", "green")
			slotFrame.enchantText:ClearAllPoints()
			slotFrame.enchantText:SetPoint(relF, slotFrame, x, y)

			slotFrame.enchantText:SetJustifyH(string.sub(relF, 7))
			slotFrame.enchantText:SetWidth(100)
			slotFrame.enchantText:EnableMouse(true)
			slotFrame.enchantText:HookScript("OnShow", M.ItemString_Collapse)
			slotFrame.enchantText:HookScript("OnEnter", M.ItemString_Expand)
			slotFrame.enchantText:HookScript("OnLeave", M.ItemString_Collapse)

			for i = 1, 10 do
				local offset = (i-1)*18 + 5
				local iconX = x > 0 and x+offset or x-offset
				local iconY = index > 15 and 20 or 2
				slotFrame["textureIcon"..i] = M:CreateItemTexture(slotFrame, relF, iconX, iconY)
			end
		end
	end

	frame.fontCreated = true
end

local azeriteSlots = {
	[1] = true,
	[3] = true,
	[5] = true,
}

local locationCache = {}
local function GetSlotItemLocation(id)
	if not azeriteSlots[id] then return end

	local itemLocation = locationCache[id]
	if not itemLocation then
		itemLocation = ItemLocation:CreateFromEquipmentSlot(id)
		locationCache[id] = itemLocation
	end
	return itemLocation
end

function M:ItemLevel_UpdateTraits(button, id, link)
	if not C.db["Misc"]["AzeriteTraits"] then return end

	local empoweredItemLocation = GetSlotItemLocation(id)
	if not empoweredItemLocation then return end

	local allTierInfo = TT:Azerite_UpdateTier(link)
	if not allTierInfo then return end

	for i = 1, 2 do
		local powerIDs = allTierInfo[i] and allTierInfo[i].azeritePowerIDs
		if not powerIDs or powerIDs[1] == 13 then break end

		for _, powerID in pairs(powerIDs) do
			local selected = C_AzeriteEmpoweredItem.IsPowerSelected(empoweredItemLocation, powerID)
			if selected then
				local spellID = TT:Azerite_PowerToSpell(powerID)
				local name, icon = C_Spell.GetSpellName(spellID), C_Spell.GetSpellTexture(spellID)
				local texture = button["textureIcon"..i]
				if name and texture then
					texture:SetTexture(icon)
					texture.bg:Show()
				end
			end
		end
	end
end

function M:ItemLevel_UpdateInfo(slotFrame, info, upgradeInfo, quality)
	local infoType = type(info)
	local level
	if infoType == "table" then
		level = info.iLvl
	else
		level = info
	end

	if (level and level > 1) and (quality and quality > 1) then
		slotFrame.iLvlText:SetText(level)
	end

	if upgradeInfo and upgradeInfo.trackString then
		local r, g, b = B.SmoothColor(upgradeInfo.currentLevel, upgradeInfo.maxLevel, true)
		slotFrame.iSlotText:SetText(upgradeInfo.trackString)
		slotFrame.iSlotText:SetTextColor(r, g, b)
		slotFrame.iLvlText:SetTextColor(r, g, b)
	end

	if infoType == "table" then
		local enchant = info.enchantText
		if enchant then
			slotFrame.enchantText:SetText(enchant)
		end

		local gemStep, essenceStep = 1, 1
		for i = 1, 10 do
			local texture = slotFrame["textureIcon"..i]
			local bg = texture.bg
			local gem = info.gems and info.gems[gemStep]
			local color = info.gemsColor and info.gemsColor[gemStep]
			local essence = not gem and (info.essences and info.essences[essenceStep])
			if gem then
				texture:SetTexture(gem)
				if color then
					bg:SetBackdropBorderColor(color.r, color.g, color.b)
				end
				bg:Show()

				gemStep = gemStep + 1
			elseif essence and next(essence) then
				local r = essence[4]
				local g = essence[5]
				local b = essence[6]
				if r and g and b then
					bg:SetBackdropBorderColor(r, g, b)
				end

				local selected = essence[1]
				texture:SetTexture(selected)
				bg:Show()

				essenceStep = essenceStep + 1
			end
		end
	end
end

function M:ItemLevel_RefreshInfo(link, unit, index, slotFrame)
	C_Timer.After(.1, function()
		local quality = C_Item.GetItemQualityByID(link)
		local info = B.GetItemLevel(link, unit, index, C.db["Misc"]["GemNEnchant"])
		if info == "tooSoon" then return end
		M:ItemLevel_UpdateInfo(slotFrame, info, upgradeInfo, quality)
	end)
end

function M:ItemLevel_SetupLevel(frame, strType, unit)
	if not UnitExists(unit) then return end

	M:CreateItemString(frame, strType)

	for index, slot in pairs(inspectSlots) do
		if index ~= 4 then
			local slotFrame = _G[strType..slot.."Slot"]
			slotFrame.iLvlText:SetText("")
			slotFrame.iSlotText:SetText("")
			slotFrame.enchantText:SetText("")

			slotFrame.iLvlText:SetTextColor(1, 1, 1)
			slotFrame.iSlotText:SetTextColor(1, 1, 1)
			for i = 1, 10 do
				local texture = slotFrame["textureIcon"..i]
				B.SetBorderColor(texture.bg)
				texture:SetTexture(nil)
				texture.bg:Hide()
			end

			local link = GetInventoryItemLink(unit, index)
			if link then
				local upgradeInfo = C_Item.GetItemUpgradeInfo(link)
				local quality = C_Item.GetItemQualityByID(link)
				local info = B.GetItemLevel(link, unit, index, C.db["Misc"]["GemNEnchant"])
				if info == "tooSoon" then
					M:ItemLevel_RefreshInfo(link, unit, index, slotFrame)
				else
					M:ItemLevel_UpdateInfo(slotFrame, info, upgradeInfo, quality)
				end

				if strType == "Character" then
					M:ItemLevel_UpdateTraits(slotFrame, index, link)
				end
			end
		end
	end
end

function M:ItemLevel_UpdatePlayer()
	M:ItemLevel_SetupLevel(CharacterFrame, "Character", "player")
end

function M:ItemLevel_UpdateInspect(...)
	local guid = ...
	if InspectFrame and InspectFrame.unit and UnitGUID(InspectFrame.unit) == guid then
		M:ItemLevel_SetupLevel(InspectFrame, "Inspect", InspectFrame.unit)
	end
end

function M:ItemLevel_FlyoutUpdate(bag, slot, quality)
	if not self.iLvl then
		self.iLvl = B.CreateFS(self, DB.Font[2]+1, "", false, "BOTTOM", 0, 0)
		self.iSlot = B.CreateFS(self, DB.Font[2]+1, "", false, "TOP", 1, -1)
	else
		self.iLvl:SetText("")
		self.iSlot:SetText("")
		self.iLvl:SetTextColor(1, 1, 1)
		self.iSlot:SetTextColor(1, 1, 1)
	end

	if quality and quality > 1 then
		local link, level
		if bag then
			link = C_Container.GetContainerItemLink(bag, slot)
			level = B.GetItemLevel(link, bag, slot)
		else
			link = GetInventoryItemLink("player", slot)
			level = B.GetItemLevel(link, "player", slot)
		end

		self.iLvl:SetText(level)

		if link then
			local upgradeInfo = C_Item.GetItemUpgradeInfo(link)
			if upgradeInfo and upgradeInfo.trackString then
				local r, g, b = B.SmoothColor(upgradeInfo.currentLevel, upgradeInfo.maxLevel, true)
				self.iSlot:SetText(upgradeInfo.trackString)
				self.iSlot:SetTextColor(r, g, b)
				self.iLvl:SetTextColor(r, g, b)
			end
		end
	end
end

function M:ItemLevel_FlyoutSetup()
	local location = self.location
	if not location then return end

	if self.iLvl then
		self.iLvl:SetText("")
		self.iLvl:SetTextColor(1, 1, 1)
	end

	if self.iSlot then
		self.iSlot:SetText("")
		self.iSlot:SetTextColor(1, 1, 1)
	end

	if tonumber(location) then
		if location >= EQUIPMENTFLYOUT_FIRST_SPECIAL_LOCATION then return end

		local _, _, bags, voidStorage, slot, bag = EquipmentManager_UnpackLocation(location)
		if voidStorage then return end
		local quality = select(13, EquipmentManager_GetItemInfoByLocation(location))
		if bags then
			M.ItemLevel_FlyoutUpdate(self, bag, slot, quality)
		else
			M.ItemLevel_FlyoutUpdate(self, nil, slot, quality)
		end
	else
		local itemLocation = self:GetItemLocation()
		local quality = itemLocation and C_Item.GetItemQuality(itemLocation)
		if itemLocation:IsBagAndSlot() then
			local bag, slot = itemLocation:GetBagAndSlot()
			M.ItemLevel_FlyoutUpdate(self, bag, slot, quality)
		elseif itemLocation:IsEquipmentSlot() then
			local slot = itemLocation:GetEquipmentSlot()
			M.ItemLevel_FlyoutUpdate(self, nil, slot, quality)
		end
	end
end

function M:ItemLevel_ScrappingUpdate()
	if not self.iLvl then
		self.iLvl = B.CreateFS(self, DB.Font[2]+1, "", false, "BOTTOMLEFT", 1, 0)
		self.iSlot = B.CreateFS(self, DB.Font[2]+1, "", false, "TOPRIGHT", 0, -2)
	else
		self.iLvl:SetText("")
		self.iSlot:SetText("")
	end

	local quality = 1
	if self.itemLocation and not self.item:IsItemEmpty() and self.item:GetItemName() then
		quality = self.item:GetItemQuality()
	end
	if self.itemLink and quality > 1 then
		local level = B.GetItemLevel(self.itemLink)
		local slot = B.GetItemType(self.itemLink)

		self.iLvl:SetText(level)
		self.iSlot:SetText(slot)
	end
end

function M:ItemLevel_ScrappingSetup()
	for button in self.ItemSlots.scrapButtons:EnumerateActive() do
		if button and not button.iLvl then
			hooksecurefunc(button, "RefreshIcon", M.ItemLevel_ScrappingUpdate)
		end
	end
end

function M.ItemLevel_ScrappingShow(event, addon)
	if addon == "Blizzard_ScrappingMachineUI" then
		hooksecurefunc(ScrappingMachineFrame, "SetupScrapButtonPool", M.ItemLevel_ScrappingSetup)

		B:UnregisterEvent(event, M.ItemLevel_ScrappingShow)
	end
end

function M:ItemLevel_UpdateMerchant(link)
	if not self.iLvl then
		self.iLvl = B.CreateFS(_G[self:GetName().."ItemButton"], DB.Font[2]+1, "", false, "BOTTOMLEFT", 1, 0)
		self.iSlot = B.CreateFS(_G[self:GetName().."ItemButton"], DB.Font[2]+1, "", false, "TOPRIGHT", 0, -2)
	else
		self.iLvl:SetText("")
		self.iSlot:SetText("")
	end

	local quality = link and C_Item.GetItemQualityByID(link) or nil
	if quality and quality > 1 then
		local level = B.GetItemLevel(link)
		local slot = B.GetItemType(link)

		self.iLvl:SetText(level)
		self.iSlot:SetText(slot)
	end
end

function M.ItemLevel_UpdateTradePlayer(index)
	local button = _G["TradePlayerItem"..index]
	local link = GetTradePlayerItemLink(index)
	M.ItemLevel_UpdateMerchant(button, link)
end

function M.ItemLevel_UpdateTradeTarget(index)
	local button = _G["TradeRecipientItem"..index]
	local link = GetTradeTargetItemLink(index)
	M.ItemLevel_UpdateMerchant(button, link)
end

local itemCache = {}

function M.ItemLevel_ReplaceItemLink(link, name)
	if not link then return end

	local modLink = itemCache[link]
	if not modLink then
		local itemExtra = B.GetItemExtra(link)
		if itemExtra then
			modLink = string.gsub(link, "|h%[(.-)%]|h", "|h"..itemExtra..name.."|h")
			itemCache[link] = modLink
		end
	end
	return modLink
end

function M:GuildNewsButtonOnClick(btn)
	if self.isEvent or not self.playerName then return end
	if btn == "LeftButton" and IsShiftKeyDown() then
		if MailFrame:IsShown() then
			MailFrameTab_OnClick(nil, 2)
			SendMailNameEditBox:SetText(self.playerName)
			SendMailNameEditBox:HighlightText()
		else
			ChatFrame_OpenChat(self.playerName)
		end
	end
end

function M:ItemLevel_ReplaceGuildNews(_, _, playerName)
	self.playerName = playerName

	local newText = string.gsub(self.text:GetText(), "(|Hitem:%d+:.-|h%[(.-)%]|h)", M.ItemLevel_ReplaceItemLink)
	if newText then
		self.text:SetText(newText)
	end

	if not self.hooked then
		self.text:SetFontObject(Game13Font)
		self:HookScript("OnClick", M.GuildNewsButtonOnClick) -- copy name by key shift
		self.hooked = true
	end
end

function M:ItemLevel_UpdateLoot()
	for i = 1, self.ScrollTarget:GetNumChildren() do
		local button = select(i, self.ScrollTarget:GetChildren())
		if button and button.Item and button.GetElementData then
			if not button.iLvl then
				button.iLvl = B.CreateFS(button.Item, DB.Font[2]+1, "", false, "BOTTOMLEFT", 1, 0)
				button.iSlot = B.CreateFS(button.Item, DB.Font[2]+1, "", false, "TOPRIGHT", 0, -2)
			else
				button.iLvl:SetText("")
				button.iSlot:SetText("")
			end

			local slotIndex = button:GetSlotIndex()
			local slotLink = GetLootSlotLink(slotIndex)
			local quality = select(5, GetLootSlotInfo(slotIndex))
			if quality and quality > 1 then
				local level = B.GetItemLevel(slotLink)
				local slot = B.GetItemType(slotLink)

				button.iLvl:SetText(level)
				button.iSlot:SetText(slot)
			end
		end
	end
end

function M:ItemLevel_UpdateBag()
	local button = self.__owner
	if not button.iLvl then
		button.iLvl = B.CreateFS(button, DB.Font[2]+1, "", false, "BOTTOMLEFT", 1, 0)
		button.iSlot = B.CreateFS(button, DB.Font[2]+1, "", false, "TOPRIGHT", 0, -2)
	else
		button.iLvl:SetText("")
		button.iSlot:SetText("")
	end

	local bagID = button.GetBankTabID and button:GetBankTabID() or button:GetBagID()
	local slotID = button.GetContainerSlotID and button:GetContainerSlotID() or button:GetID()
	local info = C_Container.GetContainerItemInfo(bagID, slotID)
	local link = info and info.hyperlink
	local quality = info and info.quality
	if quality and quality > 1 then
		local level = B.GetItemLevel(link, bagID, slotID)
		local slot = B.GetItemType(link, bagID, slotID)

		button.iLvl:SetText(level)
		button.iSlot:SetText(slot)
	end
end

function M:ItemLevel_HandleSlots()
	for button in self.itemButtonPool:EnumerateActive() do
		if not button.hooked then
			button.IconBorder.__owner = button
			hooksecurefunc(button.IconBorder, "SetShown", M.ItemLevel_UpdateBag)
			button.hooked = true
		end
	end
end

function M:ItemLevel_Containers()
	if C.db["Bags"]["Enable"] then return end

	for i = 1, 13 do
		local frame = _G["ContainerFrame"..i]
		if frame then
			hooksecurefunc(frame, "UpdateItemSlots", M.ItemLevel_HandleSlots)
		end
	end
	hooksecurefunc(ContainerFrameCombinedBags, "UpdateItemSlots", M.ItemLevel_HandleSlots)
	hooksecurefunc(AccountBankPanel, "GenerateItemSlotsForSelectedTab", M.ItemLevel_HandleSlots)
end

function M:ShowItemLevel()
	if not C.db["Misc"]["ItemLevel"] then return end

	-- iLvl on CharacterFrame
	CharacterFrame:HookScript("OnShow", M.ItemLevel_UpdatePlayer)
	B:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", M.ItemLevel_UpdatePlayer)

	-- iLvl on InspectFrame
	B:RegisterEvent("INSPECT_READY", M.ItemLevel_UpdateInspect)

	-- iLvl on FlyoutButtons
	hooksecurefunc("EquipmentFlyout_UpdateItems", function()
		for _, button in pairs(EquipmentFlyoutFrame.buttons) do
			if button:IsShown() then
				M.ItemLevel_FlyoutSetup(button)
			end
		end
	end)

	-- iLvl on ScrappingMachineFrame
	B:RegisterEvent("ADDON_LOADED", M.ItemLevel_ScrappingShow)

	-- iLvl on MerchantFrame
	hooksecurefunc("MerchantFrameItem_UpdateQuality", M.ItemLevel_UpdateMerchant)

	-- iLvl on TradeFrame
	hooksecurefunc("TradeFrame_UpdatePlayerItem", M.ItemLevel_UpdateTradePlayer)
	hooksecurefunc("TradeFrame_UpdateTargetItem", M.ItemLevel_UpdateTradeTarget)

	-- iLvl on GuildNews
	hooksecurefunc("GuildNewsButton_SetText", M.ItemLevel_ReplaceGuildNews)

	-- iLvl on LootFrame
	hooksecurefunc(LootFrame.ScrollBox, "Update", M.ItemLevel_UpdateLoot)

	-- iLvl on default Container
	M:ItemLevel_Containers()
end
M:RegisterMisc("GearInfo", M.ShowItemLevel)
