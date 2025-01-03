local _, ns = ...
local B, C, L, DB = unpack(ns)

table.insert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	local r, g, b = DB.r, DB.g, DB.b

	for i = 1, 6 do
		select(i, GhostFrame:GetRegions()):Hide()
	end
	B.ReskinIcon(GhostFrameContentsFrameIcon)

	local bg = B.SetBD(GhostFrame)
	GhostFrame:SetHighlightTexture(DB.bdTex)
	GhostFrame:GetHighlightTexture():SetVertexColor(r, g, b, .25)
end)