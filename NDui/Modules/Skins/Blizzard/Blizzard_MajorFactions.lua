local _, ns = ...
local B, C, L, DB = unpack(ns)

C.OnLoadThemes["Blizzard_MajorFactions"] = function()
	local frame = _G.MajorFactionRenownFrame

	B.StripTextures(frame, 0)
	B.CreateBG(frame)
	B.ReskinClose(frame.CloseButton)
	B.ReskinButton(frame.LevelSkipButton)
end