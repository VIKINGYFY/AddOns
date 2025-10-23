local env                                                                                                                  = select(2, ...)
local GenericEnum                                                                                                          = env.WPM:Import("wpm_modules/generic-enum")
local MixinUtil                                                                                                            = env.WPM:Import("wpm_modules/mixin-util")
local Path                                                                                                                 = env.WPM:Import("wpm_modules/path")
local Sound                                                                                                                = env.WPM:Import("wpm_modules/sound")
local UIFont                                                                                                               = env.WPM:Import("wpm_modules/ui-font")
local UIKit                                                                                                                = env.WPM:Import("wpm_modules/ui-kit")
local Frame, Grid, VStack, HStack, ScrollView, ScrollBar, Text, Input, LinearSlider, InteractiveRect, LazyScrollView, List = UIKit.UI.Frame, UIKit.UI.Grid, UIKit.UI.VStack, UIKit.UI.HStack, UIKit.UI.ScrollView, UIKit.UI.ScrollBar, UIKit.UI.Text, UIKit.UI.Input, UIKit.UI.LinearSlider, UIKit.UI.InteractiveRect, UIKit.UI.LazyScrollView, UIKit.UI.List
local UIAnim                                                                                                               = env.WPM:Import("wpm_modules/ui-anim")
local UICSharedMixin                                                                                                       = env.WPM:Import("wpm_modules/uic-sharedmixin")

local Mixin                                                                                                                = MixinUtil.Mixin
local CreateFromMixins                                                                                                     = MixinUtil.CreateFromMixins

local UICGameRange                                                                                                         = env.WPM:New("wpm_modules/uic-game/range")





local PATH        = Path.Root .. "/wpm_modules/uic-game/resources/"
local FILL        = UIKit.Define.Fill{}
local P_FILL      = UIKit.Define.Percentage{ value = 100 }
local ATLAS       = UIKit.Define.Texture_Atlas{ path = PATH .. "UICGameRange.png" }
local TEXTURE_NIL = UIKit.Define.Texture{ path = nil }



-- Stepper Button
--------------------------------

local BACKGROUND_ARROW_LEFT              = ATLAS{ inset = 128, scale = 1, left = 0 / 1024, top = 256 / 1024, right = 256 / 1024, bottom = 512 / 1024 }
local BACKGROUND_ARROW_LEFT_HIGHLIGHTED  = ATLAS{ inset = 128, scale = 1, left = 256 / 1024, top = 256 / 1024, right = 512 / 1024, bottom = 512 / 1024 }
local BACKGROUND_ARROW_LEFT_PUSHED       = ATLAS{ inset = 128, scale = 1, left = 512 / 1024, top = 256 / 1024, right = 768 / 1024, bottom = 512 / 1024 }
local BACKGROUND_ARROW_LEFT_DISABLED     = ATLAS{ inset = 128, scale = 1, left = 768 / 1024, top = 256 / 1024, right = 1024 / 1024, bottom = 512 / 1024 }
local BACKGROUND_ARROW_RIGHT             = ATLAS{ inset = 128, scale = 1, left = 0 / 1024, top = 512 / 1024, right = 256 / 1024, bottom = 768 / 1024 }
local BACKGROUND_ARROW_RIGHT_HIGHLIGHTED = ATLAS{ inset = 128, scale = 1, left = 256 / 1024, top = 512 / 1024, right = 512 / 1024, bottom = 768 / 1024 }
local BACKGROUND_ARROW_RIGHT_PUSHED      = ATLAS{ inset = 128, scale = 1, left = 512 / 1024, top = 512 / 1024, right = 768 / 1024, bottom = 768 / 1024 }
local BACKGROUND_ARROW_RIGHT_DISABLED    = ATLAS{ inset = 128, scale = 1, left = 768 / 1024, top = 512 / 1024, right = 1024 / 1024, bottom = 768 / 1024 }




local StepperButtonMixin = CreateFromMixins(UICSharedMixin.ButtonMixin)

