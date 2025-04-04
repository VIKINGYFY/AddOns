local _, ns = ...
local B, C, L, DB = unpack(ns)

local function updateSelectedTexture(texture, shown)
	local button = texture.__owner
	if shown then
		button.bg:SetBackdropBorderColor(1, 1, 0)
	else
		B.SetBorderColor(button.bg)
	end
end

local function replaceCurrencyDisplay(self)
	if not self.currencyID then return end
	local text = GetCurrencyString(self.currencyID, self.amount, self.colorCode, self.abbreviate)
	local newText, count = string.gsub(text, "|T([^:]-):[%d+:]+|t", "|T%1:14:14:0:0:64:64:5:59:5:59|t")
	if count > 0 then self:SetText(newText) end
end

local function SetCurrenciesHook(self)
	if self.currencyFramePool then
		for frame in self.currencyFramePool:EnumerateActive() do
			if not frame.hooked then
				replaceCurrencyDisplay(frame)
				hooksecurefunc(frame, "SetCurrencyFromID", replaceCurrencyDisplay)

				frame.hooked = true
			end
		end
	end
end
B.SetCurrenciesHook = SetCurrenciesHook

C.OnLoadThemes["Blizzard_RuneforgeUI"] = function()
	local frame = RuneforgeFrame
	B.ReskinClose(frame.CloseButton, nil, -70, -70)

	local createFrame = frame.CreateFrame
	B.ReskinButton(createFrame.CraftItemButton)

	hooksecurefunc(frame.CurrencyDisplay, "SetCurrencies", SetCurrenciesHook)
	hooksecurefunc(createFrame.Cost.Currencies, "SetCurrencies", SetCurrenciesHook)

	local powerFrame = frame.CraftingFrame.PowerFrame
	B.StripTextures(powerFrame)
	B.SetBD(powerFrame)

	hooksecurefunc(powerFrame.PowerList, "RefreshListDisplay", function(self)
		if not self.elements then return end

		for i = 1, self:GetNumElementFrames() do
			local button = self.elements[i]
			if button and not button.bg then
				button.Border:SetAlpha(0)
				button.CircleMask:Hide()
				button.bg = B.ReskinIcon(button.Icon)
				button.SelectedTexture:SetTexture("")
				button.SelectedTexture.__owner = button
				hooksecurefunc(button.SelectedTexture, "SetShown", updateSelectedTexture)
			end
		end
	end)

	local pageControl = powerFrame.PageControl
	B.ReskinArrow(pageControl.BackwardButton, "left")
	B.ReskinArrow(pageControl.ForwardButton, "right")

	B.ReskinTooltip(frame.ResultTooltip)
end