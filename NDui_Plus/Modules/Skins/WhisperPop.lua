local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local _G = getfenv(0)
local pairs = pairs

local function reskinListFont()
	local listButtons = _G.WhisperPopFrameList.listButtons
	for _, button in pairs(listButtons) do
		if button.text and not button.styled then
			P.ReskinFont(button.text)
			button.styled = true
		end
	end
end

local function reskinArrow(button, name)
	button:SetNormalTexture(Media.."UI-ChatIcon-Scroll"..name.."-Up")
	button:SetPushedTexture(Media.."UI-ChatIcon-Scroll"..name.."-Down")
	button:SetDisabledTexture(Media.."UI-ChatIcon-Scroll"..name.."-Disabled")
	if button.flashFrame then
		button.flashFrame.texture:SetTexture(Media.."UI-ChatIcon-BlinkHilight")
	end
end

function S:WhisperPop()
	if not S.db["WhisperPop"] then return end

	B.ReskinFrame(WhisperPopFrame)
	B.ReskinFrame(WhisperPopMessageFrame)

	B.ReskinCheck(WhisperPopMessageFrameProtectCheck)
	B.ReskinScroll(WhisperPopFrameListScrollBar)
	B.ReskinHLTex(WhisperPopFrameListHighlightTexture, nil, true)
	B.ReskinClose(WhisperPopFrameListDelete, nil, nil, nil, true)

	local arrows = {
		{WhisperPopScrollingMessageFrameButtonUp, "up"},
		{WhisperPopScrollingMessageFrameButtonDown, "down"},
		{WhisperPopScrollingMessageFrameButtonEnd, "bottom"},
	}

	for index, arrow in ipairs(arrows) do
		local arrowButton, arrowType = unpack(arrow)
		B.ReskinArrow(arrowButton, arrowType)

		if arrowButton.flashFrame then
			arrowButton.flashFrame:SetOutside(arrowButton.__bg, 4, 4)
		end

		if index < #arrows then
			local nextButton = arrows[index + 1][1]
			B.UpdatePoint(arrowButton, "BOTTOM", nextButton, "TOP", 0, 5)
		end
	end

	local lists = {
		WhisperPopFrameTopCloseButton,
		WhisperPopMessageFrameTopCloseButton,
	}
	for _, list in pairs(lists) do
		B.ReskinClose(list)
	end

	local buttons = {
		"WhisperPopFrameConfig",
		"WhisperPopNotifyButton",
	}
	for _, button in pairs(buttons) do
		local bu = _G[button]
		B.CleanTextures(bu)

		local icbg = B.ReskinIcon(_G[button.."Icon"])
		B.ReskinHLTex(bu, icbg)
		B.ReskinCPTex(bu, icbg)
	end
end

S:RegisterSkin("WhisperPop", S.WhisperPop)