local _, ns = ...
local B, C, L, DB = unpack(ns)

local function Reset_ToggleOutfitDetailsButton(self, texture)
	self:GetNormalTexture():SetTexCoord(unpack(DB.TexCoord))
	self:GetNormalTexture():SetInside(self.__bg)
	self:SetNormalTexture(texture)
	self:GetPushedTexture():SetTexCoord(unpack(DB.TexCoord))
	self:GetPushedTexture():SetInside(self.__bg)
	self:SetPushedTexture(texture)
end

local function Refresh_OutfitDetailsPanel(self)
	if self.slotPool then
		for slot in self.slotPool:EnumerateActive() do
			if not slot.bg then
				slot.bg = B.ReskinIcon(slot.Icon)
				B.ReskinBorder(slot.IconBorder, true, true)
			end
		end
	end
end

local function Update_SetSelectionPanel(self)
	if not self.bg then
		self.bg = B.ReskinIcon(self.Icon)

		B.ReskinBorder(self.IconBorder, true, true)
		self.BackgroundTexture:SetAlpha(0)
		self.SelectedTexture:SetColorTexture(1, 1, 0, .25)
		self.HighlightTexture:SetColorTexture(1, 1, 1, .25)
	end
end

C.OnLoginThemes["DressUpFrames"] = function()
	-- Dressup Frame
	B.ReskinFrame(DressUpFrame)
	B.ReskinButton(DressUpFrame.LinkButton)
	B.ReskinButton(DressUpFrame.ToggleOutfitDetailsButton)
	B.ReskinButton(DressUpFrameCancelButton)
	B.ReskinButton(DressUpFrameOutfitDropdown.SaveButton)
	B.ReskinButton(DressUpFrameResetButton)
	B.ReskinCheck(TransmogAndMountDressupFrame.ShowMountCheckButton)
	B.ReskinDropDown(DressUpFrameOutfitDropdown)
	B.ReskinMinMax(DressUpFrame.MaximizeMinimizeFrame)
	B.ReskinModelControl(DressUpFrame.ModelScene)

	Reset_ToggleOutfitDetailsButton(DressUpFrame.ToggleOutfitDetailsButton, 1392954) -- 70_professions_scroll_01
	B.UpdatePoint(DressUpFrameResetButton, "RIGHT", DressUpFrameCancelButton, "LEFT", -1, 0)

	local detailsPanel = DressUpFrame.OutfitDetailsPanel
	B.ReskinFrame(detailsPanel)
	detailsPanel:HookScript("OnShow", function(self)
		B.UpdatePoint(self, "LEFT", DressUpFrame, "RIGHT", DB.margin, 0)
	end)
	hooksecurefunc(detailsPanel, "Refresh", function(self)
		Refresh_OutfitDetailsPanel(self)
	end)

	local selectionPanel = DressUpFrame.SetSelectionPanel
	if selectionPanel then
		B.ReskinFrame(selectionPanel)
		B.ReskinScroll(selectionPanel.ScrollBar)
		B.UpdatePoint(selectionPanel, "LEFT", DressUpFrame, "RIGHT", DB.margin, 0)

		selectionPanel:HookScript("OnShow", function(self)
			B.UpdatePoint(self, "LEFT", DressUpFrame, "RIGHT", DB.margin, 0)
		end)
		hooksecurefunc(selectionPanel.ScrollBox, "Update", function(self)
			self:ForEachFrame(Update_SetSelectionPanel)
		end)
	end

	-- SideDressUp
	B.ReskinFrame(SideDressUpFrame)
	B.ReskinButton(SideDressUpFrame.ResetButton)
	SideDressUpFrame:HookScript("OnShow", function(self)
		B.UpdatePoint(self, "LEFT", self:GetParent(), "RIGHT", DB.margin, 0)
	end)

	-- Outfit frame
	B.ReskinFrame(WardrobeOutfitEditFrame)
	B.ReskinInput(WardrobeOutfitEditFrame.EditBox)
	B.ReskinButton(WardrobeOutfitEditFrame.AcceptButton)
	B.ReskinButton(WardrobeOutfitEditFrame.CancelButton)
	B.ReskinButton(WardrobeOutfitEditFrame.DeleteButton)
end