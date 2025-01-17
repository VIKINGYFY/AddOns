local _, ns = ...
local B, C, L, DB = unpack(ns)
local cr, cg, cb = DB.r, DB.g, DB.b
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
		button.__bg:SetBackdropBorderColor(cr, cg, cb)
	else
		B.SetBorderColor(button.__bg)
	end
end

function Bar:StyleActionButton(button)
	if not button or button.__bg then return end

	button.__bg = B.SetBD(button)
	button.__bg:SetFrameLevel(button:GetFrameLevel() - 1)

	local icon = B.GetObject(button, "Icon")
	if icon then
		icon:SetInside(button.__bg)
		icon:SetDrawLayer("ARTWORK")

		if not icon.__lockdown then
			icon:SetTexCoord(unpack(DB.TexCoord))
		end
	end

	local cooldown = B.GetObject(button, "Cooldown")
	if cooldown then
		cooldown:SetInside(button.__bg)
	end

	local pushed = B.GetObject(button, "PushedTexture")
	if pushed then
		B.ReskinBGBorder(pushed, button.__bg)
		pushed:SetColorTexture(1, 1, 1)
	end

	local checked = B.GetObject(button, "CheckedTexture")
	if checked then
		B.ReskinBGBorder(checked, button.__bg)
		checked:SetColorTexture(0, 1, 1)
	end

	local highlight = B.GetObject(button, "HighlightTexture")
	if highlight then
		B.ReskinHLTex(highlight, button.__bg)
	end

	local spellHighlight = B.GetObject(button, "SpellHighlightTexture")
	if spellHighlight then
		B.ReskinBGBorder(spellHighlight, button.__bg)
		spellHighlight:SetColorTexture(1, 1, 1)
	end

	local hotkey = B.GetObject(button, "HotKey")
	if hotkey then
		Bar.UpdateHotKey(hotkey)
		hooksecurefunc(hotkey, "SetText", Bar.UpdateHotKey)
	end

	local autoCast = B.GetObject(button, "AutoCastOverlay")
	if autoCast then
		autoCast:SetAllPoints(button.__bg)
	end

	local style = B.GetObject(button, "style")
	if style then style:SetAlpha(0) end

	local normal = B.GetObject(button, "NormalTexture")
	if normal then normal:SetAlpha(0) end

	local normal2 = button:GetNormalTexture()
	if normal2 then normal2:SetAlpha(0) end

	local flash = B.GetObject(button, "Flash")
	if flash then flash:SetTexture(nil) end

	local border = B.GetObject(button, "Border")
	if border then border:SetTexture(nil) end

	local newActionTexture = B.GetObject(button, "NewActionTexture")
	if newActionTexture then newActionTexture:SetTexture(nil) end

	local iconMask = B.GetObject(button, "IconMask")
	if iconMask then iconMask:Hide() end

	local slotbg = B.GetObject(button, "SlotBackground")
	if slotbg then slotbg:Hide() end
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
		local button = _G["SpellFlyoutButton"..numFlyouts]
		while button do
			Bar:StyleActionButton(button)
			numFlyouts = numFlyouts + 1
			button = _G["SpellFlyoutButton"..numFlyouts]
		end
	end
	SpellFlyout:HookScript("OnShow", checkForFlyoutButtons)
	SpellFlyout:HookScript("OnHide", checkForFlyoutButtons)
end