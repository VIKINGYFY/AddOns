local _, ns = ...
local B, C, L, DB = unpack(ns)

C.OnLoginThemes["GhostFrame"] = function()

	local cr, cg, cb = DB.r, DB.g, DB.b

	for i = 1, 6 do
		select(i, GhostFrame:GetRegions()):Hide()
	end
	B.ReskinIcon(GhostFrameContentsFrameIcon)

	local bg = B.SetBD(GhostFrame)
	GhostFrame:SetHighlightTexture(DB.bdTex)
	GhostFrame:GetHighlightTexture():SetVertexColor(cr, cg, cb, .25)
end