function StepperButtonMixin:UpdateAnimation()
    local buttonState = self:GetButtonState()
    local enabled = self:IsEnabled()

    if not enabled then
        if self.isForward then
            self:background(BACKGROUND_ARROW_RIGHT_DISABLED)
        else
            self:background(BACKGROUND_ARROW_LEFT_DISABLED)
        end
    elseif buttonState == "PUSHED" then
        if self.isForward then
            self:background(BACKGROUND_ARROW_RIGHT_PUSHED)
        else
            self:background(BACKGROUND_ARROW_LEFT_PUSHED)
        end
    elseif buttonState == "HIGHLIGHTED" then
        if self.isForward then
            self:background(BACKGROUND_ARROW_RIGHT_HIGHLIGHTED)
        else
            self:background(BACKGROUND_ARROW_LEFT_HIGHLIGHTED)
        end
    else
        if self.isForward then
            self:background(BACKGROUND_ARROW_RIGHT)
        else
            self:background(BACKGROUND_ARROW_LEFT)
        end
    end
end

function StepperButtonMixin:HandleOnClick()
    local min, max = self.parent.Range:GetMinMaxValues()
    local step = self.parent.Range:GetValueStep()
    local value = self.parent.Range:GetValue()

    if self.isForward then
        self.parent.Range:SetValue(math.min(value + step, max))
    else
        self.parent.Range:SetValue(math.max(value - step, min))
    end
end

function StepperButtonMixin:OnLoad(isForward, parent)
    self:InitButton()
    self.isForward = isForward
    self.parent = parent

    self:RegisterMouseEvents()
    self:HookButtonStateChange(self.UpdateAnimation)
    self:HookEnableChange(self.UpdateAnimation)
    self:HookMouseUp(self.HandleOnClick)
    self:HookMouseUp(self.PlayInteractSound)
    self:UpdateAnimation()
end

function StepperButtonMixin:PlayInteractSound()
    Sound:PlaySound("UI", SOUNDKIT.SCROLLBAR_STEP)
end




UICGameRange.StepperButton = UIKit.Prefab(function(id, name, children, ...)
    local frame =
        Frame(name)
        :background(TEXTURE_NIL)

    Mixin(frame, StepperButtonMixin)

    return frame
end)


-- Range
--------------------------------

local BACKGROUND                   = ATLAS{ inset = 128, scale = .0425, left = 0 / 1024, top = 768 / 1024, right = 512 / 1024, bottom = 1024 / 1024 }
local BACKGROUND_THUMB             = ATLAS{ inset = 128, scale = 1, left = 0 / 1024, top = 0 / 1024, right = 256 / 1024, bottom = 256 / 1024 }
local BACKGROUND_THUMB_HIGHLIGHTED = ATLAS{ inset = 128, scale = 1, left = 256 / 1024, top = 0 / 1024, right = 512 / 1024, bottom = 256 / 1024 }
local BACKGROUND_THUMB_PUSHED      = ATLAS{ inset = 128, scale = 1, left = 512 / 1024, top = 0 / 1024, right = 768 / 1024, bottom = 256 / 1024 }
local BACKGROUND_THUMB_DISABLED    = ATLAS{ inset = 128, scale = 1, left = 768 / 1024, top = 0 / 1024, right = 1024 / 1024, bottom = 256 / 1024 }
local THUMB_SIZE                   = 16
local STEPPER_BTN_SIZE             = UIKit.Define.Num{ value = 16 }
local RANGE_WIDTH                  = UIKit.Define.Percentage{ value = 100, operator = "-", delta = 28 }
local RANGE_HEIGHT                 = UIKit.Define.Percentage{ value = 100 }
local TRACK_SIZE                   = UIKit.Define.Fill{ delta = 6 }



local RangeSliderMixin = CreateFromMixins(UICSharedMixin.RangeMixin)

local function handleOnEnableChange(self, enabled)
    self.parent.ForwardButton:SetEnabled(enabled)
    self.parent.BackwardButton:SetEnabled(enabled)

    self:UpdateAnimation()
end

function RangeSliderMixin:OnLoad(parent)
    self:InitRange()
    self.parent = parent

    self:RegisterMouseEvents()
    self:HookButtonStateChange(self.UpdateAnimation)
    self:HookEnableChange(handleOnEnableChange)
    self:HookMouseDown(self.PlayInteractSound)
    self:HookMouseUp(self.PlayInteractSound)
    self:UpdateAnimation()
end

function RangeSliderMixin:UpdateAnimation()
    local buttonState = self:GetButtonState()
    local enabled = self:IsEnabled()

    if not enabled then
        self.parent.RangeThumb:background(BACKGROUND_THUMB_DISABLED)
    elseif buttonState == "PUSHED" then
        self.parent.RangeThumb:background(BACKGROUND_THUMB_PUSHED)
    elseif buttonState == "HIGHLIGHTED" then
        self.parent.RangeThumb:background(BACKGROUND_THUMB_HIGHLIGHTED)
    else
        self.parent.RangeThumb:background(BACKGROUND_THUMB)
    end
