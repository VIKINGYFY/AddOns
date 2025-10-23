local env                                                                                                                  = select(2, ...)
local MixinUtil                                                                                                            = env.WPM:Import("wpm_modules/mixin-util")
local Path                                                                                                                 = env.WPM:Import("wpm_modules/path")
local Sound                                                                                                                = env.WPM:Import("wpm_modules/sound")
local UIKit                                                                                                                = env.WPM:Import("wpm_modules/ui-kit")
local Frame, Grid, VStack, HStack, ScrollView, ScrollBar, Text, Input, LinearSlider, InteractiveRect, LazyScrollView, List = UIKit.UI.Frame, UIKit.UI.Grid, UIKit.UI.VStack, UIKit.UI.HStack, UIKit.UI.ScrollView, UIKit.UI.ScrollBar, UIKit.UI.Text, UIKit.UI.Input, UIKit.UI.LinearSlider, UIKit.UI.InteractiveRect, UIKit.UI.LazyScrollView, UIKit.UI.List
local UIAnim                                                                                                               = env.WPM:Import("wpm_modules/ui-anim")
local UICSharedMixin                                                                                                       = env.WPM:Import("wpm_modules/uic-sharedmixin")

local Mixin                                                                                                                = MixinUtil.Mixin
local CreateFromMixins                                                                                                     = MixinUtil.CreateFromMixins

local UICGameColorInput                                                                                                    = env.WPM:New("wpm_modules/uic-game/colorInput")




-- Shared
--------------------------------

local PATH = Path.Root .. "/wpm_modules/uic-game/resources/"
local FILL = UIKit.Define.Fill{}




-- Base
--------------------------------

local CONTENT_SIZE                = UIKit.Define.Percentage{ value = 100 }

local TEXTURE_NIL                 = UIKit.Define.Texture_NineSlice{ path = nil, inset = 1, scale = 1 }
local ATLAS                       = UIKit.Define.Texture_Atlas{ path = PATH .. "UICGameColorInput.png", inset = 128, scale = .125 }
local BACKGROUND_FRAME            = ATLAS{ left = 0 / 768, right = 256 / 768, top = 0 / 512, bottom = 256 / 512 }
local BACKGROUND_FRAME_DISABLED   = ATLAS{ left = 256 / 768, right = 512 / 768, top = 0 / 512, bottom = 256 / 512 }
local BACKGROUND_FILL             = ATLAS{ left = 0 / 768, right = 256 / 768, top = 256 / 512, bottom = 512 / 512 }
local BACKGROUND_FILL_HIGHLIGHTED = ATLAS{ left = 256 / 768, right = 512 / 768, top = 256 / 512, bottom = 512 / 512 }
local BACKGROUND_FILL_PUSHED      = ATLAS{ left = 512 / 768, right = 768 / 768, top = 256 / 512, bottom = 512 / 512 }
local ALPHA_ENABLED               = 1
local ALPHA_DISABLED              = .5




local ColorInputMixin = CreateFromMixins(UICSharedMixin.ColorInputMixin)

function ColorInputMixin:OnLoad()
    self:InitColorInput()

    self:RegisterMouseEvents()
    self:HookButtonStateChange(self.UpdateAnimation)
    self:HookEnableChange(self.UpdateAnimation)
    self:HookColorChange(self.OnColorChange)
    self:HookMouseUp(self.OnClick)
    self:HookMouseUp(self.PlayInteractSound)
    self:UpdateAnimation()
end

function ColorInputMixin:OnColorChange(color)
    self.FillTexture:SetColor(color)
end

function ColorInputMixin:UpdateAnimation()
    local buttonState = self:GetButtonState()
    local enabled = self:IsEnabled()

    self:background(enabled and BACKGROUND_FRAME or BACKGROUND_FRAME_DISABLED)
    self.Fill:SetAlpha(enabled and ALPHA_ENABLED or ALPHA_DISABLED)
    if not enabled then return end

    if buttonState == "NORMAL" then
        self.Fill:background(BACKGROUND_FILL)
    elseif buttonState == "HIGHLIGHTED" then
        self.Fill:background(BACKGROUND_FILL_HIGHLIGHTED)
    elseif buttonState == "PUSHED" then
        self.Fill:background(BACKGROUND_FILL_PUSHED)
    end
end

function ColorInputMixin:PlayInteractSound()
    Sound:PlaySound("UI", SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
end



UICGameColorInput.New = UIKit.Prefab(function(id, name, children, ...)
    local frame =
        Frame(name, {
            Frame(name .. ".Fill", {
                unpack(children)
            })
                :id("Fill", id)
                :point(UIKit.Enum.Point.Center)
                :size(CONTENT_SIZE, CONTENT_SIZE)
                :background(TEXTURE_NIL)
        })
        :background(BACKGROUND_FRAME)

    frame.Texture = frame:GetBackground()
    frame.Fill = UIKit:GetElementById("Fill", id)
    frame.FillTexture = frame.Fill:GetBackground()

    Mixin(frame, ColorInputMixin)
    frame:OnLoad(true)

    return frame
end)
