local _, ns = ...
local B, C, L, DB = unpack(ns)

C.OnLoginThemes["PetitionFrame"] = function()
	B.ReskinFrame(PetitionFrame)
	B.ReskinButton(PetitionFrameSignButton)
	B.ReskinButton(PetitionFrameRequestButton)
	B.ReskinButton(PetitionFrameRenameButton)
	B.ReskinButton(PetitionFrameCancelButton)

	B.ReskinText(PetitionFrameCharterTitle, 1, .8, 0)
	B.ReskinText(PetitionFrameMasterTitle, 1, .8, 0)
	B.ReskinText(PetitionFrameMemberTitle, 1, .8, 0)
end