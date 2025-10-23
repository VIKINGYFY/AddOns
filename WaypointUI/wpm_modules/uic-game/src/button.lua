local env                                                                                                                  = select(2, ...)
local MixinUtil                                                                                                            = env.WPM:Import("wpm_modules/mixin-util")
local Path                                                                                                                 = env.WPM:Import("wpm_modules/path")
local Sound                                                                                                                = env.WPM:Import("wpm_modules/sound")
local UIFont                                                                                                               = env.WPM:Import("wpm_modules/ui-font")
local UIKit                                                                                                                = env.WPM:Import("wpm_modules/ui-kit")
local Frame, Grid, VStack, HStack, ScrollView, ScrollBar, Text, Input, LinearSlider, InteractiveRect, LazyScrollView, List = UIKit.UI.Frame, UIKit.UI.Grid, UIKit.UI.VStack, UIKit.UI.HStack, UIKit.UI.ScrollView, UIKit.UI.ScrollBar, UIKit.UI.Text, UIKit.UI.Input, UIKit.UI.LinearSlider, UIKit.UI.InteractiveRect, UIKit.UI.LazyScrollView, UIKit.UI.List
local UIAnim                                                                                                               = env.WPM:Import("wpm_modules/ui-anim")
local GenericEnum                                                                                                          = env.WPM:Import("wpm_modules/generic-enum")
local UICSharedMixin                                                                                                       = env.WPM:Import("wpm_modules/uic-sharedmixin")

local Mixin                                                                                                                = MixinUtil.Mixin
local CreateFromMixins                                                                                                     = MixinUtil.CreateFromMixins

local UICGameButton                                                                                                        = env.WPM:New("wpm_modules/uic-game/button")




-- Shared
--------------------------------

local PATH        = Path.Root .. "/wpm_modules/uic-game/resources/"
local FILL        = UIKit.Define.Fill{}
local ATLAS       = UIKit.Define.Texture_Atlas{ path = PATH .. "UICGameButton.png", inset = 75, scale = .125 }
local TEXTURE_NIL = UIKit.Define.Texture_NineSlice{ path = nil, inset = 1, scale = 1 }




-- Base
--------------------------------

local CONTENT_SIZE                     = UIKit.Define.Percentage{ value = 100, operator = "-", delta = 19 }

local BASE_BACKGROUND_RED              = ATLAS{ left = 0 / 2048, top = 0 / 768, right = 512 / 2048, bottom = 256 / 768 }
local BASE_BACKGROUND_RED_HIGHLIGHTED  = ATLAS{ left = 512 / 2048, top = 0 / 768, right = 1024 / 2048, bottom = 256 / 768 }
local BASE_BACKGROUND_RED_PUSHED       = ATLAS{ left = 1024 / 2048, top = 0 / 768, right = 1536 / 2048, bottom = 256 / 768 }
local BASE_BACKGROUND_RED_DISABLED     = ATLAS{ left = 1536 / 2048, top = 0 / 768, right = 2048 / 2048, bottom = 256 / 768 }
local BASE_BACKGROUND_GREY             = ATLAS{ left = 0 / 2048, top = 256 / 768, right = 512 / 2048, bottom = 512 / 768 }
local BASE_BACKGROUND_GREY_HIGHLIGHTED = ATLAS{ left = 512 / 2048, top = 256 / 768, right = 1024 / 2048, bottom = 512 / 768 }
local BASE_BACKGROUND_GREY_PUSHED      = ATLAS{ left = 1024 / 2048, top = 256 / 768, right = 1536 / 2048, bottom = 512 / 768 }
local BASE_BACKGROUND_GREY_DISABLED    = ATLAS{ left = 1536 / 2048, top = 256 / 768, right = 2048 / 2048, bottom = 512 / 768 }
local CONTENT_Y                        = 0
local CONTENT_Y_HIGHLIGHTED            = 0
local CONTENT_Y_PRESSED                = -1
local ALPHA_ENABLED                    = 1
local ALPHA_DISABLED                   = .5



