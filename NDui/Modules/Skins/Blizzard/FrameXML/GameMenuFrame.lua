local _, ns = ...
local B, C, L, DB = unpack(ns)

C.OnLoginThemes["GameMenuFrame"] = function()

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

	

	hooksecurefunc(GameMenuFrame, "InitButtons", function(self)
		if not self.buttonPool then return end

		for button in self.buttonPool:EnumerateActive() do
			if not button.styled then
				button:DisableDrawLayer("BACKGROUND")
				button.bg = B.CreateBDFrame(button, 0, true, 1)
				B.ReskinHLTex(button, button.bg, true)

				button.styled = true
			end
		end
	end)
end