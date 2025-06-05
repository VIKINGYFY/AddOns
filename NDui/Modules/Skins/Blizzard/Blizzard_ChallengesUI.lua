local _, ns = ...
local B, C, L, DB = unpack(ns)

local function Reskin_ChallengesFrame(self)
	for i = 1, #self.maps do
		local button = self.DungeonIcons[i]
		if button and not button.styled then
			button:GetRegions():Hide()
			button.HighestLevel:SetDrawLayer("OVERLAY")

			B.ReskinIcon(button.Icon)

			button.styled = true
		end

		if i == 1 then
			B.UpdatePoint(self.WeeklyInfo.Child.SeasonBest, "BOTTOMLEFT", self.DungeonIcons[i], "TOPLEFT", 0, 2)
			B.UpdatePoint(button, "BOTTOMLEFT", ChallengesFrame, "BOTTOMLEFT", 3+C.mult, 3+C.mult)
		else
			B.UpdatePoint(self.DungeonIcons[i], "LEFT", self.DungeonIcons[i-1], "RIGHT", 3, 0)
		end
	end

	if C_AddOns.IsAddOnLoaded("AngryKeystones") and not self.styled then
		local schedule = AngryKeystones.Modules.Schedule
		local affixFrame = schedule.AffixFrame
		if affixFrame then
			B.StripTextures(affixFrame)
			B.CreateBDFrame(affixFrame, .25)
			if affixFrame.Entries then
				for i = 1, 3 do
					B.AffixesSetup(affixFrame.Entries[i])
				end
			end

			local partyFrame = schedule.PartyFrame
			B.StripTextures(partyFrame)
			B.CreateBDFrame(partyFrame, .25)
		end

		self.styled = true
	end
end

local function Reskin_WeeklyInfo(self)
	local affixes = C_MythicPlus.GetCurrentAffixes()
	if affixes then
		B.ReskinAffixes(self.Child)
	end
end

local function Reskin_KeystoneFrame(self)
	self.Divider:Hide()
	self.InstructionBackground:Hide()
	self:GetRegions():Hide()
end

local function Reskin_AffixsSetUp(_, affixID)
	local _, _, texture = C_ChallengeMode.GetAffixInfo(affixID)
	if texture then
		ChallengesFrame.SeasonChangeNoticeFrame.Affix.Portrait:SetTexture(texture)
	end
end

C.OnLoadThemes["Blizzard_ChallengesUI"] = function()
	B.StripTextures(ChallengesFrame)
	B.StripTextures(ChallengesFrame.WeeklyInfo.Child)

	ChallengesFrame.Background:SetInside()

	hooksecurefunc(ChallengesFrame, "Update", Reskin_ChallengesFrame)
	hooksecurefunc(ChallengesFrame.WeeklyInfo, "SetUp", Reskin_WeeklyInfo)

	local keystoneFrame = ChallengesKeystoneFrame
	B.SetBD(keystoneFrame)
	B.ReskinClose(keystoneFrame.CloseButton)
	B.ReskinButton(keystoneFrame.StartButton)

	hooksecurefunc(keystoneFrame, "Reset", Reskin_KeystoneFrame)
	hooksecurefunc(keystoneFrame, "OnKeystoneSlotted", B.ReskinAffixes)

	-- New season
	local noticeFrame = ChallengesFrame.SeasonChangeNoticeFrame
	B.ReskinButton(noticeFrame.Leave)
	B.ReskinText(noticeFrame.NewSeason, 1, .8, 0)
	B.ReskinText(noticeFrame.SeasonDescription, 1, 1, 1)
	B.ReskinText(noticeFrame.SeasonDescription2, 1, 1, 1)
	B.ReskinText(noticeFrame.SeasonDescription3, 1, .8, 0)

	local affix = noticeFrame.Affix
	B.StripTextures(affix)
	B.ReskinIcon(affix.Portrait)

	hooksecurefunc(affix, "SetUp", Reskin_AffixsSetUp)
end