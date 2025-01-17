local _, ns = ...
local B, C, L, DB = unpack(ns)

C.OnLoginThemes["PVEFrame"] = function()

	local cr, cg, cb = DB.r, DB.g, DB.b

	PVEFrameLeftInset:SetAlpha(0)
	PVEFrameBlueBg:SetAlpha(0)
	PVEFrame.shadows:SetAlpha(0)

	PVEFrameTab2:SetPoint("LEFT", PVEFrameTab1, "RIGHT", -15, 0)
	PVEFrameTab3:SetPoint("LEFT", PVEFrameTab2, "RIGHT", -15, 0)

	local iconSize = 60-2*C.mult
	for i = 1, 4 do
		local bu = GroupFinderFrame["groupButton"..i]
		if bu then
			bu.ring:Hide()
			B.ReskinButton(bu)
			bu.bg:SetColorTexture(cr, cg, cb, .25)
			bu.bg:SetInside(bu.__bg)

			bu.icon:SetPoint("LEFT", bu, "LEFT")
			bu.icon:SetSize(iconSize, iconSize)
			B.ReskinIcon(bu.icon)
		end
	end

	hooksecurefunc("GroupFinderFrame_SelectGroupButton", function(index)
		for i = 1, 3 do
			local button = GroupFinderFrame["groupButton"..i]
			if i == index then
				button.bg:Show()
			else
				button.bg:Hide()
			end
		end
	end)

	B.ReskinFrame(PVEFrame)
	B.ReskinFrameTab(PVEFrame, 4)

	if ScenarioQueueFrame then
		B.StripTextures(ScenarioFinderFrame)
		ScenarioQueueFrameBackground:SetAlpha(0)
		B.ReskinDropDown(ScenarioQueueFrameTypeDropdown)
		B.ReskinButton(ScenarioQueueFrameFindGroupButton)
		B.ReskinScroll(ScenarioQueueFrameRandomScrollFrame.ScrollBar)
		if ScenarioQueueFrameRandomScrollFrameScrollBar then
			ScenarioQueueFrameRandomScrollFrameScrollBar:SetAlpha(0)
		end
	end
end