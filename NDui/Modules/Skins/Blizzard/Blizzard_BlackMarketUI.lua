local _, ns = ...
local B, C, L, DB = unpack(ns)

C.OnLoadThemes["Blizzard_BlackMarketUI"] = function()
	local cr, cg, cb = DB.r, DB.g, DB.b

	B.StripTextures(BlackMarketFrame)
	BlackMarketFrame.MoneyFrameBorder:SetAlpha(0)
	B.StripTextures(BlackMarketFrame.HotDeal)
	B.CreateBDFrame(BlackMarketFrame.HotDeal.Item)
	BlackMarketFrame.HotDeal.Item.IconTexture:SetTexCoord(unpack(DB.TexCoord))

	local headers = {"ColumnName", "ColumnLevel", "ColumnType", "ColumnDuration", "ColumnHighBidder", "ColumnCurrentBid"}
	for _, header in pairs(headers) do
		local header = BlackMarketFrame[header]
		B.StripTextures(header)
		local bg = B.CreateBDFrame(header, .25)
		bg:SetPoint("TOPLEFT", 2, 0)
		bg:SetPoint("BOTTOMRIGHT", -1, 0)
	end

	B.SetBD(BlackMarketFrame)
	B.CreateBDFrame(BlackMarketFrame.HotDeal, .25)
	B.ReskinButton(BlackMarketFrame.BidButton)
	B.ReskinClose(BlackMarketFrame.CloseButton)
	B.ReskinInput(BlackMarketBidPriceGold)
	B.ReskinScroll(BlackMarketFrame.ScrollBar)

	hooksecurefunc(BlackMarketFrame.ScrollBox, "Update", function(self)
		for i = 1, self.ScrollTarget:GetNumChildren() do
			local bu = select(i, self.ScrollTarget:GetChildren())

			bu.Item.IconTexture:SetTexCoord(unpack(DB.TexCoord))
			if not bu.reskinned then
				B.StripTextures(bu)

				bu.Item:SetNormalTexture(0)
				bu.Item:SetPushedTexture(0)
				bu.Item:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
				B.CreateBDFrame(bu.Item)
				bu.Item.IconBorder:SetAlpha(0)

				local bg = B.CreateBDFrame(bu, .25)
				bg:SetPoint("TOPLEFT", bu.Item, "TOPRIGHT", 3, C.mult)
				bg:SetPoint("BOTTOMRIGHT", 0, 4)

				bu:SetHighlightTexture(DB.bdTex)
				local hl = bu:GetHighlightTexture()
				hl:SetVertexColor(cr, cg, cb, .25)
				hl.SetAlpha = B.Dummy
				hl:ClearAllPoints()
				hl:SetAllPoints(bg)

				bu.Selection:ClearAllPoints()
				bu.Selection:SetAllPoints(bg)
				bu.Selection:SetTexture(DB.bdTex)
				bu.Selection:SetVertexColor(cr, cg, cb, .25)

				bu.reskinned = true
			end

			if bu:IsShown() and bu.itemLink then
				local quality = C_Item.GetItemQualityByID(bu.itemLink)
				local r, g, b = C_Item.GetItemQualityColor(quality)
				bu.Name:SetTextColor(r, g, b)
			end
		end
	end)

	hooksecurefunc("BlackMarketFrame_UpdateHotItem", function(self)
		local hotDeal = self.HotDeal
		if hotDeal:IsShown() and hotDeal.itemLink then
			local quality = C_Item.GetItemQualityByID(hotDeal.itemLink)
			local r, g, b = C_Item.GetItemQualityColor(quality)
			hotDeal.Name:SetTextColor(r, g, b)
		end
		hotDeal.Item.IconBorder:Hide()
	end)
end