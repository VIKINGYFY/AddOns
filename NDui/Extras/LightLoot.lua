local _, ns = ...
local B, C, L, DB = unpack(ns)
local EX = B:GetModule("Extras")

local iconSize = 32
local fontSize = math.floor(select(2, GameFontWhite:GetFont()) + .5)

local LightLoot = CreateFrame("Button", "LightLoot", UIParent, "BackdropTemplate")
LightLoot:RegisterForClicks("AnyUp")
LightLoot:RegisterEvent("PLAYER_LOGIN")
LightLoot:RegisterEvent("LOOT_OPENED")
LightLoot:RegisterEvent("LOOT_SLOT_CLEARED")
LightLoot:RegisterEvent("LOOT_SLOT_CHANGED")
LightLoot:RegisterEvent("LOOT_CLOSED")
LightLoot:RegisterEvent("OPEN_MASTER_LOOT_LIST")
LightLoot:RegisterEvent("UPDATE_MASTER_LOOT_LIST")
LightLoot:SetFrameStrata("HIGH")
LightLoot:SetToplevel(true)
LightLoot:Hide()

LightLoot:SetScript("OnEvent", function(self, event, ...)
	self[event](self, event, ...)
end)

LightLoot:SetScript("OnHide", function(self)
	StaticPopup_Hide("CONFIRM_LOOT_DISTRIBUTION")
	CloseLoot()

	if _G.MasterLooterFrame then
		_G.MasterLooterFrame:Hide()
	end
end)

local function SetLootTooltip(self)
	local slotID = self:GetID()
	local slotType = GetLootSlotType(slotID)

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")

	if slotType == Enum.LootSlotType.Currency then
		GameTooltip:SetLootCurrency(slotID)
	elseif slotType == Enum.LootSlotType.Item then
		GameTooltip:SetLootItem(slotID)
	end
end

local function Button_OnEnter(self)
	SetLootTooltip(self)
	CursorUpdate(self)
end

local function Button_OnLeave(self)
	GameTooltip:Hide()
	ResetCursor()
end

local function Button_OnUpdate(self)
	if GameTooltip:IsOwned(self) then
		SetLootTooltip(self)
		CursorOnUpdate(self)
	end
end

local function Button_OnClick(self)
	_G.LootFrame.selectedItemName = self.name:GetText()
	_G.LootFrame.selectedLootFrame = self:GetName()
	_G.LootFrame.selectedQuality = self.quality
	_G.LootFrame.selectedSlot = self:GetID()
	_G.LootFrame.selectedTexture = self.icon:GetTexture()

	if IsModifiedClick() then
		local slotLink = GetLootSlotLink(_G.LootFrame.selectedSlot)
		HandleModifiedItemClick(slotLink)
	else
		StaticPopup_Hide("CONFIRM_LOOT_DISTRIBUTION")
		LootSlot(_G.LootFrame.selectedSlot)
	end
end

local function CreateSlot(index)
	if not LightLoot.slots[index] then
		local button = CreateFrame("Button", "LightLootSlot"..index, LightLoot, "BackdropTemplate")
		button:SetHighlightTexture(DB.bdTex)
		button:SetHeight(math.max(fontSize, iconSize))
		button:SetPoint("LEFT", LightLoot, "LEFT", DB.margin, 0)
		button:SetPoint("RIGHT", LightLoot, "RIGHT", -DB.margin, 0)
		button:SetID(index)

		button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
		button:SetScript("OnEnter", Button_OnEnter)
		button:SetScript("OnLeave", Button_OnLeave)
		button:SetScript("OnClick", Button_OnClick)
		button:SetScript("OnUpdate", Button_OnUpdate)

		local border = CreateFrame("Frame", nil, button, "BackdropTemplate")
		border:SetSize(iconSize, iconSize)
		border:SetPoint("LEFT", button, "LEFT")
		B.CreateBD(border, .25)
		button.border = border

		local icon = border:CreateTexture(nil, "ARTWORK")
		icon:SetTexCoord(unpack(DB.TexCoord))
		icon:SetInside(border)
		icon:SetTexture(nil)
		button.icon = icon

		local tier = border:CreateTexture(nil, "OVERLAY")
		tier:SetPoint("TOPLEFT", -3, 2)
		tier:SetAtlas(nil)
		button.tier = tier

		local glow = button:GetHighlightTexture()
		glow:SetVertexColor(DB.r, DB.g, DB.b, .5)
		glow:SetPoint("TOPLEFT", border, "TOPRIGHT", DB.margin, 0)
		glow:SetPoint("BOTTOMLEFT", border, "BOTTOMRIGHT", DB.margin, 0)
		glow:SetPoint("RIGHT", button, "RIGHT")
		button.glow = glow

		local name = B.CreateFS(border, 14)
		name:SetJustifyH("LEFT")
		B.UpdatePoint(name, "LEFT", border, "RIGHT", DB.margin, 0)
		button.name = name

		local text = B.CreateFS(border, 12, "", false, "BOTTOMRIGHT", -1, 1)
		button.text = text

		local quest = B.CreateFS(border, 16, "", false, "LEFT", 3, 0)
		button.quest = quest

		LightLoot.slots[index] = button
	end

	return LightLoot.slots[index]
end

