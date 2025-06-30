local _, ns = ...
local B, C, L, DB = unpack(ns)

local function NoTaintArrow(self, direction) -- needs review
	B.StripTextures(self)
	B.SetupTexture(self, direction)
end

C.OnLoginThemes["CharacterFrame"] = function()

	local cr, cg, cb = DB.r, DB.g, DB.b

	B.ReskinFrame(CharacterFrame)
	B.StripTextures(CharacterFrameInsetRight)
	B.ReskinFrameTab(CharacterFrame, 3)

	B.ReskinModelControl(CharacterModelScene)
	CharacterModelScene:DisableDrawLayer("BACKGROUND")
	CharacterModelScene:DisableDrawLayer("BORDER")
	CharacterModelScene:DisableDrawLayer("OVERLAY")

	-- [[ Item buttons ]]
	local function UpdateAzeriteItem(self)
		if not self.styled then
			self.AzeriteTexture:SetAlpha(0)
			self.RankFrame.Texture:SetTexture("")
			self.RankFrame.Label:ClearAllPoints()
			self.RankFrame.Label:SetPoint("TOPLEFT", self, 2, -1)
			self.RankFrame.Label:SetTextColor(1, .5, 0)

			self.styled = true
		end
	end

	local function UpdateAzeriteEmpoweredItem(self)
		self.AzeriteTexture:SetAtlas("AzeriteIconFrame")
		self.AzeriteTexture:SetInside()
		self.AzeriteTexture:SetDrawLayer("BORDER")
	end

	local function UpdateHighlight(self)
		local highlight = self:GetHighlightTexture()
		highlight:SetColorTexture(1, 1, 1, .25)
		highlight:SetInside(self.bg)
	end

	local function UpdateCosmetic(self)
		local itemLink = GetInventoryItemLink("player", self:GetID())
		self.IconOverlay:SetShown(itemLink and C_Item.IsCosmeticItem(itemLink))
	end

	local slots = {
		"Head", "Neck", "Shoulder", "Shirt", "Chest", "Waist", "Legs", "Feet", "Wrist",
		"Hands", "Finger0", "Finger1", "Trinket0", "Trinket1", "Back", "MainHand",
		"SecondaryHand", "Tabard",
	}

	for i = 1, #slots do
		local slot = _G["Character"..slots[i].."Slot"]
		local cooldown = _G["Character"..slots[i].."SlotCooldown"]

		B.StripTextures(slot)

		slot.bg = B.ReskinIcon(slot.icon)
		slot.ignoreTexture:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-LeaveItem-Transparent")
		slot.IconOverlay:SetAtlas("CosmeticIconFrame")
		slot.IconOverlay:SetInside(slot.bg)
		cooldown:SetInside(slot.bg)

		B.ReskinBorder(slot.IconBorder)
		B.ReskinHLTex(slot, slot.bg, nil, true)

		local popout = slot.popoutButton
		popout:SetSize(14, 14)
		B.StripTextures(popout)
		B.SetupTexture(popout, "right")

		if slot.verticalFlyout then
			B.SetupArrow(popout.__texture, "down")
			B.UpdatePoint(popout, "TOP", slot, "BOTTOM", 0, 1)
		else
			B.SetupArrow(popout.__texture, "right")
			B.UpdatePoint(popout, "LEFT", slot, "RIGHT", -1, 0)
		end

		hooksecurefunc(slot, "DisplayAsAzeriteItem", UpdateAzeriteItem)
		hooksecurefunc(slot, "DisplayAsAzeriteEmpoweredItem", UpdateAzeriteEmpoweredItem)
	end

	hooksecurefunc("PaperDollItemSlotButton_Update", function(button)
		-- also fires for bag slots, we don't want that
		if button.popoutButton then
			button.icon:SetShown(GetInventoryItemTexture("player", button:GetID()) ~= nil)
		end
		UpdateCosmetic(button)
		UpdateHighlight(button)
	end)

	-- [[ Stats pane ]]

	local pane = CharacterStatsPane
	pane.ClassBackground:Hide()
	pane.ItemLevelFrame.Corruption:SetPoint("RIGHT", 22, -8)

	local categories = {pane.ItemLevelCategory, pane.AttributesCategory, pane.EnhancementsCategory}
	for _, category in pairs(categories) do
		category.Background:Hide()
		category.Title:SetTextColor(cr, cg, cb)
		local line = category:CreateTexture(nil, "ARTWORK")
		line:SetSize(180, C.mult)
		line:SetPoint("BOTTOM", 0, 5)
		line:SetColorTexture(1, 1, 1, .25)
	end

	-- [[ Sidebar tabs ]]
	local SidebarTabs = PaperDollSidebarTabs
	B.StripTextures(SidebarTabs)
	B.UpdatePoint(SidebarTabs, "BOTTOM", CharacterFrameInsetRight, "TOP", 0, 0)

	local SidebarTab3 = PaperDollSidebarTab3
	B.UpdatePoint(SidebarTab3, "RIGHT", SidebarTabs, "RIGHT", -17, 0)

	for i = 1, #PAPERDOLL_SIDEBARS do
		local tab = _G["PaperDollSidebarTab"..i]
		tab:SetSize(31, 33)
		tab.TabBg:Hide()

		local bg = B.CreateBDFrame(tab)
		B.ReskinHLTex(tab.Highlight, bg)
		B.ReskinHLTex(tab.Hider, bg)

		tab.Icon:SetInside(bg)
		if i == 1 then
			tab.Icon:SetTexCoord(.15, .85, .15, .85)
		end
	end

	-- [[ Equipment manager ]]
	B.ReskinButton(PaperDollFrameEquipSet)
	B.ReskinButton(PaperDollFrameSaveSet)
	B.ReskinScroll(PaperDollFrame.EquipmentManagerPane.ScrollBar)

	hooksecurefunc(PaperDollFrame.EquipmentManagerPane.ScrollBox, "Update", function(self)
		for i = 1, self.ScrollTarget:GetNumChildren() do
			local child = select(i, self.ScrollTarget:GetChildren())
			if child.icon and not child.styled then
				B.HideObject(child.Stripe)
				child.BgTop:SetTexture("")
				child.BgMiddle:SetTexture("")
				child.BgBottom:SetTexture("")
				B.ReskinIcon(child.icon)

				child.HighlightBar:SetColorTexture(1, 1, 1, .25)
				child.HighlightBar:SetDrawLayer("BACKGROUND")
				child.SelectedBar:SetColorTexture(cr, cg, cb, .25)
				child.SelectedBar:SetDrawLayer("BACKGROUND")
				child.Check:SetAtlas("checkmark-minimal")

				child.styled = true
			end
		end
	end)

	B.ReskinIconSelector(GearManagerPopupFrame)

	-- TitlePane
	B.ReskinScroll(PaperDollFrame.TitleManagerPane.ScrollBar)

	hooksecurefunc(PaperDollFrame.TitleManagerPane.ScrollBox, "Update", function(self)
		for i = 1, self.ScrollTarget:GetNumChildren() do
			local child = select(i, self.ScrollTarget:GetChildren())
			if not child.styled then
				child:DisableDrawLayer("BACKGROUND")
				child.Check:SetAtlas("checkmark-minimal")

				child.styled = true
			end
		end
	end)

	-- Reputation Frame
	local oldAtlas = {
		["Options_ListExpand_Right"] = 1,
		["Options_ListExpand_Right_Expanded"] = 1,
	}
	local function updateCollapse(texture, atlas)
		if (not atlas) or oldAtlas[atlas] then
			if not texture.__owner then
				texture.__owner = texture:GetParent()
			end
			if texture.__owner:IsCollapsed() then
				texture:SetAtlas("Soulbinds_Collection_CategoryHeader_Expand")
			else
				texture:SetAtlas("Soulbinds_Collection_CategoryHeader_Collapse")
			end
		end
	end

	local function updateToggleCollapse(button)
		button:SetNormalTexture(0)
		button.__texture:DoCollapse(button:GetHeader():IsCollapsed())
	end

	local function updateReputationBars(self)
		for i = 1, self.ScrollTarget:GetNumChildren() do
			local child = select(i, self.ScrollTarget:GetChildren())
			if child and not child.styled then
				if child.Right then
					B.StripTextures(child)
					hooksecurefunc(child.Right, "SetAtlas", updateCollapse)
					hooksecurefunc(child.HighlightRight, "SetAtlas", updateCollapse)
					updateCollapse(child.Right)
					updateCollapse(child.HighlightRight)
					B.CreateBDFrame(child, .25):SetInside(nil, 2, 2)
				end
				local repbar = child.Content and child.Content.ReputationBar
				if repbar then
					B.ReskinStatusBar(repbar, true)
				end
				if child.ToggleCollapseButton then
					child.ToggleCollapseButton:GetPushedTexture():SetAlpha(0)
					B.ReskinCollapse(child.ToggleCollapseButton, true)
					updateToggleCollapse(child.ToggleCollapseButton)
					hooksecurefunc(child.ToggleCollapseButton, "RefreshIcon", updateToggleCollapse)
				end

				child.styled = true
			end
		end
	end
	hooksecurefunc(ReputationFrame.ScrollBox, "Update", updateReputationBars)

	B.ReskinScroll(ReputationFrame.ScrollBar)
	B.ReskinDropDown(ReputationFrame.filterDropdown)

	local detailFrame = ReputationFrame.ReputationDetailFrame
	B.StripTextures(detailFrame)
	B.SetBD(detailFrame)
	B.ReskinClose(detailFrame.CloseButton)
	B.ReskinCheck(detailFrame.AtWarCheckbox)
	B.ReskinCheck(detailFrame.MakeInactiveCheckbox)
	B.ReskinCheck(detailFrame.WatchFactionCheckbox)
	B.ReskinButton(detailFrame.ViewRenownButton)
	B.ReskinScroll(detailFrame.ScrollingDescriptionScrollBar)

	-- Token frame
	B.ReskinScroll(TokenFrame.ScrollBar) -- taint if touching thumb, needs review
	B.ReskinDropDown(TokenFrame.filterDropdown)
	if TokenFramePopup.CloseButton then -- blizz typo by parentKey "CloseButton" into "$parent.CloseButton"
		B.ReskinClose(TokenFramePopup.CloseButton)
	else
		B.ReskinClose((select(5, TokenFramePopup:GetChildren())))
	end

	B.ReskinButton(TokenFramePopup.CurrencyTransferToggleButton)
	B.ReskinCheck(TokenFramePopup.InactiveCheckbox)
	B.ReskinCheck(TokenFramePopup.BackpackCheckbox)

	NoTaintArrow(TokenFrame.CurrencyTransferLogToggleButton, "right") -- taint control, needs review
	B.ReskinFrame(CurrencyTransferLog)
	B.ReskinScroll(CurrencyTransferLog.ScrollBar)

	local function handleCurrencyIcon(button)
		local icon = button.CurrencyIcon
		if icon then
			B.ReskinIcon(icon)
		end
	end
	hooksecurefunc(CurrencyTransferLog.ScrollBox, "Update", function(self)
		self:ForEachFrame(handleCurrencyIcon)
	end)

	local transferMenu = CurrencyTransferMenu.Content or CurrencyTransferMenu -- isNewPatch
	if transferMenu then
		B.ReskinFrame(CurrencyTransferMenu)
		B.CreateBDFrame(transferMenu.SourceSelector, .25)
		transferMenu.SourceSelector.SourceLabel:SetWidth(56)
		B.ReskinDropDown(transferMenu.SourceSelector.Dropdown)
		B.ReskinIcon(transferMenu.SourceBalancePreview.BalanceInfo.CurrencyIcon)
		B.ReskinIcon(transferMenu.PlayerBalancePreview.BalanceInfo.CurrencyIcon)
		B.ReskinButton(transferMenu.ConfirmButton)
		B.ReskinButton(transferMenu.CancelButton)

		local amountSelector = transferMenu.AmountSelector
		if amountSelector then
			B.CreateBDFrame(amountSelector, .25)
			B.ReskinButton(amountSelector.MaxQuantityButton)
			B.ReskinInput(amountSelector.InputBox)
			B.UpdateSize(amountSelector.InputBox.__bg, 3, -3, -9, 9)
		end
	end

	hooksecurefunc(TokenFrame.ScrollBox, "Update", function(self)
		for i = 1, self.ScrollTarget:GetNumChildren() do
			local child = select(i, self.ScrollTarget:GetChildren())
			if child and not child.styled then
				if child.Right then
					B.StripTextures(child)
					hooksecurefunc(child.Right, "SetAtlas", updateCollapse)
					hooksecurefunc(child.HighlightRight, "SetAtlas", updateCollapse)
					updateCollapse(child.Right)
					updateCollapse(child.HighlightRight)
					B.CreateBDFrame(child, .25):SetInside(nil, 2, 2)
				end
				local icon = child.Content and child.Content.CurrencyIcon
				if icon then
					B.ReskinIcon(icon)
				end
				if child.ToggleCollapseButton then
					child.ToggleCollapseButton:GetPushedTexture():SetAlpha(0)
					B.ReskinCollapse(child.ToggleCollapseButton, true)
					updateToggleCollapse(child.ToggleCollapseButton)
					hooksecurefunc(child.ToggleCollapseButton, "RefreshIcon", updateToggleCollapse)
				end

				child.styled = true
			end
		end
	end)

	B.StripTextures(TokenFramePopup)
	B.SetBD(TokenFramePopup)

	-- Quick Join
	B.ReskinScroll(QuickJoinFrame.ScrollBar)
	B.ReskinButton(QuickJoinFrame.JoinQueueButton)

	B.SetBD(QuickJoinRoleSelectionFrame)
	B.ReskinButton(QuickJoinRoleSelectionFrame.AcceptButton)
	B.ReskinButton(QuickJoinRoleSelectionFrame.CancelButton)
	B.ReskinClose(QuickJoinRoleSelectionFrame.CloseButton)
	B.StripTextures(QuickJoinRoleSelectionFrame)

	B.ReskinRole(QuickJoinRoleSelectionFrame.RoleButtonTank, "TANK")
	B.ReskinRole(QuickJoinRoleSelectionFrame.RoleButtonHealer, "HEALER")
	B.ReskinRole(QuickJoinRoleSelectionFrame.RoleButtonDPS, "DPS")
end