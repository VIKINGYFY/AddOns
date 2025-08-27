local _, ns = ...
local B, C, L, DB = unpack(ns)

C.OnLoginThemes["AddonList"] = function()

	local function forceSaturation(self, _, force)
		if force then return end
		self:SetVertexColor(DB.r, DB.g, DB.b)
		self:SetDesaturated(true, true)
	end

	B.ReskinFrame(AddonList)
	B.ReskinDropDown(AddonList.Dropdown)
	B.ReskinScroll(AddonList.ScrollBar)

	B.ReskinButton(AddonList.EnableAllButton)
	B.ReskinButton(AddonList.DisableAllButton)
	B.ReskinButton(AddonList.CancelButton)
	B.ReskinButton(AddonList.OkayButton)
	B.ReskinCheck(AddonList.ForceLoad)
	B.ReskinInput(AddonList.SearchBox)

	hooksecurefunc("AddonList_InitAddon", function(entry)
		if not entry.styled then
			B.ReskinCheck(entry.Enabled)
			B.ReskinButton(entry.LoadAddonButton)
			hooksecurefunc(entry.Enabled:GetCheckedTexture(), "SetDesaturated", forceSaturation)

			B.ReplaceIconString(entry.Title)
			hooksecurefunc(entry.Title, "SetText", B.ReplaceIconString)

			entry.styled = true
		end
	end)
end