local _, ns = ...
local B, C, L, DB = unpack(ns)

C.OnLoadThemes["Blizzard_GenericTraitUI"] = function()
	B.ReskinFrame(GenericTraitFrame)
	B.ReplaceIconString(GenericTraitFrame.Currency.UnspentPointsCount)
	hooksecurefunc(GenericTraitFrame.Currency.UnspentPointsCount, "SetText", B.ReplaceIconString)
end