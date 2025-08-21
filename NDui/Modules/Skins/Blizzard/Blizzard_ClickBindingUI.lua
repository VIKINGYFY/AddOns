local _, ns = ...
local B, C, L, DB = unpack(ns)

local function updateNewGlow(self)
	if self.NewOutline:IsShown() then
		self.bg:SetBackdropBorderColor(0, .7, .08)
	else
		B.SetBorderColor(self.bg)
	end
end

local function updateIconGlow(self, show)
	if show then
		self.__owner.bg:SetBackdropBorderColor(0, .7, .08)
	else
		B.SetBorderColor(self.__owner.bg)
	end
end

local function reskinScrollChild(self)
	for i = 1, self.ScrollTarget:GetNumChildren() do
		local child = select(i, self.ScrollTarget:GetChildren())
		local icon = child and child.Icon
		if icon and not icon.bg then
			icon.bg = B.ReskinIcon(icon)
			child.Background:Hide()
			child.bg = B.CreateBDFrame(child.Background, .25)

			B.ReskinButton(child.DeleteButton)
			child.DeleteButton:SetSize(20, 20)
			child.FrameHighlight:SetInside(child.bg)
			child.FrameHighlight:SetColorTexture(1, 1, 1, .25) -- 0.25 might be too much

			child.NewOutline:SetTexture(nil)
			child.BindingText:SetFontObject(Game12Font)
			hooksecurefunc(child, "Init", updateNewGlow)

			local iconHighlight = child.IconHighlight
			iconHighlight:SetTexture(nil)
			iconHighlight.__owner = icon
			hooksecurefunc(iconHighlight, "SetShown", updateIconGlow)
		end
	end
end

C.OnLoadThemes["Blizzard_ClickBindingUI"] = function()
	local frame = _G.ClickBindingFrame

	B.ReskinFrame(frame)
	frame.TutorialButton.Ring:Hide()
	frame.TutorialButton:SetPoint("TOPLEFT", frame, "TOPLEFT", -12, 12)

	B.ReskinButton(frame.ResetButton)
	B.ReskinButton(frame.AddBindingButton)
	B.ReskinButton(frame.SaveButton)
	B.ReskinScroll(frame.ScrollBar)

	frame.ScrollBoxBackground:Hide()
	hooksecurefunc(frame.ScrollBox, "Update", reskinScrollChild)

	frame.TutorialFrame.NineSlice:Hide()
	B.SetBD(frame.TutorialFrame)

	if frame.EnableMouseoverCastCheckbox then
		B.ReskinCheck(frame.EnableMouseoverCastCheckbox)
	end
end