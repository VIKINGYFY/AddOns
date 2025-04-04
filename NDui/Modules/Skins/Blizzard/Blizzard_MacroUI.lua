local _, ns = ...
local B, C, L, DB = unpack(ns)

C.OnLoadThemes["Blizzard_MacroUI"] = function()
	MacroHorizontalBarLeft:Hide()
	B.StripTextures(MacroFrameTab1)
	B.StripTextures(MacroFrameTab2)

	B.StripTextures(MacroPopupFrame)
	B.StripTextures(MacroPopupFrame.BorderBox)
	MacroFrameTextBackground:HideBackdrop()

	MacroPopupFrame:SetHeight(525)
	MacroNewButton:ClearAllPoints()
	MacroNewButton:SetPoint("RIGHT", MacroExitButton, "LEFT", -1, 0)

	B.ReskinScroll(MacroFrame.MacroSelector.ScrollBar)

	local function handleMacroButton(button)
		local bg = B.ReskinIcon(button.Icon)
		button:DisableDrawLayer("BACKGROUND")
		button.SelectedTexture:SetColorTexture(1, 1, 0, .5)
		button.SelectedTexture:SetInside(bg)
		local hl = button:GetHighlightTexture()
		hl:SetColorTexture(1, 1, 1, .25)
		hl:SetInside(bg)
	end
	handleMacroButton(MacroFrameSelectedMacroButton)

	hooksecurefunc(MacroFrame.MacroSelector.ScrollBox, "Update", function(self)
		for i = 1, self.ScrollTarget:GetNumChildren() do
			local child = select(i, self.ScrollTarget:GetChildren())
			if not child.styled then
				handleMacroButton(child)

				child.styled = true
			end
		end
	end)

	B.ReskinIconSelector(MacroPopupFrame)

	B.ReskinFrame(MacroFrame)
	B.CreateBDFrame(MacroFrameScrollFrame, .25)
	B.ReskinScroll(MacroFrameScrollFrame.ScrollBar)
	B.ReskinButton(MacroDeleteButton)
	B.ReskinButton(MacroNewButton)
	B.ReskinButton(MacroExitButton)
	B.ReskinButton(MacroEditButton)
	B.ReskinButton(MacroSaveButton)
	B.ReskinButton(MacroCancelButton)
end