local _, ns = ...
local B, C, L, DB = unpack(ns)

local function hideCategoryButton(button)
	button.NormalTexture:Hide()
	button.SelectedTexture:SetColorTexture(0, 1, 1, .25)
	button.HighlightTexture:SetColorTexture(1, 1, 1, .25)
end

local function reskinListIcon(frame)
	if not frame.tableBuilder then return end

	for i = 1, 22 do
		local row = frame.tableBuilder.rows[i]
		if row then
			local cell = row.cells and row.cells[1]
			if cell and cell.Icon then
				if not cell.styled then
					cell.Icon.bg = B.ReskinIcon(cell.Icon)
					if cell.IconBorder then cell.IconBorder:Hide() end
					cell.styled = true
				end
				cell.Icon.bg:SetShown(cell.Icon:IsShown())
			end
		end
	end
end

local function reskinListHeader(headerContainer)
	local maxHeaders = headerContainer:GetNumChildren()
	for i = 1, maxHeaders do
		local header = select(i, headerContainer:GetChildren())
		if header and not header.styled then
			header:DisableDrawLayer("BACKGROUND")
			header.bg = B.CreateBDFrame(header)
			local hl = header:GetHighlightTexture()
			hl:SetColorTexture(1, 1, 1, .25)
			hl:SetAllPoints(header.bg)

			header.styled = true
		end

		if header.bg then
			header.bg:SetPoint("BOTTOMRIGHT", i < maxHeaders and -5 or 0, -2)
		end
	end
end

local function reskinBrowseOrders(frame)
	local headerContainer = frame.RecipeList and frame.RecipeList.HeaderContainer
	if headerContainer then
		reskinListHeader(headerContainer)
	end
end

local function reskinMoneyInput(box)
	B.ReskinInput(box)
	box.__bg:SetPoint("TOPLEFT", 0, -3)
	box.__bg:SetPoint("BOTTOMRIGHT", 0, 3)
end

local function reskinContainer(container)
	local button = container.Button
	button.bg = B.ReskinIcon(button.Icon)
	B.ReskinBorder(button.IconBorder)
	button:SetNormalTexture(0)
	button:SetPushedTexture(0)
	button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)

	local box = container.EditBox
	box:DisableDrawLayer("BACKGROUND")
	B.ReskinInput(box)
	B.ReskinArrow(box.DecrementButton, "left")
	B.ReskinArrow(box.IncrementButton, "right")
end

local function reskinOrderIcon(child)
	if child.styled then return end

	local button = child:GetChildren()
	if button and button.IconBorder then
		button.bg = B.ReskinIcon(button.Icon)
		B.ReskinBorder(button.IconBorder)
	end
	child.styled = true
end

