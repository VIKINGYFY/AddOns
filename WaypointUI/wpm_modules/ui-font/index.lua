local env               = select(2, ...)
local UIKit             = env.WPM:Import("wpm_modules/ui-kit")
local React             = env.WPM:Import("wpm_modules/react")

local UIFont_CustomFont = env.WPM:Import("wpm_modules/ui-font/custom-font")
local UIFont_FontUtil   = env.WPM:Import("wpm_modules/ui-font/font-util")
local UIFont            = env.WPM:New("wpm_modules/ui-font")


-- Predefined Fonts
--------------------------------

local UIFontNormal = React.New(UIKit.Define.FontFamily{ path = GameFontNormal:GetFont() })
UIFont.UIFontNormal = UIFontNormal

local UIFontObjectNormal8 = UIFont_FontUtil:CreateFontObject()
UIFontObjectNormal8:SetFont(GameFontNormal:GetFont(), 8, "")
UIFont.UIFontObjectNormal8 = UIFontObjectNormal8

local UIFontObjectNormal10 = UIFont_FontUtil:CreateFontObject()
UIFontObjectNormal10:SetFont(GameFontNormal:GetFont(), 10, "")
UIFont.UIFontObjectNormal10 = UIFontObjectNormal10

local UIFontObjectNormal12 = UIFont_FontUtil:CreateFontObject()
UIFontObjectNormal12:SetFont(GameFontNormal:GetFont(), 12, "")
UIFont.UIFontObjectNormal12 = UIFontObjectNormal12

local UIFontObjectNormal14 = UIFont_FontUtil:CreateFontObject()
UIFontObjectNormal14:SetFont(GameFontNormal:GetFont(), 14, "")
UIFont.UIFontObjectNormal14 = UIFontObjectNormal14

local UIFontObjectNormal16 = UIFont_FontUtil:CreateFontObject()
UIFontObjectNormal16:SetFont(GameFontNormal:GetFont(), 16, "")
UIFont.UIFontObjectNormal16 = UIFontObjectNormal16

local UIFontObjectNormal18 = UIFont_FontUtil:CreateFontObject()
UIFontObjectNormal18:SetFont(GameFontNormal:GetFont(), 18, "")
UIFont.UIFontObjectNormal18 = UIFontObjectNormal18


-- API
--------------------------------

UIFont.CustomFont = UIFont_CustomFont
