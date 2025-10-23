local env                   = select(2, ...)
local UIKit_UI_Parser    = env.WPM:Import("wpm_modules/ui-kit/ui/parser")

local UIKit_UI           = env.WPM:New("wpm_modules/ui-kit/ui")

UIKit_UI.Frame           = function(name, children) return UIKit_UI_Parser:CreateFrameFromType("Frame", name, children) end
UIKit_UI.Grid            = function(name, children) return UIKit_UI_Parser:CreateFrameFromType("Grid", name, children) end
UIKit_UI.HStack          = function(name, children) return UIKit_UI_Parser:CreateFrameFromType("HStack", name, children) end
UIKit_UI.VStack          = function(name, children) return UIKit_UI_Parser:CreateFrameFromType("VStack", name, children) end
UIKit_UI.Text            = function(name, children) return UIKit_UI_Parser:CreateFrameFromType("Text", name, children) end
UIKit_UI.ScrollView      = function(name, children) return UIKit_UI_Parser:CreateFrameFromType("ScrollView", name, children) end
UIKit_UI.ScrollBar       = function(name, children) return UIKit_UI_Parser:CreateFrameFromType("ScrollBar", name, children) end
UIKit_UI.Input           = function(name, children) return UIKit_UI_Parser:CreateFrameFromType("Input", name, children) end
UIKit_UI.LinearSlider    = function(name, children) return UIKit_UI_Parser:CreateFrameFromType("LinearSlider", name, children) end
UIKit_UI.InteractiveRect = function(name, children) return UIKit_UI_Parser:CreateFrameFromType("InteractiveRect", name, children) end
UIKit_UI.LazyScrollView  = function(name, children) return UIKit_UI_Parser:CreateFrameFromType("LazyScrollView", name, children) end
UIKit_UI.List            = function(name, children) return UIKit_UI_Parser:CreateFrameFromType("List", name, children) end
