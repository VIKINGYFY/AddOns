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

local UICGameCheckbox                                                                                                      = env.WPM:New("wpm_modules/uic-game/checkbox")





local PATH                           = Path.Root .. "/wpm_modules/uic-game/resources/"
local ATLAS                          = UIKit.Define.Texture_Atlas{ path = PATH .. "UICGameCheckbox.png", inset = 75, scale = 1 }
local BACKGROUND                     = ATLAS{ left = 0 / 768, top = 0 / 512, right = 256 / 768, bottom = 256 / 512 }
local BACKGROUND_HIGHLIGHTED         = ATLAS{ left = 256 / 768, top = 0 / 512, right = 512 / 768, bottom = 256 / 512 }
local BACKGROUND_DISABLED            = ATLAS{ left = 512 / 768, top = 0 / 512, right = 768 / 768, bottom = 256 / 512 }
local BACKGROUND_CHECKED             = ATLAS{ left = 0 / 768, top = 256 / 512, right = 256 / 768, bottom = 512 / 512 }
local BACKGROUND_CHECKED_HIGHLIGHTED = ATLAS{ left = 256 / 768, top = 256 / 512, right = 512 / 768, bottom = 512 / 512 }
local BACKGROUND_CHECKED_DISABLED    = ATLAS{ left = 512 / 768, top = 256 / 512, right = 768 / 768, bottom = 512 / 512 }





local CheckboxMixin = CreateFromMixins(UICSharedMixin.CheckboxMixin)

function CheckboxMixin:OnLoad()
    self:InitCheckbox()

    self:RegisterMouseEvents()

    self:HookCheck(self.UpdateCheck)
    self:HookMouseUp(self.Toggle)
    self:HookEnableChange(self.UpdateAnimation)
    self:HookButtonStateChange(self.UpdateAnimation)
    self:HookMouseUp(self.PlayInteractSound)

    self:UpdateAnimation()
    self:UpdateCheck()
end

function CheckboxMixin:UpdateAnimation()
    local chedked = self:GetChecked()
    local highlighted = self:IsHighlighted()
    local enabled = self:IsEnabled()

    if chedked then
        if not enabled then
            self:background(BACKGROUND_CHECKED_DISABLED)
        elseif highlighted then
            self:background(BACKGROUND_CHECKED_HIGHLIGHTED)
        else
            self:background(BACKGROUND_CHECKED)
        end
    else
        if not enabled then
            self:background(BACKGROUND_DISABLED)
        elseif highlighted then
            self:background(BACKGROUND_HIGHLIGHTED)
        else
            self:background(BACKGROUND)
        end
    end
end

function CheckboxMixin:UpdateCheck()
    self:UpdateAnimation()
end

function CheckboxMixin:PlayInteractSound()
    local checked = self:GetChecked()
    if checked then
        Sound:PlaySound("UI", SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    else
        Sound:PlaySound("UI", SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
    end
end



UICGameCheckbox.New = UIKit.Prefab(function(id, name, children, ...)
    local frame =
        Frame(name)
        :background(BACKGROUND)

    Mixin(frame, CheckboxMixin)
    frame:OnLoad()

    return frame
end)
