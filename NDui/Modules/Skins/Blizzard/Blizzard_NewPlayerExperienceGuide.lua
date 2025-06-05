local _, ns = ...
local B, C, L, DB = unpack(ns)

C.OnLoadThemes["Blizzard_NewPlayerExperience"] = function()
	B.ReskinButton(KeyboardMouseConfirmButton)
	if NPE_TutorialWalk_Frame then
		NPE_TutorialWalk_Frame.ContainerFrame.TURNLEFT.KeyBind:SetTextColor(1, .8, 0)
		NPE_TutorialWalk_Frame.ContainerFrame.TURNRIGHT.KeyBind:SetTextColor(1, .8, 0)
		NPE_TutorialWalk_Frame.ContainerFrame.MOVEFORWARD.KeyBind:SetTextColor(1, .8, 0)
		NPE_TutorialWalk_Frame.ContainerFrame.MOVEBACKWARD.KeyBind:SetTextColor(1, .8, 0)
		NPE_TutorialSingleKey_Frame.ContainerFrame.KeyBind.KeyBind:SetTextColor(1, .8, 0)
	end
end

C.OnLoadThemes["Blizzard_NewPlayerExperienceGuide"] = function()
	local GuideFrame = GuideFrame

	B.ReskinFrame(GuideFrame)
	GuideFrame.Title:SetTextColor(1, .8, 0)
	GuideFrame.ScrollFrame.Child.Text:SetTextColor(1, 1, 1)
	B.ReskinScroll(GuideFrame.ScrollFrame.ScrollBar)
	B.ReskinButton(GuideFrame.ScrollFrame.ConfirmationButton)
end