local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_ScrappingMachineUI"] = function()
	B.ReskinFrame(ScrappingMachineFrame)
	B.ReskinButton(ScrappingMachineFrame.ScrapButton)

	local ItemSlots = ScrappingMachineFrame.ItemSlots
	B.StripTextures(ItemSlots)

	hooksecurefunc(ScrappingMachineFrame, "UpdateScrapButtonState", function(self)
		for button in self.ItemSlots.scrapButtons:EnumerateActive() do
			if not button.bg then
				B.StripTextures(button)

				button.bg = B.ReskinIcon(button.Icon)
				B.ReskinBorder(button.IconBorder)
				B.ReskinHLTex(button, button.bg)
			end
		end
	end)
end