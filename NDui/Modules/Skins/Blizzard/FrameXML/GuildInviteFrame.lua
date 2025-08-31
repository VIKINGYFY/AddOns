local _, ns = ...
local B, C, L, DB = unpack(ns)

C.OnLoginThemes["GuildInviteFrame"] = function()

	B.CreateBG(GuildInviteFrame)
	for i = 1, 10 do
		select(i, GuildInviteFrame:GetRegions()):Hide()
	end
	B.ReskinButton(GuildInviteFrameJoinButton)
	B.ReskinButton(GuildInviteFrameDeclineButton)
end