local _, ns = ...
local B, C, L, DB = unpack(ns)

--/run LoadAddOn"Blizzard_ChromieTimeUI" ChromieTimeFrame:Show()
C.OnLoadThemes["Blizzard_ChromieTimeUI"] = function()
	local frame = ChromieTimeFrame

	B.StripTextures(frame)
	B.SetBD(frame)
	B.ReskinClose(frame.CloseButton)
	B.ReskinButton(frame.SelectButton)

	local header = frame.Title
	header:DisableDrawLayer("BACKGROUND")
	header.Text:SetFontObject(SystemFont_Huge1)
	B.CreateBDFrame(header, .25)

	frame.CurrentlySelectedExpansionInfoFrame.Name:SetTextColor(1, 1, 0)
	frame.CurrentlySelectedExpansionInfoFrame.Description:SetTextColor(1, 1, 1)
end