local ButtonMixin = CreateFromMixins(UICSharedMixin.ButtonMixin)

function ButtonMixin:OnLoad(isRed)
    self:InitButton()
    self.isRed = isRed

    self:RegisterMouseEvents()
    self:HookButtonStateChange(self.UpdateAnimation)
    self:HookEnableChange(self.UpdateAnimation)
    self:HookMouseUp(self.PlayInteractSound)
    self:UpdateAnimation()
end

function ButtonMixin:UpdateAnimation()
    local enabled = self:IsEnabled()
    local buttonState = self:GetButtonState()

    if not enabled then
        self.Texture:background(self.isRed and BASE_BACKGROUND_RED_DISABLED or BASE_BACKGROUND_GREY_DISABLED)
        self.Content:ClearAllPoints()
        self.Content:SetPoint("CENTER", self, "CENTER", 0, CONTENT_Y)
    elseif buttonState == "NORMAL" then
        self.Texture:background(self.isRed and BASE_BACKGROUND_RED or BASE_BACKGROUND_GREY)
        self.Content:ClearAllPoints()
        self.Content:SetPoint("CENTER", self, "CENTER", 0, CONTENT_Y)
    elseif buttonState == "HIGHLIGHTED" then
        self.Texture:background(self.isRed and BASE_BACKGROUND_RED_HIGHLIGHTED or BASE_BACKGROUND_GREY_HIGHLIGHTED)
        self.Content:ClearAllPoints()
        self.Content:SetPoint("CENTER", self, "CENTER", -CONTENT_Y_HIGHLIGHTED, CONTENT_Y_HIGHLIGHTED)
    elseif buttonState == "PUSHED" then
        self.Texture:background(self.isRed and BASE_BACKGROUND_RED_PUSHED or BASE_BACKGROUND_GREY_PUSHED)
        self.Content:ClearAllPoints()
        self.Content:SetPoint("CENTER", self, "CENTER", -CONTENT_Y_PRESSED, CONTENT_Y_PRESSED)
    end

    self.Content:SetAlpha(enabled and ALPHA_ENABLED or ALPHA_DISABLED)
end

