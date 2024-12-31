local _, ns = ...
local B, C, L, DB = unpack(ns)

table.insert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	GuildRegistrarFrameEditBox:SetHeight(20)
	AvailableServicesText:SetTextColor(1, 1, 1)
	AvailableServicesText:SetShadowColor(0, 0, 0)

	B.ReskinFrame(GuildRegistrarFrame)
	GuildRegistrarFrameEditBox:DisableDrawLayer("BACKGROUND")
	B.CreateBDFrame(GuildRegistrarFrameEditBox, .25)
	B.ReskinButton(GuildRegistrarFrameGoodbyeButton)
	B.ReskinButton(GuildRegistrarFramePurchaseButton)
	B.ReskinButton(GuildRegistrarFrameCancelButton)
end)