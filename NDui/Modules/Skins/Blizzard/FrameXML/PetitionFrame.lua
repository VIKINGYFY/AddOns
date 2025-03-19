local _, ns = ...
local B, C, L, DB = unpack(ns)

C.OnLoginThemes["PetitionFrame"] = function()

	B.ReskinFrame(PetitionFrame)
	B.ReskinButton(PetitionFrameSignButton)
	B.ReskinButton(PetitionFrameRequestButton)
	B.ReskinButton(PetitionFrameRenameButton)
	B.ReskinButton(PetitionFrameCancelButton)

	PetitionFrameCharterTitle:SetTextColor(1, 1, 0)
	PetitionFrameCharterTitle:SetShadowColor(0, 0, 0)
	PetitionFrameMasterTitle:SetTextColor(1, 1, 0)
	PetitionFrameMasterTitle:SetShadowColor(0, 0, 0)
	PetitionFrameMemberTitle:SetTextColor(1, 1, 0)
	PetitionFrameMemberTitle:SetShadowColor(0, 0, 0)
end