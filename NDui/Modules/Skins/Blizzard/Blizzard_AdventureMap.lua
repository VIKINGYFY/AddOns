local _, ns = ...
local B, C, L, DB = unpack(ns)

C.OnLoadThemes["Blizzard_AdventureMap"] = function()
	local dialog = AdventureMapQuestChoiceDialog

	B.StripTextures(dialog)
	B.SetBD(dialog)
	B.ReskinButton(dialog.AcceptButton)
	B.ReskinButton(dialog.DeclineButton)
	B.ReskinClose(dialog.CloseButton)
	B.ReskinScroll(dialog.Details.ScrollBar)

	dialog:HookScript("OnShow", function(self)
		if self.styled then return end

		for i = 6, 7 do
			local bu = select(i, dialog:GetChildren())
			if bu then
				bu.ItemNameBG:Hide()

				local icbg = B.ReskinIcon(bu.Icon)
				local bubg = B.CreateBDFrame(bu, .25)
				bubg:ClearAllPoints()
				bubg:SetPoint("LEFT", icbg, "RIGHT", DB.margin, 0)
			end
		end
		dialog.Details.Child.TitleHeader:SetTextColor(1, .8, 0)
		dialog.Details.Child.ObjectivesHeader:SetTextColor(1, .8, 0)

		self.styled = true
	end)
end