local _, ns = ...
local B, C, L, DB = unpack(ns)

C.OnLoadThemes["Blizzard_TorghastLevelPicker"] = function()
	local frame = TorghastLevelPickerFrame

	B.ReskinClose(frame.CloseButton, frame, -60, -60)
	B.ReskinButton(frame.OpenPortalButton)
	B.ReskinArrow(frame.Pager.PreviousPage, "left")
	B.ReskinArrow(frame.Pager.NextPage, "right")
end