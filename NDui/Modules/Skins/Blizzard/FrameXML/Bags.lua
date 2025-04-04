local _, ns = ...
local B, C, L, DB = unpack(ns)

local MAX_CONTAINER_ITEMS = 36
local backpackTexture = "Interface\\Buttons\\Button-Backpack-Up"

local function handleMoneyFrame(frame)
	if frame.MoneyFrame then
		B.StripTextures(frame.MoneyFrame)
		B.CreateBDFrame(frame.MoneyFrame, .25)
	end
end

local function createBagIcon(frame, index)
	if not frame.bagIcon then
		frame.bagIcon = frame.PortraitButton:CreateTexture(nil, "ARTWORK")
		B.ReskinIcon(frame.bagIcon)
		frame.bagIcon:SetPoint("TOPLEFT", 5, -3)
		frame.bagIcon:SetSize(32, 32)
	end
	if index == 1 then
		frame.bagIcon:SetTexture(backpackTexture) -- backpack
	end
	handleMoneyFrame(frame)
end

local function replaceSortTexture(texture)
	texture:SetTexture("Interface\\Icons\\INV_Pet_Broom") -- HD version
	texture:SetTexCoord(unpack(DB.TexCoord))
end

local function ReskinSortButton(button)
	replaceSortTexture(button:GetNormalTexture())
	replaceSortTexture(button:GetPushedTexture())
	B.CreateBDFrame(button, .25, nil, -1)

	local highlight = button:GetHighlightTexture()
	highlight:SetColorTexture(1, 1, 1, .25)
	highlight:SetAllPoints(button)
end

local function ReskinBagSlot(bu)
	B.CleanTextures(bu)

	bu.bg = B.ReskinIcon(bu.icon)
	B.ReskinBorder(bu.IconBorder)
	B.ReskinHLTex(bu, bu.bg)
	B.ReskinCPTex(bu, bu.bg)

	local questTexture = bu.IconQuestTexture
	if questTexture then
		questTexture:SetDrawLayer("BACKGROUND")
		questTexture:SetSize(1, 1)
	end

	local hl = bu.SlotHighlightTexture
	if hl then
		hl:SetColorTexture(1, 1, 0, .5)
	end
end

local function updateContainer(frame)
	local id = frame:GetID()
	local name = frame:GetName()

	if id == 0 then
		BagItemSearchBox:ClearAllPoints()
		BagItemSearchBox:SetPoint("TOPLEFT", frame, "TOPLEFT", 50, -35)
		BagItemAutoSortButton:ClearAllPoints()
		BagItemAutoSortButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -9, -31)
	end

	for i = 1, frame.size do
		local itemButton = _G[name.."Item"..i]
		local questTexture = _G[name.."Item"..i.."IconQuestTexture"]
		if itemButton and questTexture:IsShown() then
			itemButton.IconBorder:SetVertexColor(1, 1, 0)
		end
	end

	if frame.bagIcon and id ~= 0 then
		local invID = C_Container.ContainerIDToInventoryID(id)
		if invID then
			local icon = GetInventoryItemTexture("player", invID)
			frame.bagIcon:SetTexture(icon or backpackTexture)
		end
	end
end

local function emptySlotBG(button)
	if button.ItemSlotBackground then
		button.ItemSlotBackground:Hide()
	end
end

local function handleBagSlots(self)
	for button in self.itemButtonPool:EnumerateActive() do
		if not button.bg then
			ReskinBagSlot(button)
		end
	end
end

local function handleBankTab(tab)
	if not tab.styled then
		tab.Border:SetAlpha(0)
		tab:SetNormalTexture(0)
		tab:SetPushedTexture(0)
		tab:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		tab.SelectedTexture:SetTexture(DB.pushedTex)
		B.CreateBDFrame(tab)
		tab.Icon:SetTexCoord(unpack(DB.TexCoord))

		tab.styled = true
	end
end

