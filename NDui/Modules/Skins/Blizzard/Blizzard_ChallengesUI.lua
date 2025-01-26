local _, ns = ...
local B, C, L, DB = unpack(ns)

C.OnLoadThemes["Blizzard_ChallengesUI"] = function()
	B.StripTextures(ChallengesFrame)
	B.StripTextures(ChallengesFrame.WeeklyInfo.Child)

	ChallengesFrame.Background:SetInside()

	local angryStyle
	local function UpdateIcons(self)
		for i = 1, #self.maps do
			local bu = self.DungeonIcons[i]
			if bu and not bu.styled then
				bu:GetRegions():Hide()
				bu.HighestLevel:SetDrawLayer("OVERLAY")

				B.ReskinIcon(bu.Icon)

				bu.styled = true
			end
			if i == 1 then
				B.UpdatePoint(self.WeeklyInfo.Child.SeasonBest, "BOTTOMLEFT", self.DungeonIcons[i], "TOPLEFT", 0, 2)
				B.UpdatePoint(bu, "BOTTOMLEFT", ChallengesFrame, "BOTTOMLEFT", 3+C.mult, 3+C.mult)
			else
				B.UpdatePoint(self.DungeonIcons[i], "LEFT", self.DungeonIcons[i-1], "RIGHT", 3, 0)
			end
		end

		if C_AddOns.IsAddOnLoaded("AngryKeystones") and not angryStyle then
			local mod = AngryKeystones.Modules.Schedule
			local scheduel = mod.AffixFrame
			if scheduel then
				B.StripTextures(scheduel)
				B.CreateBDFrame(scheduel, .25)
				if scheduel.Entries then
					for i = 1, 3 do
						B.AffixesSetup(scheduel.Entries[i])
					end
				end

				local party = mod.PartyFrame
				B.StripTextures(party)
				B.CreateBDFrame(party, .25)
			end

			angryStyle = true
		end
	end
	hooksecurefunc(ChallengesFrame, "Update", UpdateIcons)

	hooksecurefunc(ChallengesFrame.WeeklyInfo, "SetUp", function(self)
		local affixes = C_MythicPlus.GetCurrentAffixes()
		if affixes then
			B.AffixesSetup(self.Child)
		end
	end)

	local keystone = ChallengesKeystoneFrame
	B.SetBD(keystone)
	B.ReskinClose(keystone.CloseButton)
	B.ReskinButton(keystone.StartButton)

	hooksecurefunc(keystone, "Reset", function(self)
		self:GetRegions():SetAlpha(0)
		self.InstructionBackground:SetAlpha(0)
	end)

	hooksecurefunc(keystone, "OnKeystoneSlotted", B.AffixesSetup)

	-- New season
	local noticeFrame = ChallengesFrame.SeasonChangeNoticeFrame
	B.ReskinButton(noticeFrame.Leave)
	noticeFrame.NewSeason:SetTextColor(1, .8, 0)
	noticeFrame.SeasonDescription:SetTextColor(1, 1, 1)
	noticeFrame.SeasonDescription2:SetTextColor(1, 1, 1)
	noticeFrame.SeasonDescription3:SetTextColor(1, .8, 0)

	local affix = noticeFrame.Affix
	B.StripTextures(affix)
	local bg = B.ReskinIcon(affix.Portrait)
	bg:SetFrameLevel(3)

	hooksecurefunc(affix, "SetUp", function(_, affixID)
		local _, _, texture = C_ChallengeMode.GetAffixInfo(affixID)
		if texture then
			affix.Portrait:SetTexture(texture)
		end
	end)
end