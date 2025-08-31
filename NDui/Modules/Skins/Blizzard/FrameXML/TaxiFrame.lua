local _, ns = ...
local B, C, L, DB = unpack(ns)

C.OnLoginThemes["TaxiFrame"] = function()

	TaxiFrame:DisableDrawLayer("BORDER")
	TaxiFrame:DisableDrawLayer("OVERLAY")
	TaxiFrame.Bg:Hide()
	TaxiFrame.TitleBg:Hide()
	TaxiFrame.TopTileStreaks:Hide()

	B.CreateBG(TaxiFrame, 3, -23, -5, 3)
	B.ReskinClose(TaxiFrame.CloseButton, TaxiRouteMap)
end