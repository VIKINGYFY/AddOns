local _, ns = ...
local B, C, L, DB = unpack(ns)

local function Reskin_ItemButton(self)
	local item = _G[self]
	B.StripTextures(item)

	local button = _G[self.."ItemButton"]
	B.StripTextures(button)

	button.bg = B.ReskinIcon(button.icon)
	B.ReskinBorder(button.IconBorder)
	B.ReskinHLTex(button, button.bg)
	B.ReskinCPTex(button, button.bg)
end

C.OnLoginThemes["TradeFrame"] = function()
	B.ReskinFrame(TradeFrame)
	B.ReskinButton(TradeFrameTradeButton)
	B.ReskinButton(TradeFrameCancelButton)

	if not TradePlayerInputMoneyFrame:IsForbidden() then
		B.ReskinInput(TradePlayerInputMoneyFrameGold)
		B.ReskinInput(TradePlayerInputMoneyFrameSilver)
		B.ReskinInput(TradePlayerInputMoneyFrameCopper)

		B.UpdatePoint(TradePlayerInputMoneyFrameSilver, "LEFT", TradePlayerInputMoneyFrameGold, "RIGHT", 1, 0)
		B.UpdatePoint(TradePlayerInputMoneyFrameCopper, "LEFT", TradePlayerInputMoneyFrameSilver, "RIGHT", 1, 0)
	end

	local texts = {
		TradeFramePlayerNameText,
		TradeFrameRecipientNameText,
	}
	for index, text in pairs(texts) do
		text:SetWidth(150)
		text:SetJustifyH("CENTER")
		if index == 1 then
			B.UpdatePoint(text, "TOPRIGHT", TradeFrame, "TOP", -5, -10)
		else
			B.UpdatePoint(text, "TOPLEFT", TradeFrame, "TOP", 5, -10)
		end
	end

	local insets = {
		TradePlayerEnchantInset,
		TradePlayerInputMoneyInset,
		TradePlayerItemsInset,
		TradeRecipientEnchantInset,
		TradeRecipientItemsInset,
		TradeRecipientMoneyInset,
		TradeRecipientMoneyBg,
	}
	for _, inset in pairs(insets) do
		inset:Hide()
	end

	local highlights = {
		TradeHighlightPlayer,
		TradeHighlightPlayerEnchant,
		TradeHighlightRecipient,
		TradeHighlightRecipientEnchant,
	}
	for _, highlight in pairs(highlights) do
		B.StripTextures(highlight)
		highlight:SetFrameStrata("HIGH")

		local bg = B.CreateBDFrame(highlight, .25)
		bg:SetBackdropColor(0, 1, 0, .25)
		bg:SetBackdropBorderColor(0, 1, 0, 1)
	end

	for i = 1, MAX_TRADE_ITEMS do
		Reskin_ItemButton("TradePlayerItem"..i)
		Reskin_ItemButton("TradeRecipientItem"..i)
	end
end
