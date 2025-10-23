local env                   = select(2, ...)
local UICGameButton         = env.WPM:Import("wpm_modules/uic-game/button")
local UICGameCheckbox       = env.WPM:Import("wpm_modules/uic-game/checkbox")
local UICGameRange          = env.WPM:Import("wpm_modules/uic-game/range")
local UICGameScrollBar      = env.WPM:Import("wpm_modules/uic-game/scrollBar")
local UICGameInput          = env.WPM:Import("wpm_modules/uic-game/input")
local UICGameSelectionMenu  = env.WPM:Import("wpm_modules/uic-game/selectionMenu")
local UICGameColorInput     = env.WPM:Import("wpm_modules/uic-game/colorInput")
local UICGame               = env.WPM:New("wpm_modules/uic-game")

UICGame.ButtonRed           = UICGameButton.RedBase
UICGame.ButtonGrey          = UICGameButton.GreyBase
UICGame.ButtonRedWithText   = UICGameButton.RedWithText
UICGame.ButtonGreyWithText  = UICGameButton.GreyWithText
UICGame.ButtonSelectionMenu = UICGameButton.SelectionMenu
UICGame.Checkbox            = UICGameCheckbox.New
UICGame.ScrollBar           = UICGameScrollBar.New
UICGame.Input               = UICGameInput.New
UICGame.Range               = UICGameRange.New
UICGame.RangeWithText       = UICGameRange.NewWithText
UICGame.SelectionMenu       = UICGameSelectionMenu.New
UICGame.ColorInput          = UICGameColorInput.New


-- Demo
--------------------------------

--[[
    local UIKit = env.WPM:Import("wpm_modules/ui-kit")
    local Frame, Grid, VStack, HStack, ScrollView, ScrollBar, Text, Input, LinearSlider, InteractiveRect, LazyScrollView, List = UIKit.UI.Frame, UIKit.UI.Grid, UIKit.UI.VStack, UIKit.UI.HStack, UIKit.UI.ScrollView, UIKit.UI.ScrollBar, UIKit.UI.Text, UIKit.UI.Input, UIKit.UI.LinearSlider, UIKit.UI.InteractiveRect, UIKit.UI.LazyScrollView, UIKit.UI.List

    VStack{
        -- Red Button with Text
        UICGame.ButtonRedWithText()
            :id("RedWithText")
            :size(UIKit.Define.Num{ value = 175 }, UIKit.Define.Num{ value = 32 }),

        -- Grey Button with Text
        UICGame.ButtonGreyWithText()
            :id("GreyWithText")
            :size(UIKit.Define.Num{ value = 175 }, UIKit.Define.Num{ value = 32 }),

        -- Selection Menu Button
        UICGame.ButtonSelectionMenu()
            :id("SelectionMenuButton")
            :size(UIKit.Define.Num{ value = 175 }, UIKit.Define.Num{ value = 32 }),

        -- Checkbox
        UICGame.Checkbox()
            :id("Checkbox")
            :size(UIKit.Define.Num{ value = 22 }, UIKit.Define.Num{ value = 22 }),

        -- Input
        UICGame.Input()
            :id("Input")
            :size(UIKit.Define.Num{ value = 175 }, UIKit.Define.Fit{ delta = 17 }),

        -- Range
        UICGame.Range()
            :id("Range")
            :size(UIKit.Define.Num{ value = 175 }, UIKit.Define.Num{ value = 15 }),

        -- Range With Text
        UICGame.RangeWithText()
            :id("RangeWithText")
            :size(UIKit.Define.Num{ value = 175 }, UIKit.Define.Num{ value = 15 }),

        -- Color Input
        UICGame.ColorInput()
            :id("ColorInput")
            :size(UIKit.Define.Num{ value = 175 }, UIKit.Define.Num{ value = 32 })
    }
        :point(UIKit.Enum.Point.Center)
        :parent(UIParent)
        :size(UIKit.Define.Percentage{ value = 50 }, UIKit.Define.Percentage{ value = 50 })
        :layoutDirection(UIKit.Enum.Direction.Vertical)
        :layoutSpacing(UIKit.Define.Num{ value = 5 })
        :_Render()


    ScrollView{
        Frame{

        }
            :point(UIKit.Enum.Point.Top)
            :size(UIKit.Define.Percentage{ value = 100 }, UIKit.Define.Num{ value = 100 })
    }
        :id("ScrollView")
        :point(UIKit.Enum.Point.Center)
        :size(UIKit.Define.Num{ value = 375 }, UIKit.Define.Num{ value = 250 })
        :scrollDirection(UIKit.Enum.Direction.Vertical)
        :scrollViewContentWidth(UIKit.Define.Percentage{ value = 100 })
        :scrollViewContentHeight(UIKit.Define.Num{ value = 575 })
        :scrollInterpolation(5)
        :_Render()

    UICGameScrollBar.New{

    }
        :id("ScrollBar")
        :scrollBarTarget("ScrollView")
        :point(UIKit.Enum.Point.Right)
        :size(UIKit.Define.Num{ value = 7 }, UIKit.Define.Num{ value = 575 })
        :scrollDirection(UIKit.Enum.Direction.Vertical)
        :_Render()

    -- Set Values
    E_RedWithText = UIKit:GetElementById("RedWithText")
    E_RedWithText:SetText("Button")

    E_GreyWithText = UIKit:GetElementById("GreyWithText")
    E_GreyWithText:SetText("Button")

    E_Input = UIKit:GetElementById("Input")

    E_Checkbox = UIKit:GetElementById("Checkbox")
    E_Checkbox:SetChecked(true)

    E_Range = UIKit:GetElementById("Range")
    E_Range:GetRange():SetMinMaxValues(0, 1)
    E_Range:GetRange():SetValue(.5)

    E_RangeWithText = UIKit:GetElementById("RangeWithText")
    E_RangeWithText:GetRange():SetMinMaxValues(0, 1)
    E_RangeWithText:GetRange():SetValue(.5)
    E_RangeWithText:SetText("Range")

    E_ColorInput = UIKit:GetElementById("ColorInput")

    E_ScrollView = UIKit:GetElementById("ScrollView")
    E_ScrollBar = UIKit:GetElementById("ScrollBar")

    -- Create a dropdown menu
    --      Try: MyContextMenu:Load(initialIndex, data, onValueChange, onElementUpdateHandler, point, relativeTo, relativePoint, x, y)

    Data = {}
    for i = 1, 500 do
        table.insert(Data, "entry" .. i)
    end


    E_ContextMenu = UICGameSelectionMenu.New("MyContextMenu", {

        })
        :parent(UIParent)
        :frameStrata(UIKit.Enum.FrameStrata.FullscreenDialog)
        :size(UIKit.Define.Num{ value = 175 }, UIKit.Define.Fit{ delta = 7 })
        :_Render()

    -- Dropdown Button to open menu

    local value = 1

    E_SelectionMenuButton = UIKit:GetElementById("SelectionMenuButton")
    E_SelectionMenuButton:SetSelectionMenu(E_ContextMenu)
    E_SelectionMenuButton:HookValueChanged(function(_, val) value = val; print(value) end)
    E_SelectionMenuButton:SetData(Data)
--]]
