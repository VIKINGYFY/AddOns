local _, ns = ...
local B, C, L, DB = unpack(ns)

table.insert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	local cr, cg, cb = DB.r, DB.g, DB.b

	local function forceSaturation(self, _, force)
		if force then return end
		self:SetVertexColor(cr, cg, cb)
		self:SetDesaturated(true, true)
	end

	B.ReskinFrame(AddonList)
	B.ReskinDropDown(AddonList.Dropdown)
	B.ReskinScroll(AddonList.ScrollBar)

	if DB.isNewPatch then
		B.ReskinButton(AddonList.EnableAllButton)
		B.ReskinButton(AddonList.DisableAllButton)
		B.ReskinButton(AddonList.CancelButton)
		B.ReskinButton(AddonList.OkayButton)
		B.ReskinCheck(AddonList.ForceLoad)
		B.ReskinInput(AddonList.SearchBox)
	
		hooksecurefunc("AddonList_InitAddon", function(entry)
			if not entry.styled then
				B.ReskinCheck(entry.Enabled, true)
				B.ReskinButton(entry.LoadAddonButton)
				hooksecurefunc(entry.Enabled:GetCheckedTexture(), "SetDesaturated", forceSaturation)
	
				B.ReplaceIconString(entry.Title)
				hooksecurefunc(entry.Title, "SetText", B.ReplaceIconString)
	
				entry.styled = true
			end
		end)
	else
		B.ReskinButton(AddonListEnableAllButton)
		B.ReskinButton(AddonListDisableAllButton)
		B.ReskinButton(AddonListCancelButton)
		B.ReskinButton(AddonListOkayButton)
		B.ReskinCheck(AddonListForceLoad)
	
		AddonListForceLoad:SetSize(26, 26)
	
		hooksecurefunc("AddonList_InitButton", function(entry)
			if not entry.styled then
				B.ReskinCheck(entry.Enabled, true)
				B.ReskinButton(entry.LoadAddonButton)
				hooksecurefunc(entry.Enabled:GetCheckedTexture(), "SetDesaturated", forceSaturation)
	
				B.ReplaceIconString(entry.Title)
				hooksecurefunc(entry.Title, "SetText", B.ReplaceIconString)
	
				entry.styled = true
			end
		end)
	end
end)