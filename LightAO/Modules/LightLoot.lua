local B, C, L, DB = unpack(LightAO)

local iconSize = 33

local fontSizeItem = math.floor(select(2, GameFontWhite:GetFont()) + .5)

local point = {"CENTER", 300, 0}
local slots = {}

local LightLoot = CreateFrame("Button", "LightLoot", UIParent, "BackdropTemplate")
LightLoot:RegisterForClicks("AnyUp")
LightLoot:SetClampedToScreen(true)
LightLoot:SetClampRectInsets(0, 0, 14, 0)
LightLoot:SetFrameStrata("TOOLTIP")
LightLoot:SetHitRectInsets(0, 0, -14, 0)
LightLoot:SetMovable(true)
LightLoot:SetParent(UIParent)
LightLoot:SetToplevel(true)

LightLoot:SetScript("OnEvent", function(self, event, ...)
	self[event](self, event, ...)
end)

LightLoot:SetScript("OnHide", function(self)
	StaticPopup_Hide("CONFIRM_LOOT_DISTRIBUTION")
	CloseLoot()
end)

local Title = B.CreateFS(LightLoot, 18, "", false, "TOP", 0, 20)
LightLoot.Title = Title

local function OnEnter(self)
	local slot = self:GetID()
	if GetLootSlotType(slot) == LOOT_SLOT_ITEM then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetLootItem(slot)
		CursorUpdate(self)
	end
	self.glow:Show()
end

local function OnLeave(self)
	self.glow:Hide()
	GameTooltip:Hide()
	ResetCursor()
end

local function OnClick(self)
	LootFrame.selectedLootButton = self
	LootFrame.selectedSlot = self:GetID()
	LootFrame.selectedQuality = self.lootQuality
	LootFrame.selectedItemName = self.name:GetText()

	if IsModifiedClick() then
		HandleModifiedItemClick(GetLootSlotLink(self:GetID()))
	else
		StaticPopup_Hide("CONFIRM_LOOT_DISTRIBUTION")
		LootSlot(self:GetID())
	end
end

local function OnUpdate(self)
	if GameTooltip:IsOwned(self) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetLootItem(self:GetID())
		CursorOnUpdate(self)
	end
end

local function CreateSlot(id)
	local cr, cg, cb = DB.cr, DB.cg, DB.cb

	local button = CreateFrame("Button", "LightLootSlot"..id, LightLoot, "BackdropTemplate")
	button:SetHeight(math.max(fontSizeItem, iconSize))
	button:SetPoint("LEFT", 5, 0)
	button:SetPoint("RIGHT", -5, 0)
	button:SetID(id)

	button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	button:SetScript("OnEnter", OnEnter)
	button:SetScript("OnLeave", OnLeave)
	button:SetScript("OnClick", OnClick)
	button:SetScript("OnUpdate", OnUpdate)

	local icBD = CreateFrame("Frame", nil, button, "BackdropTemplate")
	icBD:SetSize(iconSize, iconSize)
	icBD:SetPoint("LEFT", button)
	B.CreateBD(icBD, 1)
	button.icBD = icBD

	local icon = icBD:CreateTexture(nil, "ARTWORK")
	icon:SetAlpha(.8)
	icon:SetTexCoord(.08, .92, .08, .92)
	icon:SetPoint("TOPLEFT", 1, -1)
	icon:SetPoint("BOTTOMRIGHT", -1, 1)
	button.icon = icon

	local glow = button:CreateTexture(nil, "ARTWORK")
	glow:SetAlpha(.5)
	glow:SetPoint("TOPLEFT", icon, "TOPRIGHT", 3, 0)
	glow:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT")
	glow:SetTexture(DB.bdTex)
	glow:SetVertexColor(cr, cg, cb)
	glow:Hide()
	button.glow = glow

	local name = B.CreateFS(icBD, 14, "")
	name:SetJustifyH("LEFT")
	name:SetPoint("LEFT", icon, "RIGHT", 5, 0)
	name:SetNonSpaceWrap(true)
	button.name = name

	local count = B.CreateFS(icBD, 14, "", false, "BOTTOMRIGHT", -1, 1)
	button.count = count

	local quest = B.CreateFS(icBD, 14, "!", false, "LEFT", 3, 0)
	button.quest = quest

	slots[id] = button
	return button
end

function LightLoot:UpdateWidth()
	local maxWidth = 0
	for _, slot in next, slots do
		if slot:IsShown() then
			local width = slot.name:GetStringWidth()
			if width > maxWidth then
				maxWidth = width
			end
		end
	end

	self:SetWidth(math.max(maxWidth + 16 + iconSize, self.Title:GetStringWidth() + 5))
end

