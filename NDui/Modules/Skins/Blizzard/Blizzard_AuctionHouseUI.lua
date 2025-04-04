local _, ns = ...
local B, C, L, DB = unpack(ns)

local function reskinAuctionButton(button)
	B.ReskinButton(button)
	button:SetSize(22, 22)
end

local function reskinSellPanel(frame)
	B.StripTextures(frame)

	local itemDisplay = frame.ItemDisplay
	B.StripTextures(itemDisplay)
	B.CreateBDFrame(itemDisplay, .25)

	local itemButton = itemDisplay.ItemButton
	if itemButton.IconMask then itemButton.IconMask:Hide() end
	itemButton.EmptyBackground:Hide()
	itemButton:SetPushedTexture(0)
	itemButton.Highlight:SetColorTexture(1, 1, 1, .25)
	itemButton.Highlight:SetAllPoints(itemButton.Icon)
	itemButton.bg = B.ReskinIcon(itemButton.Icon)
	B.ReskinBorder(itemButton.IconBorder)

	B.ReskinInput(frame.QuantityInput.InputBox)
	B.ReskinButton(frame.QuantityInput.MaxButton)
	B.ReskinInput(frame.PriceInput.MoneyInputFrame.GoldBox)
	B.ReskinInput(frame.PriceInput.MoneyInputFrame.SilverBox)
	if frame.SecondaryPriceInput then
		B.ReskinInput(frame.SecondaryPriceInput.MoneyInputFrame.GoldBox)
		B.ReskinInput(frame.SecondaryPriceInput.MoneyInputFrame.SilverBox)
	end
	B.ReskinDropDown(frame.Duration.Dropdown)
	B.ReskinButton(frame.PostButton)
	if frame.BuyoutModeCheckButton then
		B.ReskinCheck(frame.BuyoutModeCheckButton)
		frame.BuyoutModeCheckButton:SetSize(28, 28)
	end
end

local function reskinListIcon(frame)
	if not frame.tableBuilder then return end

	for i = 1, 22 do
		local row = frame.tableBuilder.rows[i]
		if row then
			for j = 1, 4 do
				local cell = row.cells and row.cells[j]
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
end

local function reskinSummaryButtons(self)
	for i = 1, self.ScrollTarget:GetNumChildren() do
		local child = select(i, self.ScrollTarget:GetChildren())
		if child and child.Icon then
			if not child.styled then
				child.Icon.bg = B.ReskinIcon(child.Icon)
				if child.IconBorder then child.IconBorder:SetAlpha(0) end
				child.styled = true
			end
			child.Icon.bg:SetShown(child.Icon:IsShown())
		end
	end
end

local function reskinListHeader(frame)
	local maxHeaders = frame.HeaderContainer:GetNumChildren()
	for i = 1, maxHeaders do
		local header = select(i, frame.HeaderContainer:GetChildren())
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

	reskinListIcon(frame)
end

local function reskinSellList(frame, hasHeader)
	B.StripTextures(frame)
	if frame.RefreshFrame then
		reskinAuctionButton(frame.RefreshFrame.RefreshButton)
	end
	B.ReskinScroll(frame.ScrollBar)
	if hasHeader then
		B.CreateBDFrame(frame.ScrollBox, .25)
		hooksecurefunc(frame, "RefreshScrollFrame", reskinListHeader)
	else
		hooksecurefunc(frame.ScrollBox, "Update", reskinSummaryButtons)
	end
end

local function reskinItemDisplay(itemDisplay, needInit)
	B.StripTextures(itemDisplay)
	local bg = B.CreateBDFrame(itemDisplay, .25)
	bg:SetPoint("TOPLEFT", 3, -3)
	bg:SetPoint("BOTTOMRIGHT", -3, 0)
	local itemButton = itemDisplay.ItemButton
	if itemButton.CircleMask then
		itemButton.CircleMask:Hide()
		itemButton.useCircularIconBorder = true
	end
	itemButton.bg = B.ReskinIcon(itemButton.Icon)
	B.ReskinBorder(itemButton.IconBorder, needInit)

	local hl = itemButton:GetHighlightTexture()
	hl:SetColorTexture(1, 1, 1, .25)
	hl:SetInside(itemButton.bg)
end

local function reskinItemList(frame, hasHeader)
	B.StripTextures(frame)
	B.CreateBDFrame(frame.ScrollBox, .25)
	B.ReskinScroll(frame.ScrollBar)
	if frame.RefreshFrame then
		reskinAuctionButton(frame.RefreshFrame.RefreshButton)
	end
	if hasHeader then
		hooksecurefunc(frame, "RefreshScrollFrame", reskinListHeader)
	end
end