end

function RangeSliderMixin:PlayInteractSound()
    Sound:PlaySound("UI", SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
end


local RangeMixin = {}

function RangeMixin:GetRange()
    return self.Range
end


UICGameRange.New = UIKit.Prefab(function(id, name, children, ...)
    local frame =
        Frame(name, {
            LinearSlider(name .. ".Range", {
                Frame(name .. ".RangeThumb")
                    :id("RangeThumb", id)
                    :frameLevel(2)
                    :under("LINEAR_SLIDER_THUMB")
                    :size(FILL)
                    :background(BACKGROUND_THUMB),

                Frame(name .. ".RangeTrack")
                    :id("RangeTrack", id)
                    :frameLevel(1)
                    :under("LINEAR_SLIDER_TRACK")
                    :size(TRACK_SIZE)
                    :background(BACKGROUND)
            })
                :id("Range", id)
                :point(UIKit.Enum.Point.Center)
                :size(RANGE_WIDTH, RANGE_HEIGHT)
                :linearSliderThumbPropagateMouse(true)
                :linearSliderThumbSize(THUMB_SIZE, THUMB_SIZE)
                :linearSliderOrientation(UIKit.Enum.Orientation.Horizontal),

            UICGameRange.StepperButton(name .. ".ForwardButton")
                :id("ForwardButton", id)
                :point(UIKit.Enum.Point.Right)
                :size(STEPPER_BTN_SIZE, STEPPER_BTN_SIZE),

            UICGameRange.StepperButton(name .. ".BackwardButton")
                :id("BackwardButton", id)
                :point(UIKit.Enum.Point.Left)
                :size(STEPPER_BTN_SIZE, STEPPER_BTN_SIZE)
        })

    frame.Range = UIKit:GetElementById("Range", id)
    frame.RangeThumb = UIKit:GetElementById("RangeThumb", id)
    frame.RangeTrack = UIKit:GetElementById("RangeTrack", id)
    frame.ForwardButton = UIKit:GetElementById("ForwardButton", id)
    frame.BackwardButton = UIKit:GetElementById("BackwardButton", id)

    Mixin(frame.Range, RangeSliderMixin)
    Mixin(frame, RangeMixin)
    frame.Range:OnLoad(frame)
    frame.ForwardButton:OnLoad(true, frame)
    frame.BackwardButton:OnLoad(false, frame)

    return frame
end)


-- Range With Text
--------------------------------

local TEXT_COLOR      = UIKit.Define.Color_RGBA{ r = GenericEnum.ColorRGB.Yellow.r * 255, g = GenericEnum.ColorRGB.Yellow.g * 255, b = GenericEnum.ColorRGB.Yellow.b * 255, a = 1 }
local RWT_RANGE_WIDTH = UIKit.Define.Percentage{ value = 66 }
local RWT_TEXT_WIDTH  = UIKit.Define.Percentage{ value = 34, operator = "-", delta = 5 }


local RangeWithTextMixin = {}

function RangeWithTextMixin:GetRange()
    return self.Range:GetRange()
end

function RangeWithTextMixin:SetText(text)
    self.Text:SetText(text)
end

function RangeWithTextMixin:GetText()
    return self.Text:GetText()
end


UICGameRange.NewWithText = UIKit.Prefab(function(id, name, children, ...)
    local frame =
        Frame(name, {
            Text(name .. ".Text")
                :id("Text", id)
                :point(UIKit.Enum.Point.Left)
                :size(RWT_TEXT_WIDTH, P_FILL)
                :fontObject(UIFont.UIFontObjectNormal12)
                :textAlignment("RIGHT", "MIDDLE")
                :textColor(TEXT_COLOR),
            UICGameRange.New(name .. ".Range")
                :id("Range", id)
                :point(UIKit.Enum.Point.Right)
                :size(RWT_RANGE_WIDTH, P_FILL)
        })

    frame.Text = UIKit:GetElementById("Text", id)
    frame.Range = UIKit:GetElementById("Range", id)

    Mixin(frame, RangeWithTextMixin)

    return frame
end)
