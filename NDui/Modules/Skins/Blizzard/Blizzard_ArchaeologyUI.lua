local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_ArchaeologyUI"] = function()
	B.ReskinFrame(ArchaeologyFrame)
	ArchaeologyFrame:DisableDrawLayer("BACKGROUND")
	B.ReskinButton(ArchaeologyFrameArtifactPageSolveFrameSolveButton)
	B.ReskinButton(ArchaeologyFrameArtifactPageBackButton)

	ArchaeologyFrameSummaryPageTitle:SetTextColor(1, 1, 1)
	ArchaeologyFrameArtifactPageHistoryTitle:SetTextColor(1, .8, 0)
	ArchaeologyFrameArtifactPageHistoryScrollChildText:SetTextColor(1, 1, 1)
	ArchaeologyFrameHelpPageTitle:SetTextColor(1, 1, 1)
	ArchaeologyFrameHelpPageDigTitle:SetTextColor(1, 1, 1)
	ArchaeologyFrameHelpPageHelpScrollHelpText:SetTextColor(1, 1, 1)
	ArchaeologyFrameCompletedPage:GetRegions():SetTextColor(1, 1, 1)
	ArchaeologyFrameCompletedPageTitle:SetTextColor(1, 1, 1)
	ArchaeologyFrameCompletedPageTitleTop:SetTextColor(1, 1, 1)
	ArchaeologyFrameCompletedPageTitleMid:SetTextColor(1, 1, 1)
	ArchaeologyFrameCompletedPagePageText:SetTextColor(1, 1, 1)
	ArchaeologyFrameSummaryPagePageText:SetTextColor(1, 1, 1)
	for i = 1, ARCHAEOLOGY_MAX_RACES do
		local bu = _G["ArchaeologyFrameSummaryPageRace"..i]
		bu.raceName:SetTextColor(1, 1, 1)
	end

	for i = 1, ARCHAEOLOGY_MAX_COMPLETED_SHOWN do
		local buttonName = "ArchaeologyFrameCompletedPageArtifact"..i
		local button = _G[buttonName]
		local icon = _G[buttonName.."Icon"]
		local name = _G[buttonName.."ArtifactName"]
		local subText = _G[buttonName.."ArtifactSubText"]
		B.StripTextures(button)
		B.ReskinIcon(icon)
		name:SetTextColor(1, .8, 0)
		subText:SetTextColor(1, 1, 1)
		local bg = B.CreateBDFrame(button, .25)
		bg:SetPoint("TOPLEFT", -4, 4)
		bg:SetPoint("BOTTOMRIGHT", 4, -4)
	end

	ArchaeologyFrameInfoButton:SetPoint("TOPLEFT", 3, -3)
	ArchaeologyFrameSummarytButton:SetPoint("TOPLEFT", ArchaeologyFrame, "TOPRIGHT", 1, -50)
	ArchaeologyFrameSummarytButton:SetFrameLevel(ArchaeologyFrame:GetFrameLevel() - 1)
	ArchaeologyFrameCompletedButton:SetPoint("TOPLEFT", ArchaeologyFrame, "TOPRIGHT", 1, -120)
	ArchaeologyFrameCompletedButton:SetFrameLevel(ArchaeologyFrame:GetFrameLevel() - 1)

	B.ReskinDropDown(ArchaeologyFrameRaceFilter)
	B.ReskinScroll(ArchaeologyFrameArtifactPageHistoryScroll.ScrollBar)
	B.ReskinArrow(ArchaeologyFrameCompletedPagePrevPageButton, "left")
	B.ReskinArrow(ArchaeologyFrameCompletedPageNextPageButton, "right")
	ArchaeologyFrameCompletedPagePrevPageButtonIcon:Hide()
	ArchaeologyFrameCompletedPageNextPageButtonIcon:Hide()
	B.ReskinArrow(ArchaeologyFrameSummaryPagePrevPageButton, "left")
	B.ReskinArrow(ArchaeologyFrameSummaryPageNextPageButton, "right")
	ArchaeologyFrameSummaryPagePrevPageButtonIcon:Hide()
	ArchaeologyFrameSummaryPageNextPageButtonIcon:Hide()

	B.ReskinStatusBar(ArchaeologyFrameRankBar)
	ArchaeologyFrameRankBar:SetHeight(14)
	B.ReskinIcon(ArchaeologyFrameArtifactPageIcon)
	B.ReskinStatusBar(ArchaeologyFrameArtifactPageSolveFrameStatusBar)

	-- ArcheologyDigsiteProgressBar
	B.StripTextures(ArcheologyDigsiteProgressBar)
	B.ReskinStatusBar(ArcheologyDigsiteProgressBar.FillBar)

	local ticks = {}
	ArcheologyDigsiteProgressBar:HookScript("OnShow", function(self)
		local bar = self.FillBar
		if not bar then return end
		B:CreateAndUpdateBarTicks(bar, ticks, bar.fillBarMax)
	end)
end