local _, ns = ...
local B, C, L, DB = unpack(ns)

C.OnLoadThemes["Blizzard_Contribution"] = function()
	B.ReskinFrame(ContributionCollectionFrame)

	hooksecurefunc(ContributionMixin, "Update", function(self)
		if not self.styled then
			B.ReskinText(self.Header.Text, 1, 1, 0)
			B.ReskinButton(self.ContributeButton)
			B.ReplaceIconString(self.ContributeButton)
			hooksecurefunc(self.ContributeButton, "SetText", B.ReplaceIconString)

			B.StripTextures(self.Status)
			B.CreateBDFrame(self.Status, .25, nil, -1)

			self.styled = true
		end
	end)

	hooksecurefunc(ContributionRewardMixin, "Setup", function(self)
		if not self.styled then
			B.ReskinText(self.RewardName, 1, 1, 1)
			self.Border:Hide()
			self:GetRegions():Hide()
			B.ReskinIcon(self.Icon)

			self.styled = true
		end
	end)
end