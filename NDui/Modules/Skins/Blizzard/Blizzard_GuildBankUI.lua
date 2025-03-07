local _, ns = ...
local B, C, L, DB = unpack(ns)

C.OnLoadThemes["Blizzard_GuildBankUI"] = function()
	B.StripTextures(GuildBankFrame)
	B.ReskinFrame(GuildBankFrame)
	B.ReskinFrameTab(GuildBankFrame, 4)

	GuildBankFrame.Emblem:Hide()
	GuildBankFrame.MoneyFrameBG:Hide()
	B.ReskinButton(GuildBankFrame.WithdrawButton)
	B.ReskinButton(GuildBankFrame.DepositButton)
	B.ReskinScroll(GuildBankFrame.Log.ScrollBar)
	B.ReskinScroll(GuildBankInfoScrollFrame.ScrollBar)

	B.ReskinButton(GuildBankFrame.BuyInfo.PurchaseButton)
	B.ReskinButton(GuildBankFrame.Info.SaveButton)
	B.ReskinInput(GuildItemSearchBox)

	GuildBankFrame.WithdrawButton:SetPoint("RIGHT", GuildBankFrame.DepositButton, "LEFT", -2, 0)

	for i = 1, 7 do
		local column = GuildBankFrame.Columns[i]
		column:GetRegions():Hide()

		for j = 1, 14 do
			local button = column.Buttons[j]
			button:SetNormalTexture(0)
			button:SetPushedTexture(0)
			button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
			button.icon:SetTexCoord(unpack(DB.TexCoord))
			button.bg = B.CreateBDFrame(button, .25)
			button.searchOverlay:SetOutside()
			B.ReskinBorder(button.IconBorder)
		end
	end

	for i = 1, 8 do
		local tab = _G["GuildBankTab"..i]
		local button = tab.Button
		local icon = button.IconTexture

		B.StripTextures(tab)
		button:SetNormalTexture(0)
		button:SetPushedTexture(0)
		button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		button:SetCheckedTexture(DB.pushedTex)
		B.CreateBDFrame(button)
		icon:SetTexCoord(unpack(DB.TexCoord))

		local a1, p, a2, x, y = button:GetPoint()
		button:SetPoint(a1, p, a2, x + C.mult, y)
	end

	B.ReskinIconSelector(GuildBankPopupFrame)
end