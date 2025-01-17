local _, ns = ...
local B, C, L, DB = unpack(ns)

C.OnLoadThemes["Blizzard_ObliterumUI"] = function()
	local obliterum = ObliterumForgeFrame

	B.ReskinFrame(obliterum)
	B.ReskinButton(obliterum.ObliterateButton)
	B.ReskinIcon(obliterum.ItemSlot.Icon)
end