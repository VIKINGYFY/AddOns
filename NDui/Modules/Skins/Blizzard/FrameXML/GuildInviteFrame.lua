local _, ns = ...
local B, C, L, DB = unpack(ns)

table.insert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	B.SetBD(GuildInviteFrame)
	for i = 1, 10 do
		select(i, GuildInviteFrame:GetRegions()):Hide()
	end
	B.ReskinButton(GuildInviteFrameJoinButton)
	B.ReskinButton(GuildInviteFrameDeclineButton)
end)