function ButtonMixin:PlayInteractSound()
    Sound:PlaySound("UI", SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
end

UICGameButton.RedBase = UIKit.Prefab(function(id, name, children, ...)
    local frame =
        Frame(name, {
            Frame(name .. ".Content", {
                unpack(children)
            })
                :id("Content", id)
                :point(UIKit.Enum.Point.Center)
                :size(CONTENT_SIZE, CONTENT_SIZE)
        })
        :background(TEXTURE_NIL)

    frame.Texture = frame:GetBackground()
    frame.Content = UIKit:GetElementById("Content", id)

    Mixin(frame, ButtonMixin)
    frame:OnLoad(true)

    return frame
end)

UICGameButton.GreyBase = UIKit.Prefab(function(id, name, children, ...)
    local frame =
        Frame(name, {
            Frame(name .. ".Content", {
                unpack(children)
            })
                :id("Content", id)
                :point(UIKit.Enum.Point.Center)
                :size(CONTENT_SIZE, CONTENT_SIZE)
        })
        :background(TEXTURE_NIL)

    frame.Texture = frame:GetBackground()
    frame.Content = UIKit:GetElementById("Content", id)

    Mixin(frame, ButtonMixin)
    frame:OnLoad(false)

    return frame
end)




-- Text
--------------------------------

local VARIANT_RED_TEXT_COLOR              = UIKit.Define.Color_RGBA{ r = GenericEnum.ColorRGB.Yellow.r * 255, g = GenericEnum.ColorRGB.Yellow.g * 255, b = GenericEnum.ColorRGB.Yellow.b * 255, a = 1 }
local VARIANT_RED_TEXT_COLOR_HIGHLIGHTED  = UIKit.Define.Color_RGBA{ r = 255, g = 255, b = 255, a = 1 }
local VARIANT_GRAY_TEXT_COLOR             = UIKit.Define.Color_RGBA{ r = 216, g = 216, b = 216, a = 1 }
local VARIANT_GRAY_TEXT_COLOR_HIGHLIGHTED = UIKit.Define.Color_RGBA{ r = 255, g = 255, b = 255, a = 1 }



local ButtonTextMixin = {}

function ButtonTextMixin:ButtonText_OnLoad()
    self:HookButtonStateChange(self.ButtonText_UpdateAnimation)
end

function ButtonTextMixin:ButtonText_UpdateAnimation()
    local isRed = self.isRed
    local enabled = self:IsEnabled()
    local buttonState = self:GetButtonState()

    if not enabled then
        self.Text:textColor(isRed and VARIANT_RED_TEXT_COLOR or VARIANT_GRAY_TEXT_COLOR)
    elseif buttonState == "NORMAL" then
        self.Text:textColor(isRed and VARIANT_RED_TEXT_COLOR or VARIANT_GRAY_TEXT_COLOR)
    elseif buttonState == "HIGHLIGHTED" then
        self.Text:textColor(isRed and VARIANT_RED_TEXT_COLOR_HIGHLIGHTED or VARIANT_GRAY_TEXT_COLOR_HIGHLIGHTED)
    elseif buttonState == "PUSHED" then
        self.Text:textColor(isRed and VARIANT_RED_TEXT_COLOR_HIGHLIGHTED or VARIANT_GRAY_TEXT_COLOR_HIGHLIGHTED)
    end

end

function ButtonTextMixin:SetText(text)
    self.Text:SetText(text)
end

function ButtonTextMixin:GetText()
    return self.Text:GetText()
end

UICGameButton.RedWithText = UIKit.Prefab(function(id, name, children, ...)
    local frame =
        UICGameButton.RedBase(name, {
            Text(name .. ".Text", {

            })
                :textColor(VARIANT_RED_TEXT_COLOR)
                :fontObject(UIFont.UIFontObjectNormal12)
                :id("Text", id)
                :size(FILL),

            unpack(children)
        })
        :id("Button", id)

    frame.Text = UIKit:GetElementById("Text", id)

    Mixin(frame, ButtonTextMixin)
    frame:ButtonText_OnLoad()

    return frame
end)

UICGameButton.GreyWithText = UIKit.Prefab(function(id, name, children, ...)
    local frame =
        UICGameButton.GreyBase(name, {
            Text(name .. ".Text", {

            })
                :fontObject(UIFont.UIFontObjectNormal12)
                :id("Text", id)
                :size(FILL),

            unpack(children)
        })

    frame.Text = UIKit:GetElementById("Text", id)

    Mixin(frame, ButtonTextMixin)
    frame:ButtonText_OnLoad()

    return frame
end)



-- Selection Menu
--------------------------------

local SM_ARROW_BACKGROUND = ATLAS{ left = 0 / 1536, top = 512 / 768, right = 256 / 1536, bottom = 768 / 768 }
local SM_ARROW_SIZE       = UIKit.Define.Num{ value = 12 }


local ButtonSelectionMenuMixin = CreateFromMixins(UICSharedMixin.SelectionMenuRemote)

function ButtonSelectionMenuMixin:OnLoad()
    self:InitSelectionMenuRemote()
end


UICGameButton.SelectionMenu = UIKit.Prefab(function(id, name, children, ...)
    local frame =
        UICGameButton.GreyWithText(name, {
            Frame(name .. ".Arrow")
                :id("Arrow", id)
                :point(UIKit.Enum.Point.Right)
                :background(SM_ARROW_BACKGROUND)
                :size(SM_ARROW_SIZE, SM_ARROW_SIZE),

            unpack(children)
        })

    frame.Text:textAlignment("LEFT", "MIDDLE")
    frame.Arrow = UIKit:GetElementById("Arrow", id)

    Mixin(frame, ButtonSelectionMenuMixin)
    frame:OnLoad()

    return frame
end)
