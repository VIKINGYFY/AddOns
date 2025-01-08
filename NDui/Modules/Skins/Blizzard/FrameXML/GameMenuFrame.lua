local _, ns = ...
local B, C, L, DB = unpack(ns)

table.insert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	B.StripTextures(GameMenuFrame.Header)
	GameMenuFrame.Header:ClearAllPoints()
	GameMenuFrame.Header:SetPoint("TOP", GameMenuFrame, 0, 7)
	B.SetBD(GameMenuFrame)
	GameMenuFrame.Border:Hide()
	GameMenuFrame.Header.Text:SetFontObject(Game16Font)
	local line = GameMenuFrame.Header:CreateTexture(nil, "ARTWORK")
	line:SetSize(156, C.mult)
	line:SetPoint("BOTTOM", 0, 5)
	line:SetColorTexture(1, 1, 1, .25)

	local cr, cg, cb = DB.r, DB.g, DB.b

	hooksecurefunc(GameMenuFrame, "InitButtons", function(self)
		if not self.buttonPool then return end

		for button in self.buttonPool:EnumerateActive() do
			if not button.styled then
				button:DisableDrawLayer("BACKGROUND")
				button.bg = B.CreateBDFrame(button, 0, true, C.mult)
				B.ReskinHLTex(button, button.bg, true)

				button.styled = true
			end
		end
	end)
end)