C.OnLoadThemes["Blizzard_ProfessionsCustomerOrders"] = function()
	local frame = _G.ProfessionsCustomerOrdersFrame

	B.ReskinFrame(frame)
	for i = 1, 2 do
		B.ReskinTab(frame.Tabs[i])
	end
	B.StripTextures(frame.MoneyFrameBorder)
	B.CreateBDFrame(frame.MoneyFrameBorder, .25)
	B.StripTextures(frame.MoneyFrameInset)

	local searchBar = frame.BrowseOrders.SearchBar
	B.ReskinButton(searchBar.FavoritesSearchButton)
	searchBar.FavoritesSearchButton:SetSize(22, 22)
	B.ReskinInput(searchBar.SearchBox)
	B.ReskinButton(searchBar.SearchButton)
	B.ReskinFilterButton(searchBar.FilterDropdown)

	B.StripTextures(frame.BrowseOrders.CategoryList)
	B.ReskinScroll(frame.BrowseOrders.CategoryList.ScrollBar)

	hooksecurefunc(frame.BrowseOrders.CategoryList.ScrollBox, "Update", function(self)
		for i = 1, self.ScrollTarget:GetNumChildren() do
			local child = select(i, self.ScrollTarget:GetChildren())
			if child.Text and not child.styled then
				hideCategoryButton(child)
				hooksecurefunc(child, "Init", hideCategoryButton)

				child.styled = true
			end
		end
	end)

	local recipeList = frame.BrowseOrders.RecipeList
	B.StripTextures(recipeList)
	B.CreateBDFrame(recipeList.ScrollBox, .25):SetInside()
	B.ReskinScroll(recipeList.ScrollBar)

	hooksecurefunc(frame.BrowseOrders, "SetupTable", reskinBrowseOrders)
	hooksecurefunc(frame.BrowseOrders, "StartSearch", reskinListIcon)

	-- Form
	B.ReskinButton(frame.Form.BackButton)
	B.ReskinCheck(frame.Form.AllocateBestQualityCheckbox)
	B.ReskinCheck(frame.Form.TrackRecipeCheckbox.Checkbox)

	frame.Form.RecipeHeader:Hide()
	B.CreateBDFrame(frame.Form.RecipeHeader, .25)
	B.StripTextures(frame.Form.LeftPanelBackground)
	B.StripTextures(frame.Form.RightPanelBackground)

	local itemButton = frame.Form.OutputIcon
	itemButton.CircleMask:Hide()
	itemButton.bg = B.ReskinIcon(itemButton.Icon)
	B.ReskinBorder(itemButton.IconBorder, true, true)

	local hl = itemButton:GetHighlightTexture()
	hl:SetColorTexture(1, 1, 1, .25)
	hl:SetInside(itemButton.bg)

	B.ReskinInput(frame.Form.OrderRecipientTarget)
	frame.Form.OrderRecipientTarget.__bg:SetPoint("TOPLEFT", -8, -2)
	frame.Form.OrderRecipientTarget.__bg:SetPoint("BOTTOMRIGHT", 0, 2)
	B.ReskinDropDown(frame.Form.OrderRecipientDropdown)
	B.ReskinDropDown(frame.Form.MinimumQuality.Dropdown)

	local paymentContainer = frame.Form.PaymentContainer
	B.StripTextures(paymentContainer.NoteEditBox)
	local bg = B.CreateBDFrame(paymentContainer.NoteEditBox, .25)
	bg:SetPoint("TOPLEFT", 15, 5)
	bg:SetPoint("BOTTOMRIGHT", -18, 0)

	reskinMoneyInput(paymentContainer.TipMoneyInputFrame.GoldBox)
	reskinMoneyInput(paymentContainer.TipMoneyInputFrame.SilverBox)
	B.ReskinDropDown(paymentContainer.DurationDropdown)
	B.ReskinButton(paymentContainer.ListOrderButton)
	B.ReskinButton(paymentContainer.CancelOrderButton)

	local viewButton = paymentContainer.ViewListingsButton
	viewButton:SetAlpha(0)
	local buttonFrame = CreateFrame("Frame", nil, paymentContainer)
	buttonFrame:SetInside(viewButton)
	local tex = buttonFrame:CreateTexture(nil, "ARTWORK")
	tex:SetAllPoints()
	tex:SetTexture("Interface\\CURSOR\\Crosshair\\Repair")

	local current = frame.Form.CurrentListings
	B.StripTextures(current)
	B.SetBD(current)
	B.ReskinButton(current.CloseButton)
	B.ReskinScroll(current.OrderList.ScrollBar)
	reskinListHeader(current.OrderList.HeaderContainer)
	B.StripTextures(current.OrderList)
	current:ClearAllPoints()
	current:SetPoint("LEFT", frame, "RIGHT", 10, 0)

	local function resetButton(button)
		button:SetNormalTexture(0)
		button:SetPushedTexture(0)
		local hl = button:GetHighlightTexture()
		hl:SetColorTexture(1, 1, 1, .25)
		hl:SetInside(button.bg)
	end

	hooksecurefunc(frame.Form, "UpdateReagentSlots", function(self)
		for slot in self.reagentSlotPool:EnumerateActive() do
			local button = slot.Button
			if button and not button.styled then
				button.bg = B.ReskinIcon(button.Icon)
				B.ReskinBorder(button.IconBorder, true, true)
				if button.SlotBackground then
					button.SlotBackground:Hide()
				end
				B.ReskinCheck(slot.Checkbox)
				button.HighlightTexture:SetColorTexture(1, 1, 0, .5)
				button.HighlightTexture:SetInside(button.bg)
				resetButton(button)
				hooksecurefunc(button, "Update", resetButton)

				button.styled = true
			end
		end
	end)

	local qualityDialog = frame.Form.QualityDialog
	B.StripTextures(qualityDialog)
	B.SetBD(qualityDialog)
	B.ReskinClose(qualityDialog.ClosePanelButton)
	B.ReskinButton(qualityDialog.AcceptButton)
	B.ReskinButton(qualityDialog.CancelButton)
	for i = 1, 3 do
		reskinContainer(qualityDialog["Container"..i])
	end

	B.ReskinButton(frame.Form.OrderRecipientDisplay.SocialDropdown)

	-- Orders
	B.ReskinButton(frame.MyOrdersPage.RefreshButton)
	frame.MyOrdersPage.RefreshButton.__bg:SetInside(nil, 3, 3)
	B.StripTextures(frame.MyOrdersPage.OrderList)
	B.CreateBDFrame(frame.MyOrdersPage.OrderList, .25)
	reskinListHeader(frame.MyOrdersPage.OrderList.HeaderContainer)
	B.ReskinScroll(frame.MyOrdersPage.OrderList.ScrollBar)

	hooksecurefunc(frame.MyOrdersPage.OrderList.ScrollBox, "Update", function(self)
		self:ForEachFrame(reskinOrderIcon)
	end)

	-- Item flyout
	if OpenProfessionsItemFlyout then
		hooksecurefunc("OpenProfessionsItemFlyout", B.ReskinProfessionsFlyout)
	end
end