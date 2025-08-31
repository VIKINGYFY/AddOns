local _, ns = ...
local B, C, L, DB = unpack(ns)

C.OnLoadThemes["Blizzard_AnimaDiversionUI"] = function()
	local frame = AnimaDiversionFrame

	B.StripTextures(frame)
	B.CreateBG(frame)
	B.ReskinClose(frame.CloseButton)
	frame.AnimaDiversionCurrencyFrame.Background:SetAlpha(0)

	local currencyFrame = frame.AnimaDiversionCurrencyFrame.CurrencyFrame
	B.ReplaceIconString(currencyFrame.Quantity)
	hooksecurefunc(currencyFrame.Quantity, "SetText", B.ReplaceIconString)

	B.ReskinButton(frame.ReinforceInfoFrame.AnimaNodeReinforceButton)
end