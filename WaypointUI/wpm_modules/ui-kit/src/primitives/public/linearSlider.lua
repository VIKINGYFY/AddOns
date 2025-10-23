local env          = select(2, ...)
local MixinUtil    = env.WPM:Import("wpm_modules/mixin-util")
local Frame        = env.WPM:Import("wpm_modules/ui-kit/primitives/frame")

local Mixin        = MixinUtil.Mixin

local LinearSlider = env.WPM:New("wpm_modules/ui-kit/primitives/linearSlider")



local dummy = CreateFrame("Slider"); dummy:Hide()
local ENABLE_FUNC = getmetatable(dummy).__index.Enable
local DISABLE_FUNC = getmetatable(dummy).__index.Disable
local SET_ENABLED_FUNC = getmetatable(dummy).__index.SetEnabled



local LinearSliderMixin = {}
do
    -- Accessor
    --------------------------------

    function LinearSliderMixin:GetThumb()
        return self.__Thumb
    end

    function LinearSliderMixin:GetThumbAnchor()
        return self.__ThumbAnchor
    end


    -- Set
    --------------------------------

    function LinearSliderMixin:SetThumbSize(width, height)
        self.__ThumbAnchor:SetSize(width, height)
    end

    -- Thumb
    --------------------------------

    function LinearSliderMixin:OnThumbMouseDown(button)
        self:TriggerEvent("OnThumbMouseDown", button)
    end

    function LinearSliderMixin:OnThumbMouseUp(button)
        self:TriggerEvent("OnThumbMouseUp", button)
    end

    -- Override
    --------------------------------

    function LinearSliderMixin:EnableSlider()
        ENABLE_FUNC(self)
    end

    function LinearSliderMixin:DisableSlider()
        DISABLE_FUNC(self)
    end

    function LinearSliderMixin:SetEnabledSlider(enabled)
        SET_ENABLED_FUNC(self, enabled)
    end
end




function LinearSlider:New(name, parent)
    name = name or "undefined"


    local linearSlider = Frame:New("Slider", name, parent)
    Mixin(linearSlider, LinearSliderMixin)
    linearSlider:SetObeyStepOnDrag(true)


    -- Thumb Anchor
    --------------------------------

    local thumbAnchor = linearSlider:CreateTexture(name .. ".ThumbAnchor")
    linearSlider:SetThumbTexture(thumbAnchor)


    -- Thumb
    --------------------------------

    local thumb = Frame:New("Frame", name .. ".Thumb", linearSlider)
    thumb:SetPoint("TOPLEFT", thumbAnchor)
    thumb:SetPoint("BOTTOMRIGHT", thumbAnchor)


    -- Initialize
    --------------------------------

    linearSlider:AddAlias("LINEAR_SLIDER_THUMB", thumb)
    linearSlider:AddAlias("LINEAR_SLIDER_TRACK", linearSlider)

    linearSlider.__ThumbAnchor = thumbAnchor
    linearSlider.__Thumb = thumb


    -- Events
    --------------------------------

    linearSlider:HookScript("OnValueChanged", function(_, ...) linearSlider:TriggerEvent("OnValueChanged", ...) end)
    linearSlider:HookScript("OnMinMaxChanged", function(_, ...) linearSlider:TriggerEvent("OnMinMaxChanged", ...) end)
    thumb:HookScript("OnMouseDown", function(_, button) linearSlider:OnThumbMouseDown(button) end)
    thumb:HookScript("OnMouseUp", function(_, button) linearSlider:OnThumbMouseUp(button) end)


    _G[name .. ".ThumbAnchor"] = nil
    return linearSlider
end