C.OnLoadThemes["Blizzard_AuctionHouseUI"] = function()
	B.ReskinFrame(AuctionHouseFrame)
	B.StripTextures(AuctionHouseFrame.MoneyFrameBorder)
	B.CreateBDFrame(AuctionHouseFrame.MoneyFrameBorder, .25)
	B.StripTextures(AuctionHouseFrame.MoneyFrameInset)
	B.ReskinTab(AuctionHouseFrameBuyTab)
	AuctionHouseFrameBuyTab:SetPoint("BOTTOMLEFT", 20, -30)
	B.ReskinTab(AuctionHouseFrameSellTab)
	B.ReskinTab(AuctionHouseFrameAuctionsTab)

	local searchBar = AuctionHouseFrame.SearchBar
	reskinAuctionButton(searchBar.FavoritesSearchButton)
	B.ReskinInput(searchBar.SearchBox)
	B.ReskinButton(searchBar.SearchButton)

	local filterButton = searchBar.FilterButton
	B.ReskinFilterButton(filterButton)
	B.ReskinFilterReset(filterButton.ClearFiltersButton)

	B.StripTextures(AuctionHouseFrame.CategoriesList)
	B.ReskinScroll(AuctionHouseFrame.CategoriesList.ScrollBar)
	reskinItemList(AuctionHouseFrame.BrowseResultsFrame.ItemList, true)

	hooksecurefunc("AuctionHouseFilterButton_SetUp", function(button)
		button.NormalTexture:SetAlpha(0)
		button.SelectedTexture:SetColorTexture(0, 1, 1, .25)
		button.HighlightTexture:SetColorTexture(1, 1, 1, .25)
	end)

	local itemBuyFrame = AuctionHouseFrame.ItemBuyFrame
	B.ReskinButton(itemBuyFrame.BackButton)
	B.ReskinButton(itemBuyFrame.BidFrame.BidButton)
	B.ReskinButton(itemBuyFrame.BuyoutFrame.BuyoutButton)
	reskinItemDisplay(itemBuyFrame.ItemDisplay)
	reskinItemList(itemBuyFrame.ItemList, true)

	local commBuyFrame = AuctionHouseFrame.CommoditiesBuyFrame
	B.ReskinButton(commBuyFrame.BackButton)
	local buyDisplay = commBuyFrame.BuyDisplay
	B.StripTextures(buyDisplay)
	B.ReskinInput(buyDisplay.QuantityInput.InputBox)
	B.ReskinButton(buyDisplay.BuyButton)
	reskinItemDisplay(buyDisplay.ItemDisplay)
	reskinItemList(commBuyFrame.ItemList)

	local wowTokenResults = AuctionHouseFrame.WoWTokenResults
	B.StripTextures(wowTokenResults)
	B.ReskinButton(wowTokenResults.Buyout)
	reskinItemDisplay(wowTokenResults.TokenDisplay, true)
	B.ReskinScroll(wowTokenResults.DummyScrollBar)

	local gameTimeTutorial = wowTokenResults.GameTimeTutorial
	B.ReskinFrame(gameTimeTutorial)
	B.ReskinButton(gameTimeTutorial.RightDisplay.StoreButton)
	gameTimeTutorial.LeftDisplay.Label:SetTextColor(1, 1, 1)
	gameTimeTutorial.LeftDisplay.Tutorial1:SetTextColor(1, 1, 0)
	gameTimeTutorial.RightDisplay.Label:SetTextColor(1, 1, 1)
	gameTimeTutorial.RightDisplay.Tutorial1:SetTextColor(1, 1, 0)

	local woWTokenSellFrame = AuctionHouseFrame.WoWTokenSellFrame
	B.StripTextures(woWTokenSellFrame)
	B.ReskinButton(woWTokenSellFrame.PostButton)
	B.StripTextures(woWTokenSellFrame.DummyItemList)
	B.CreateBDFrame(woWTokenSellFrame.DummyItemList, .25)
	B.ReskinScroll(woWTokenSellFrame.DummyItemList.DummyScrollBar)
	reskinAuctionButton(woWTokenSellFrame.DummyRefreshButton)
	reskinItemDisplay(woWTokenSellFrame.ItemDisplay)

	reskinSellPanel(AuctionHouseFrame.ItemSellFrame)
	reskinSellPanel(AuctionHouseFrame.CommoditiesSellFrame)
	reskinSellList(AuctionHouseFrame.CommoditiesSellList, true)
	reskinSellList(AuctionHouseFrame.ItemSellList, true)
	reskinSellList(AuctionHouseFrameAuctionsFrame.SummaryList)
	reskinSellList(AuctionHouseFrameAuctionsFrame.AllAuctionsList, true)
	reskinSellList(AuctionHouseFrameAuctionsFrame.BidsList, true)
	reskinSellList(AuctionHouseFrameAuctionsFrame.CommoditiesList, true)
	reskinSellList(AuctionHouseFrameAuctionsFrame.ItemList, true)
	reskinItemDisplay(AuctionHouseFrameAuctionsFrame.ItemDisplay)

	B.ReskinTab(AuctionHouseFrameAuctionsFrameAuctionsTab)
	B.ReskinTab(AuctionHouseFrameAuctionsFrameBidsTab)
	B.ReskinButton(AuctionHouseFrameAuctionsFrame.CancelAuctionButton)
	B.ReskinButton(AuctionHouseFrameAuctionsFrame.BidFrame.BidButton)
	B.ReskinButton(AuctionHouseFrameAuctionsFrame.BuyoutFrame.BuyoutButton)

	local buyDialog = AuctionHouseFrame.BuyDialog
	B.StripTextures(buyDialog)
	B.SetBD(buyDialog)
	B.ReskinButton(buyDialog.OkayButton)
	B.ReskinButton(buyDialog.BuyNowButton)
	B.ReskinButton(buyDialog.CancelButton)

	local multisellFrame = AuctionHouseMultisellProgressFrame
	B.StripTextures(multisellFrame)
	B.SetBD(multisellFrame)
	local progressBar = multisellFrame.ProgressBar
	B.ReskinStatusBar(progressBar, false, true)
	B.ReskinIcon(progressBar.Icon)
	local close = multisellFrame.CancelButton
	B.ReskinClose(close)
	close:ClearAllPoints()
	close:SetPoint("LEFT", progressBar, "RIGHT", 3, 0)
end