function LightLoot:AnchorSlots()
	local buttonSize = math.max(iconSize, fontSizeItem)
	local shownSlots = 0

	for i = 1, #slots do
		local button = slots[i]
		if button:IsShown() then
			shownSlots = shownSlots + 1
			button:SetPoint("TOP", LightLoot, 0, (-5 + iconSize) - (shownSlots * iconSize) - (shownSlots - 1) * 5)
		end
	end

	self:SetHeight(math.max(shownSlots * iconSize + 10 + (shownSlots - 1) * 5 , iconSize))
end

function LightLoot:LOOT_OPENED(event, autoloot)
	self:Show()

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
		local x, y = GetCursorPosition()
		x = x / self:GetEffectiveScale()
		y = y / self:GetEffectiveScale()

		self:ClearAllPoints()
		self:SetPoint("TOPLEFT", nil, "BOTTOMLEFT", x - 40, y + 20)
		self:GetCenter()
		self:Raise()
	else
		self:ClearAllPoints()
		self:SetUserPlaced(false)
		self:SetPoint(unpack(point))
	end

	local maxQuality = 0
	local items = GetNumLootItems()
	if items > 0 then
		for i = 1, items do
			local slot = slots[i] or CreateSlot(i)
			local lootIcon, lootName, lootQuantity, currencyID, lootQuality, locked, isQuestItem, questID, isActive = GetLootSlotInfo(i)
			if lootIcon then
				local color = ITEM_QUALITY_COLORS[lootQuality]
				local r, g, b = color.r, color.g, color.b
				local slotType = GetLootSlotType(i)

				if slotType == LOOT_SLOT_MONEY then
					lootName = lootName:gsub("\n", "，")
				end

				if lootQuantity and lootQuantity > 1 then
					slot.count:SetText(B.FormatNB(lootQuantity))
					slot.count:Show()
				else
					slot.count:Hide()
				end

				if questId and not isActive then
					slot.quest:Show()
				else
					slot.quest:Hide()
				end

				if (lootQuality and lootQuality >= 0) or questId or isQuestItem then
					if questId or isQuestItem then
						r, g, b = 1, .8, 0
					end
					slot.name:SetTextColor(r, g, b)
					slot.icBD:SetBackdropBorderColor(r, g, b)
				else
					slot.name:SetTextColor(.5, .5, .5)
					slot.icBD:SetBackdropBorderColor(.5, .5, .5)
				end

				slot.lootQuality = lootQuality
				slot.isQuestItem = isQuestItem

				slot.name:SetText(lootName)
				slot.icon:SetTexture(lootIcon)

				maxQuality = math.max(maxQuality, lootQuality)

				slot:Enable()
				slot:Show()
			end
		end
	else
		local slot = slots[1] or CreateSlot(1)

		slot.name:SetText(NONE)
		slot.name:SetTextColor(.5, .5, .5)
		slot.icon:SetTexture(nil)

		slot.count:Hide()
		slot.quest:Hide()
		slot.glow:Hide()
		slot:Disable()
		slot:Show()
	end

	local color = ITEM_QUALITY_COLORS[maxQuality]
	local r, g, b = color.r, color.g, color.b
	self:SetBackdropBorderColor(r, g, b)
	self.Shadow:SetBackdropBorderColor(r, g, b)
	self.Title:SetTextColor(r, g, b)

	self:AnchorSlots()
	self:UpdateWidth()
end
LightLoot:RegisterEvent("LOOT_OPENED")

function LightLoot:LOOT_SLOT_CLEARED(event, slot)
	if not self:IsShown() then return end

	slots[slot]:Hide()
	self:AnchorSlots()
end
LightLoot:RegisterEvent("LOOT_SLOT_CLEARED")

function LightLoot:LOOT_CLOSED()
	StaticPopup_Hide("LOOT_BIND")
	self:Hide()

	for _, slot in pairs(slots) do
		slot:Hide()
	end
end
LightLoot:RegisterEvent("LOOT_CLOSED")

function LightLoot:OPEN_MASTER_LOOT_LIST()
	MasterLooterFrame_Show(LootFrame.selectedLootButton)
end
LightLoot:RegisterEvent("OPEN_MASTER_LOOT_LIST")

function LightLoot:UPDATE_MASTER_LOOT_LIST()
	if LootFrame.selectedLootButton then
		MasterLooterFrame_UpdatePlayers()
	end
end
LightLoot:RegisterEvent("UPDATE_MASTER_LOOT_LIST")

function LightLoot:PLAYER_LOGIN()
	B.CreateBD(LightLoot)
	B.CreateSD(LightLoot)
	B.CreateTex(LightLoot)
end
LightLoot:RegisterEvent("PLAYER_LOGIN")

LootFrame:UnregisterAllEvents()
table.insert(UISpecialFrames, "LightLoot")

-- fix blizzard setpoint connection bs
hooksecurefunc(MasterLooterFrame, 'Hide', MasterLooterFrame.ClearAllPoints)