C.OnLoginThemes["Bags"] = function()

	local menu = AccountBankPanel and AccountBankPanel.TabSettingsMenu
	if menu then
		B.StripTextures(menu)
		B.ReskinIconSelector(menu)
		menu.DepositSettingsMenu:DisableDrawLayer("OVERLAY")

		for _, child in pairs({menu.DepositSettingsMenu:GetChildren()}) do
			if child:IsObjectType("CheckButton") then
				B.ReskinCheck(child)
				child:SetSize(24, 24)
			elseif child.Arrow then
				B.ReskinDropDown(child)
			end
		end
	end

	if C.db["Bags"]["Enable"] then return end

	for i = 1, 13 do
		local frameName = "ContainerFrame"..i
		local frame = _G[frameName]
		local name = frame.TitleText or _G[frameName.."TitleText"]
		name:SetDrawLayer("OVERLAY")
		name:ClearAllPoints()
		name:SetPoint("TOP", 0, -10)
		B.ReskinClose(frame.CloseButton)

		B.StripTextures(frame)
		B.SetBD(frame)
		frame.PortraitContainer:Hide()
		if frame.Bg then frame.Bg:Hide() end
		createBagIcon(frame, i)
		hooksecurefunc(frame, "Update", updateContainer)
		hooksecurefunc(frame, "UpdateItemSlots", handleBagSlots)
	end

	B.StripTextures(BackpackTokenFrame)
	B.CreateBDFrame(BackpackTokenFrame, .25)

	hooksecurefunc(BackpackTokenFrame, "Update", function(self)
		local tokens = self.Tokens
		if next(tokens) then
			for i = 1, #tokens do
				local token = tokens[i]
				if not token.styled then
					B.ReskinIcon(token.Icon)
					token.styled = true
				end
			end
		end
	end)

	B.ReskinInput(BagItemSearchBox)
	ReskinSortButton(BagItemAutoSortButton)

	-- Combined bags
	B.StripTextures(ContainerFrameCombinedBags)
	B.SetBD(ContainerFrameCombinedBags)
	createBagIcon(ContainerFrameCombinedBags, 1)
	ContainerFrameCombinedBags.PortraitButton.Highlight:SetTexture("")
	hooksecurefunc(ContainerFrameCombinedBags, "UpdateItemSlots", handleBagSlots)

	-- [[ Bank ]]

	BankFrameMoneyFrameBorder:Hide()
	B.StripTextures(BankSlotsFrame)
	BankSlotsFrame.EdgeShadows:Hide()
	B.ReskinFrame(BankFrame)
	B.ReskinButton(BankFramePurchaseButton)
	B.ReskinInput(BankItemSearchBox)
	B.ReskinFrameTab(BankFrame, 3)

	for i = 1, 28 do
		ReskinBagSlot(_G["BankFrameItem"..i])
	end

	for i = 1, 7 do
		ReskinBagSlot(BankSlotsFrame["Bag"..i])
	end

	ReskinSortButton(BankItemAutoSortButton)

	hooksecurefunc("BankFrameItemButton_Update", function(button)
		if not button.isBag and button.IconQuestTexture:IsShown() then
			button.IconBorder:SetVertexColor(1, 1, 0)
		end
	end)

	-- [[ Reagent bank ]]

	ReagentBankFrame:DisableDrawLayer("BACKGROUND")
	ReagentBankFrame:DisableDrawLayer("BORDER")
	ReagentBankFrame:DisableDrawLayer("ARTWORK")
	ReagentBankFrame.NineSlice:SetAlpha(0)
	ReagentBankFrame.EdgeShadows:Hide()

	B.ReskinButton(ReagentBankFrame.DespositButton)
	B.ReskinButton(ReagentBankFrameUnlockInfoPurchaseButton)

	-- make button more visible
	B.StripTextures(ReagentBankFrameUnlockInfo)
	ReagentBankFrameUnlockInfoBlackBG:SetColorTexture(.1, .1, .1)

	local reagentButtonsStyled = false
	ReagentBankFrame:HookScript("OnShow", function()
		if not reagentButtonsStyled then
			for i = 1, 98 do
				local button = _G["ReagentBankFrameItem"..i]
				ReskinBagSlot(button)
				BankFrameItemButton_Update(button)
			end
			reagentButtonsStyled = true
		end
	end)

	-- [[ Account bank ]]
	AccountBankPanel.NineSlice:SetAlpha(0)
	AccountBankPanel.EdgeShadows:Hide()
	B.ReskinButton(AccountBankPanel.ItemDepositFrame.DepositButton)
	B.ReskinCheck(AccountBankPanel.ItemDepositFrame.IncludeReagentsCheckbox)
	handleMoneyFrame(AccountBankPanel)
	B.ReskinButton(AccountBankPanel.MoneyFrame.WithdrawButton)
	B.ReskinButton(AccountBankPanel.MoneyFrame.DepositButton)

	hooksecurefunc(AccountBankPanel, "GenerateItemSlotsForSelectedTab", handleBagSlots)

	hooksecurefunc(AccountBankPanel, "RefreshBankTabs", function(self)
		for tab in self.bankTabPool:EnumerateActive() do
			handleBankTab(tab)
		end
	end)
	handleBankTab(AccountBankPanel.PurchaseTab)

	B.ReskinButton(AccountBankPanel.PurchasePrompt.TabCostFrame.PurchaseButton)
end