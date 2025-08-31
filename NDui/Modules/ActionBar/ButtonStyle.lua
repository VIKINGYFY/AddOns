local _, ns = ...
local B, C, L, DB = unpack(ns)

local Bar = B:GetModule("Actionbar")

local keyButton = string.gsub(KEY_BUTTON4, "%d", "")
local keyNumpad = string.gsub(KEY_NUMPAD1, "%d", "")

local replaces = {
	{"("..keyButton..")", "M"},
	{"("..keyNumpad..")", "N"},
	{"(a%-)", "a"},
	{"(c%-)", "c"},
	{"(s%-)", "s"},
	{KEY_BUTTON3, "M3"},
	{KEY_MOUSEWHEELUP, "MU"},
	{KEY_MOUSEWHEELDOWN, "MD"},
	{KEY_SPACE, "Sp"},
	{"CAPSLOCK", "CL"},
	{"Capslock", "CL"},
	{"BUTTON", "M"},
	{"NUMPAD", "N"},
	{"(META%-)", "m"},
	{"(Meta%-)", "m"},
	{"(ALT%-)", "a"},
	{"(CTRL%-)", "c"},
	{"(SHIFT%-)", "s"},
	{"MOUSEWHEELUP", "MU"},
	{"MOUSEWHEELDOWN", "MD"},
	{"SPACE", "Sp"},
}

function Bar:UpdateHotKey()
	local text = self:GetText()
	if not text then return end

	if text == RANGE_INDICATOR then
		text = ""
	else
		for _, value in pairs(replaces) do
			text = string.gsub(text, value[1], value[2])
		end
	end
	self:SetFormattedText("%s", text)
end

function Bar:UpdateEquipedColor(button)
	if not button.__bg then return end

	if button.Border:IsShown() then
		button.__bg:SetBackdropBorderColor(DB.r, DB.g, DB.b)
	else
		B.SetBorderColor(button.__bg)
	end
end

function Bar:StyleActionButton(button)
	if not button or button.__bg then return end

	B.CleanTextures(button)

	button.__bg = B.CreateBG(button, -1)

	B.ReskinCPTex(button, button.__bg, true)
	B.UpdateButton(button, button.__bg)

	local flash = B.GetObject(button, "Flash")
	if flash then
		B.ReskinHLTex(flash, button.__bg)
	end

	local highlight = B.GetObject(button, "HighlightTexture")
	if highlight then
		B.ReskinHLTex(highlight, button.__bg)
	end

	local spellHighlight = B.GetObject(button, "SpellHighlightTexture")
	if spellHighlight then
		B.ReskinBBTex(spellHighlight, button.__bg)
	end

	local hotkey = B.GetObject(button, "HotKey")
	if hotkey then
		Bar.UpdateHotKey(hotkey)
		hooksecurefunc(hotkey, "SetText", Bar.UpdateHotKey)
	end
end

function Bar:ReskinBars()
	for i = 1, 8 do
		for j = 1, 12 do
			Bar:StyleActionButton(_G["NDui_ActionBar"..i.."Button"..j])
		end
	end
	--petbar buttons
	for i = 1, NUM_PET_ACTION_SLOTS do
		Bar:StyleActionButton(_G["PetActionButton"..i])
	end
	--stancebar buttons
	for i = 1, 10 do
		Bar:StyleActionButton(_G["StanceButton"..i])
	end
	--leave vehicle
	Bar:StyleActionButton(_G["NDui_LeaveVehicleButton"])
	--extra action button
	Bar:StyleActionButton(_G["ExtraActionButton1"])
	--spell flyout
	SpellFlyout.Background:SetAlpha(0)
	local numFlyouts = 1
	local function checkForFlyoutButtons()
		local button = _G["SpellFlyoutPopupButton"..numFlyouts]
		while button do
			Bar:StyleActionButton(button)
			numFlyouts = numFlyouts + 1
			button = _G["SpellFlyoutPopupButton"..numFlyouts]
		end
	end
	SpellFlyout:HookScript("OnShow", checkForFlyoutButtons)
	SpellFlyout:HookScript("OnHide", checkForFlyoutButtons)
end