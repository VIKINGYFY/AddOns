local _, ns = ...
local B, C, L, DB = unpack(ns)

local Type_StatusBar = _G.Enum.UIWidgetVisualizationType.StatusBar
local Type_CaptureBar = _G.Enum.UIWidgetVisualizationType.CaptureBar
local Type_SpellDisplay = _G.Enum.UIWidgetVisualizationType.SpellDisplay
local Type_DoubleStatusBar = _G.Enum.UIWidgetVisualizationType.DoubleStatusBar
local Type_ItemDisplay = _G.Enum.UIWidgetVisualizationType.ItemDisplay

local function ResetLabelColor(text, _, _, _, _, force)
	if not force then
		text:SetTextColor(1, 1, 1, 1, true)
	end
end

local function ReskinWidgetStatusBar(bar)
	if bar and not bar.styled then
		B.CleanTextures(bar)
		B.CreateBG(bar)

		if bar.Label then
			--bar.Label:SetPoint("CENTER", 0, -5)
			--bar.Label:SetFontObject(Game12Font)
			ResetLabelColor(bar.Label)
			hooksecurefunc(bar.Label, "SetTextColor", ResetLabelColor)
		end

		bar.styled = true
	end
end

local function ReskinDoubleStatusBarWidget(self)
	if not self.styled then
		ReskinWidgetStatusBar(self.LeftBar)
		ReskinWidgetStatusBar(self.RightBar)

		self.styled = true
	end
end

local function ReskinPVPCaptureBar(self)
	B.StripTextures(self, 0)

	self.LeftBar:SetTexture(DB.normTex)
	self.NeutralBar:SetTexture(DB.normTex)
	self.RightBar:SetTexture(DB.normTex)

	self.LeftBar:SetVertexColor(.2, .6, 1)
	self.NeutralBar:SetVertexColor(.8, .8, .8)
	self.RightBar:SetVertexColor(.9, .2, .2)

	if not self.bg then
		self.bg = B.CreateBG(self)
		self.bg:SetPoint("TOPLEFT", self.LeftBar, -2, 2)
		self.bg:SetPoint("BOTTOMRIGHT", self.RightBar, 2, -2)
	end
end

local function ReskinSpellDisplayWidget(spell)
	if not spell.bg then
		spell.Border:SetAlpha(0)
		spell.DebuffBorder:SetAlpha(0)
		spell.bg = B.ReskinIcon(spell.Icon)
	end
	spell.IconMask:Hide()
end

local function ReskinPowerBarWidget(self)
	if not self.widgetFrames then return end

	for _, widgetFrame in pairs(self.widgetFrames) do
		if widgetFrame.widgetType == Type_StatusBar then
			if not widgetFrame:IsForbidden() then
				ReskinWidgetStatusBar(widgetFrame.Bar)
			end
		end
	end
end

local function ReskinWidgetItemDisplay(item)
	if not item.bg then
		item.bg = B.ReskinIcon(item.Icon)
		B.ReskinBorder(item.IconBorder, true)
	end
	item.IconMask:Hide()
end

local function ReskinWidgetGroups(self)
	if not self.widgetFrames then return end

	for _, widgetFrame in pairs(self.widgetFrames) do
		if not widgetFrame:IsForbidden() then
			local widgetType = widgetFrame.widgetType
			if widgetType == Type_DoubleStatusBar then
				ReskinDoubleStatusBarWidget(widgetFrame)
			elseif widgetType == Type_SpellDisplay then
				ReskinSpellDisplayWidget(widgetFrame.Spell)
			elseif widgetType == Type_StatusBar then
				ReskinWidgetStatusBar(widgetFrame.Bar)
			elseif widgetType == Type_ItemDisplay then
				ReskinWidgetItemDisplay(widgetFrame.Item)
			end
		end
	end
end

C.OnLoginThemes["UIWidgets"] = function()

	hooksecurefunc(_G.UIWidgetTopCenterContainerFrame, "UpdateWidgetLayout", ReskinWidgetGroups)
	ReskinWidgetGroups(_G.UIWidgetTopCenterContainerFrame)

	hooksecurefunc(_G.UIWidgetBelowMinimapContainerFrame, "UpdateWidgetLayout", function(self)
		if not self.widgetFrames then return end

		for _, widgetFrame in pairs(self.widgetFrames) do
			if widgetFrame.widgetType == Type_CaptureBar then
				if not widgetFrame:IsForbidden() then
					ReskinPVPCaptureBar(widgetFrame)
				end
			end
		end
	end)

	hooksecurefunc(_G.UIWidgetPowerBarContainerFrame, "UpdateWidgetLayout", ReskinPowerBarWidget)
	ReskinPowerBarWidget(_G.UIWidgetPowerBarContainerFrame)

	hooksecurefunc(_G.ObjectiveTrackerUIWidgetContainer, "UpdateWidgetLayout", ReskinPowerBarWidget)
	ReskinPowerBarWidget(_G.ObjectiveTrackerUIWidgetContainer)

	--[[ if font outline enabled in tooltip, fix text shows in two lines on Torghast info
	hooksecurefunc(_G.UIWidgetTemplateTextWithStateMixin, "Setup", function(self)
		self.Text:SetWidth(self.Text:GetStringWidth() + 2)
	end)]]

	-- needs review, might remove this in the future
	hooksecurefunc(_G.UIWidgetTemplateStatusBarMixin, "Setup", function(self)
		if self:IsForbidden() then return end
		ReskinWidgetStatusBar(self.Bar)
		if self.Label then
			self.Label:SetTextColor(1, .8, 0)
		end
	end)

	B.ReskinButton(_G.UIWidgetCenterDisplayFrame.CloseButton)
end