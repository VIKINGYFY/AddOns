local _, ns = ...
local B, C, L, DB = unpack(ns)

C.OnLoginThemes["GhostFrame"] = function()

	

	for i = 1, 6 do
		select(i, GhostFrame:GetRegions()):Hide()
	end
	B.ReskinIcon(GhostFrameContentsFrameIcon)

	local bg = B.SetBD(GhostFrame)
	GhostFrame:SetHighlightTexture(DB.bdTex)
	GhostFrame:GetHighlightTexture():SetVertexColor(DB.r, DB.g, DB.b, .25)
end