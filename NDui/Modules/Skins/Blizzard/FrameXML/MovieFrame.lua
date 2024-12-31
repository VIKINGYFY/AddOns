local _, ns = ...
local B, C, L, DB = unpack(ns)

table.insert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	-- Cinematic

	CinematicFrameCloseDialog:HookScript("OnShow", function(self)
		self:SetScale(UIParent:GetScale())
	end)

	B.StripTextures(CinematicFrameCloseDialog)
	local bg = B.SetBD(CinematicFrameCloseDialog)
	bg:SetFrameLevel(1)
	B.ReskinButton(CinematicFrameCloseDialogConfirmButton)
	B.ReskinButton(CinematicFrameCloseDialogResumeButton)

	-- Movie

	local closeDialog = MovieFrame.CloseDialog

	closeDialog:HookScript("OnShow", function(self)
		self:SetScale(UIParent:GetScale())
	end)

	B.StripTextures(closeDialog)
	local bg = B.SetBD(closeDialog)
	bg:SetFrameLevel(1)
	B.ReskinButton(closeDialog.ConfirmButton)
	B.ReskinButton(closeDialog.ResumeButton)
end)