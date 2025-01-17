local _, ns = ...
local B, C, L, DB = unpack(ns)

local function Update_SendMailFrame()
	for i = 1, ATTACHMENTS_MAX_SEND do
		local button = _G["SendMailAttachment"..i]
		local icon = button:GetNormalTexture()

		if HasSendMailItem(i) and icon then
			icon:SetTexCoord(unpack(DB.TexCoord))
			icon:SetInside(button)
		end
	end
end

local function Update_OpenAllMail(self)
	B.UpdatePoint(self, "BOTTOMRIGHT", MailFrameInset, "TOP", -2, 5)
end

C.OnLoginThemes["MailFrame"] = function()
	B.ReskinFrame(MailFrame)
	B.ReskinFrameTab(MailFrame, 2)
	B.ReskinFrame(OpenMailFrame)

	B.StripTextures(SendMailFrame)
	B.StripTextures(SendMailMoneyInset)
	B.ReskinScroll(SendMailScrollFrame.ScrollBar)
	B.ReskinScroll(OpenMailScrollFrame.ScrollBar)
	B.ReskinRadio(SendMailSendMoneyButton)
	B.ReskinRadio(SendMailCODButton)
	B.ReskinArrow(InboxPrevPageButton, "left")
	B.ReskinArrow(InboxNextPageButton, "right")

	B.CreateBDFrame(OpenMailScrollFrame, .25)
	B.CreateBDFrame(SendMailScrollFrame, .25)

	SendMailNameEditBox:SetWidth(200)
	SendMailSubjectEditBox:SetWidth(200)
	SendMailCostMoneyFrame:DisableDrawLayer("BACKGROUND")

	B.UpdatePoint(InboxTitleText, "TOP", MailFrame, "TOP", 0, -5)
	B.UpdatePoint(SendMailTitleText, "TOP", MailFrame, "TOP", 0, -5)
	B.UpdatePoint(OpenMailTitleText, "TOP", OpenMailFrame, "TOP", 0, -5)
	B.UpdatePoint(OpenMailCancelButton, "BOTTOMRIGHT", OpenMailFrame, "BOTTOMRIGHT", -4, 4)
	B.UpdatePoint(SendMailMailButton, "RIGHT", SendMailCancelButton, "LEFT", -1, 0)
	B.UpdatePoint(OpenMailDeleteButton, "RIGHT", OpenMailCancelButton, "LEFT", -1, 0)
	B.UpdatePoint(OpenMailReplyButton, "RIGHT", OpenMailDeleteButton, "LEFT", -1, 0)
	B.UpdatePoint(SendMailMoneySilver, "LEFT", SendMailMoneyGold, "RIGHT", 1, 0)
	B.UpdatePoint(SendMailMoneyCopper, "LEFT", SendMailMoneySilver, "RIGHT", 1, 0)
	B.UpdatePoint(SendMailNameEditBox, "TOPLEFT", SendMailFrame, "TOPLEFT", 80, -30)
	B.UpdatePoint(SendMailSubjectEditBox, "TOPLEFT", SendMailNameEditBox, "BOTTOMLEFT", 0, -1)
	B.UpdatePoint(SendMailCostMoneyFrame, "LEFT", SendMailSubjectEditBox, "RIGHT", 4, 0)

	local fonts = {
		MailFont_Large,
		MailTextFontNormal,
		InvoiceTextFontNormal,
		InvoiceTextFontSmall,
	}
	for _, font in pairs(fonts) do
		B.ReskinText(font, 1, 1, 1)
	end

	local lists = {
		InboxFrameBg,
		SendMailMoneyBg,
		OpenMailArithmeticLine,
		OpenStationeryBackgroundLeft,
		OpenStationeryBackgroundRight,
		SendStationeryBackgroundLeft,
		SendStationeryBackgroundRight,
	}
	for _, list in pairs(lists) do
		list:Hide()
	end

	local buttons = {
		OpenAllMail,
		OpenMailCancelButton,
		OpenMailDeleteButton,
		OpenMailReplyButton,
		OpenMailReportSpamButton,
		SendMailCancelButton,
		SendMailMailButton,
	}
	for _, button in pairs(buttons) do
		B.ReskinButton(button)
	end

	local inputs = {
		SendMailMoneyCopper,
		SendMailMoneyGold,
		SendMailMoneySilver,
		SendMailNameEditBox,
		SendMailSubjectEditBox,
	}
	for _, input in pairs(inputs) do
		B.ReskinInput(input, 20)
		input:EnableDrawLayer("BACKGROUND")
	end

	local buttons = {"OpenMailLetterButton", "OpenMailMoneyButton"}
	for _, name in pairs(buttons) do
		local button = _G[name]
		B.CleanTextures(button)

		local icbg = B.ReskinIcon(_G[name.."IconTexture"])
		B.ReskinHLTex(button, icbg)
	end

	for i = 1, INBOXITEMS_TO_DISPLAY do
		local items = "MailItem"..i
		local buttons = items.."Button"

		local item = _G[items]
		B.StripTextures(item)

		local button = _G[buttons]
		B.StripTextures(button)

		button.bg = B.ReskinIcon(_G[buttons.."Icon"])
		B.ReskinHLTex(button, button.bg)
		B.ReskinCPTex(button, button.bg)
		B.ReskinBorder(_G[buttons.."IconBorder"])

		local sender = _G[items.."Sender"]
		B.UpdatePoint(sender, "BOTTOMLEFT", button.bg, "RIGHT", 4, 1)

		local subject = _G[items.."Subject"]
		B.UpdatePoint(subject, "TOPLEFT", button.bg, "RIGHT", 4, -1)
	end

	for i = 1, ATTACHMENTS_MAX_RECEIVE do
		local buttons = "OpenMailAttachmentButton"..i

		local button = _G[buttons]
		B.CleanTextures(button)

		button.bg = B.ReskinIcon(_G[buttons.."IconTexture"])
		B.ReskinHLTex(button, button.bg)
		B.ReskinCPTex(button, button.bg)
		B.ReskinBorder(button.IconBorder)
	end

	for i = 1, ATTACHMENTS_MAX_SEND do
		local button = _G["SendMailAttachment"..i]
		B.StripTextures(button)

		button.bg = B.CreateBDFrame(button, .25)
		B.ReskinHLTex(button, button.bg)
		B.ReskinCPTex(button, button.bg)
		B.ReskinBorder(button.IconBorder)
	end

	hooksecurefunc("SendMailFrame_Update", Update_SendMailFrame)
end