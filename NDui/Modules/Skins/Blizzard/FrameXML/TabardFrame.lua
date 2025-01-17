local _, ns = ...
local B, C, L, DB = unpack(ns)

C.OnLoginThemes["TabardFrame"] = function()

	B.ReskinFrame(TabardFrame)
	TabardFrameMoneyInset:Hide()
	TabardFrameMoneyBg:Hide()
	B.CreateBDFrame(TabardFrameCostFrame, .25)
	B.ReskinButton(TabardFrameAcceptButton)
	B.ReskinButton(TabardFrameCancelButton)
	B.ReskinArrow(TabardCharacterModelRotateLeftButton, "left")
	B.ReskinArrow(TabardCharacterModelRotateRightButton, "right")
	TabardCharacterModelRotateRightButton:SetPoint("TOPLEFT", TabardCharacterModelRotateLeftButton, "TOPRIGHT", 1, 0)

	TabardFrameCustomizationBorder:Hide()
	for i = 1, 5 do
		B.StripTextures(_G["TabardFrameCustomization"..i])
		B.ReskinArrow(_G["TabardFrameCustomization"..i.."LeftButton"], "left")
		B.ReskinArrow(_G["TabardFrameCustomization"..i.."RightButton"], "right")
	end
end