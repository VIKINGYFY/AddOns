local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_MajorFactions"] = function()
	local frame = _G.MajorFactionRenownFrame

	B.StripTextures(frame, 0)
	B.SetBD(frame)
	B.ReskinClose(frame.CloseButton)
	B.ReskinButton(frame.LevelSkipButton)
end