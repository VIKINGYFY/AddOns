local _, ns = ...
local B, C, L, DB = unpack(ns)

C.OnLoginThemes["MovieFrame"] = function()

	-- Cinematic

	CinematicFrameCloseDialog:HookScript("OnShow", function(self)
		self:SetScale(UIParent:GetScale())
	end)

	B.StripTextures(CinematicFrameCloseDialog)
	local bg = B.CreateBG(CinematicFrameCloseDialog)
	bg:SetFrameLevel(1)
	B.ReskinButton(CinematicFrameCloseDialogConfirmButton)
	B.ReskinButton(CinematicFrameCloseDialogResumeButton)

	-- Movie

	local closeDialog = MovieFrame.CloseDialog

	closeDialog:HookScript("OnShow", function(self)
		self:SetScale(UIParent:GetScale())
	end)

	B.StripTextures(closeDialog)
	local bg = B.CreateBG(closeDialog)
	bg:SetFrameLevel(1)
	B.ReskinButton(closeDialog.ConfirmButton)
	B.ReskinButton(closeDialog.ResumeButton)
end