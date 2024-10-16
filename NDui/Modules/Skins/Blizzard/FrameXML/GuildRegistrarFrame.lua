local _, ns = ...
local B, C, L, DB = unpack(ns)

table.insert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	GuildRegistrarFrameEditBox:SetHeight(20)
	AvailableServicesText:SetTextColor(1, 1, 1)
	AvailableServicesText:SetShadowColor(0, 0, 0)

	B.ReskinPortraitFrame(GuildRegistrarFrame)
	GuildRegistrarFrameEditBox:DisableDrawLayer("BACKGROUND")
	B.CreateBDFrame(GuildRegistrarFrameEditBox, .25)
	B.Reskin(GuildRegistrarFrameGoodbyeButton)
	B.Reskin(GuildRegistrarFramePurchaseButton)
	B.Reskin(GuildRegistrarFrameCancelButton)
end)