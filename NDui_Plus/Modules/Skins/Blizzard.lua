local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

function S:QuestMapFrame()
	for _, tab in ipairs(_G.QuestMapFrame.TabButtons) do
		if not tab.bg then
			B.StripTextures(tab, 2)

			tab.bg = B.CreateBG(tab, 1, -4, -5, 4)
			B.ReskinHLTex(tab.SelectedTexture, tab.bg, true)
		end
	end
end

S:RegisterSkin("QuestMapFrame")