local _, ns = ...
local B, C, L, DB = unpack(ns)

local function SkinFactionCategory(button)
	if button.UnlockedState and not button.styled then
		button.UnlockedState.WatchFactionButton:SetSize(28, 28)
		B.ReskinCheck(button.UnlockedState.WatchFactionButton)
		button.UnlockedState.WatchFactionButton.Label:SetFontObject(Game18Font)

		button.styled = true
	end
end

local function SkinLandingOverlay(frame)
	if frame and not frame.styled then
		B.StripTextures(frame)
		B.SetBD(frame)

		if frame.SkillsButton then
			B.ReskinButton(frame.SkillsButton)
		end
		if frame.CloseButton then
			B.ReskinClose(frame.CloseButton)
		end
		if frame.ScrollFadeOverlay then
			frame.ScrollFadeOverlay:SetAlpha(0)
		end
		if frame.MajorFactionList then
			B.ReskinScroll(frame.MajorFactionList.ScrollBar)
			frame.MajorFactionList.ScrollBox:ForEachFrame(SkinFactionCategory)
			hooksecurefunc(frame.MajorFactionList.ScrollBox, "Update", function(self)
				self:ForEachFrame(SkinFactionCategory)
			end)
		end

		frame.styled = true
	end
end

C.OnLoadThemes["Blizzard_ExpansionLandingPage"] = function()
	local frame = _G.ExpansionLandingPage

	frame:HookScript("OnShow", function()
		local overlay = frame.Overlay
		if overlay then
			if overlay.DragonridingPanel then
				SkinLandingOverlay(overlay.DragonridingPanel)
			elseif overlay.WarWithinLandingOverlay then
				SkinLandingOverlay(overlay.WarWithinLandingOverlay)
			end
		end
	end)
end