local function UpdateSlot(slot, index)
	local lootIcon, lootName, lootQuantity, currencyID, lootQuality, isLocked, isQuestItem, questID, isActive = GetLootSlotInfo(index)
	local r, g, b = C_Item.GetItemQualityColor(lootQuality or 0)
	local slotType = GetLootSlotType(index)
	local slotLink = GetLootSlotLink(index)

	local itemTier, itemText
	if slotLink then
		itemTier = C_TradeSkillUI.GetItemReagentQualityByItemInfo(slotLink)

		local itemID, _, _, _, _, itemClassID, itemSubClassID = C_Item.GetItemInfoInstant(slotLink)
		if EX.isCollection(itemID, itemClassID, itemSubClassID) then
			itemText = B.GetItemType(slotLink)
		elseif EX.isEquipment(itemID, itemClassID) then
			itemText = B.GetItemLevel(slotLink)
		elseif lootQuantity and lootQuantity > 1 then
			itemText = B.Numb(lootQuantity)
		end
	end

	if slotType == Enum.LootSlotType.Money then
		lootName = lootName:gsub("\n", "，")
	end

	if questId or isQuestItem then
		r, g, b = 1, 1, 0
	end

	if itemTier then
		slot.tier:SetAtlas(format("Professions-Icon-Quality-Tier%d-Inv", itemTier), true)
	end

	if itemText then
		slot.text:SetText(itemText)
		slot.text:SetTextColor(r, g, b)
	end

	if questId and not isActive then
		slot.quest:SetText("!")
		slot.quest:SetTextColor(r, g, b)
	end

	slot.name:SetText(lootName)
	slot.name:SetTextColor(r, g, b)
	slot.icon:SetTexture(lootIcon)
	slot.border:SetBackdropBorderColor(r, g, b)
	slot.quality = lootQuality or 0

	slot:Enable()
	slot:Show()
end

local function ClearSlot(slot)
	local r, g, b = C_Item.GetItemQualityColor(0)
	slot.name:SetText("")
	slot.text:SetText("")
	slot.quest:SetText("")
	slot.tier:SetAtlas(nil)
	slot.icon:SetTexture(nil)
	slot.text:SetTextColor(r, g, b)
	slot.quest:SetTextColor(r, g, b)
	slot.border:SetBackdropBorderColor(r, g, b)
	slot.quality = 0

	slot:Disable()
	slot:Hide()
end

function LightLoot:UpdateLayout()
	local maxWidth, maxQuality, shownSlot = 0, 0, 0

	for _, slot in ipairs(self.slots) do
		if slot:IsShown() then
			local nameWidth = slot.name:GetWidth() or 0
			maxWidth = math.max(maxWidth, nameWidth)

			local lootQuality = slot.quality or 0
			maxQuality = math.max(maxQuality, lootQuality)

			shownSlot = shownSlot + 1
			slot:SetPoint("TOP", self, "TOP", 0, (-DB.margin + iconSize) - (shownSlot * iconSize) - (shownSlot - 1) * DB.margin)
		end
	end

	self:SetWidth(math.max(maxWidth + iconSize + DB.margin*3, self.Title:GetWidth()))
	self:SetHeight(math.max(shownSlot * iconSize + (shownSlot - 1) * DB.margin + DB.margin*2, iconSize))

	local r, g, b = C_Item.GetItemQualityColor(maxQuality)
	self.Border:SetBackdropBorderColor(r, g, b)
	self.Title:SetTextColor(r, g, b)

	if self.Border.__shadow then
		self.Border.__shadow:SetBackdropBorderColor(r, g, b)
	end
end

function LightLoot:PLAYER_LOGIN()
	B.CreateMF(self)

	self.slots = {}
	self.Border = B.SetBD(self)
	self.Title = B.CreateFS(self, 18, "", false, "TOP", 0, 20)

	_G.LootFrame:UnregisterAllEvents()
	table.insert(_G.UISpecialFrames, "LightLoot")

	hooksecurefunc(_G.MasterLooterFrame, "Hide", _G.MasterLooterFrame.ClearAllPoints)
end

function LightLoot:LOOT_OPENED(event, autoloot)
	self:Show()
	self:Raise()

	if not self:IsShown() then
		CloseLoot(not autoLoot)
	end

	if IsFishingLoot() then
		self.Title:SetText(PROFESSIONS_FISHING)
	elseif UnitIsDead("target") then
		self.Title:SetText(UnitName("target"))
	else
		self.Title:SetText(LOOT)
	end

	if GetCVar("lootUnderMouse") == "1" then
		if CanAutoSetGamePadCursorControl(true) then
			SetGamePadCursorControl(true)
		end

		local x, y = GetCursorPosition()
		local scale = self:GetEffectiveScale()
		B.UpdatePoint(self, "TOPLEFT", UIParent, "BOTTOMLEFT", (x / scale) - 40, (y / scale) + 20)
	else
		B.UpdatePoint(self, "CENTER", UIParent, "CENTER", 300, 0)
	end

	local items = GetNumLootItems()
	if items > 0 then
		for index = 1, items do
			local slot = self.slots[index] or CreateSlot(index)
			UpdateSlot(slot, index)
		end
	end

	self:UpdateLayout()
end

function LightLoot:LOOT_SLOT_CLEARED(event, index)
	if not self:IsShown() then return end

	local slot = self.slots[index]
	if slot then ClearSlot(slot) end

	self:UpdateLayout()
end

function LightLoot:LOOT_SLOT_CHANGED(event, index)
	if not self:IsShown() then return end

	local slot = self.slots[index]
	if slot then UpdateSlot(slot, index) end

	self:UpdateLayout()
end

function LightLoot:LOOT_CLOSED()
	StaticPopup_Hide("LOOT_BIND")
	self:Hide()

	for _, slot in ipairs(self.slots) do
		ClearSlot(slot)
	end
end

function LightLoot:OPEN_MASTER_LOOT_LIST()
	if _G.LootFrame.selectedLootButton then
		_G.MasterLooterFrame_Show(_G.LootFrame.selectedLootButton)
	end
end

function LightLoot:UPDATE_MASTER_LOOT_LIST()
	if _G.LootFrame.selectedLootButton then
		_G.MasterLooterFrame_UpdatePlayers()
	end
end
