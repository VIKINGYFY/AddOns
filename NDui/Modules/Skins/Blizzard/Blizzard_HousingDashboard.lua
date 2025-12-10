local _, ns = ...
local B, C, L, DB = unpack(ns)

C.OnLoadThemes["Blizzard_HousingDashboard"] = function()
	B.ReskinFrame(HousingDashboardFrame)
--[[
	for _, tab in ipairs(HousingDashboardFrame.TabButtons) do
		B.ReskinTabButton(tab)
	end
]]
	local houseInfoContent = HousingDashboardFrame.HouseInfoContent
	B.StripTextures(houseInfoContent)

	B.ReskinButton(houseInfoContent.HouseFinderButton)
	B.ReskinDropDown(houseInfoContent.HouseDropdown)
	B.ReskinCheck(houseInfoContent.ContentFrame.HouseUpgradeFrame.WatchFavorButton)

	local catalogContent = HousingDashboardFrame.CatalogContent
	B.StripTextures(catalogContent)
	B.StripTextures(catalogContent.Categories)
	B.StripTextures(catalogContent.PreviewFrame)
	B.StripTextures(catalogContent.OptionsContainer)

	B.ReskinEditBox(catalogContent.SearchBox)
	B.ReskinFilterButton(catalogContent.Filters.FilterDropdown)
	B.ReskinScroll(catalogContent.OptionsContainer.ScrollBar)
end

C.OnLoadThemes["Blizzard_HousingModelPreview"] = function()
	B.ReskinFrame(HousingModelPreviewFrame)
end