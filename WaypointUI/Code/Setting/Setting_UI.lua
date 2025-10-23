local env                                                                                                                  = select(2, ...)
local Path                                                                                                                 = env.WPM:Import("wpm_modules/path")
local UIKit                                                                                                                = env.WPM:Import("wpm_modules/ui-kit")
local Frame, Grid, VStack, HStack, ScrollView, ScrollBar, Text, Input, LinearSlider, InteractiveRect, LazyScrollView, List = UIKit.UI.Frame, UIKit.UI.Grid, UIKit.UI.VStack, UIKit.UI.HStack, UIKit.UI.ScrollView, UIKit.UI.ScrollBar, UIKit.UI.Text, UIKit.UI.Input, UIKit.UI.LinearSlider, UIKit.UI.InteractiveRect, UIKit.UI.LazyScrollView, UIKit.UI.List
local UIAnim                                                                                                               = env.WPM:Import("wpm_modules/ui-anim")

local UICGame                                                                                                              = env.WPM:Import("wpm_modules/uic-game")



-- Frame
--------------------------------

local TEXTURE_DIVIDER = UIKit.Define.Texture{ path = Path.Root .. "/Art/Shape/Square.png" }


Frame("WUISettingFrame", {
    Frame("WUISettingFrame.Sidebar", {
        Frame("WUISettingFrame.Sidebar.Divider")
            :id("WUISettingFrame.Sidebar.Divider")
            :point(UIKit.Enum.Point.Right)
            :size(UIKit.Define.Num{ value = 2 }, UIKit.Define.Percentage{ value = 100 })
            :background(TEXTURE_DIVIDER)
            :backgroundColor(UIKit.Define.Color_RGBA{ r = 142.5, g = 142.5, b = 142.5, a = .2375 }),

        Frame("WUISettingFrame.Sidebar.Content", {
            VStack("WUISettingFrame.Sidebar.Tab")
                :id("WUISettingFrame.Sidebar.Tab")
                :point(UIKit.Enum.Point.Top)
                :size(UIKit.Define.Percentage{ value = 100 }, UIKit.Define.Percentage{ value = 100, operator = "-", delta = 75 })
                :layoutSpacing(UIKit.Define.Num{ value = 3 }),

            VStack("WUISettingFrame.Sidebar.Footer")
                :id("WUISettingFrame.Sidebar.Footer")
                :point(UIKit.Enum.Point.Bottom)
                :size(UIKit.Define.Percentage{ value = 100 }, UIKit.Define.Num{ value = 75 })
                :layoutAlignmentV(UIKit.Enum.Direction.Trailing)
                :layoutSpacing(UIKit.Define.Num{ value = 3 })
        })
            :id("WUISettingFrame.Sidebar.Content")
            :size(UIKit.Define.Fill{ delta = 45 })
    })
        :id("WUISettingFrame.Sidebar")
        :point(UIKit.Enum.Point.Left)
        :size(UIKit.Define.Num{ value = 212 }, UIKit.Define.Percentage{ value = 100 }),

    Frame("WUISettingFrame.Content", {
        Frame("WUISettingFrame.Content.Container")
            :id("WUISettingFrame.Content.Container")
            :point(UIKit.Enum.Point.Center)
            :size(UIKit.Define.Percentage{ value = 100, operator = "-", delta = 35 }, UIKit.Define.Percentage{ value = 100 })
    })
        :id("WUISettingFrame.Content")
        :point(UIKit.Enum.Point.Right)
        :size(UIKit.Define.Percentage{ value = 100, operator = "-", delta = 212 }, UIKit.Define.Percentage{ value = 100 })
})
    :id("WUISettingFrame")

WUISettingFrame = UIKit:GetElementById("WUISettingFrame")
WUISettingFrame.Sidebar = UIKit:GetElementById("WUISettingFrame.Sidebar")
WUISettingFrame.Sidebar.Content = UIKit:GetElementById("WUISettingFrame.Sidebar.Content")
WUISettingFrame.Sidebar.Image = UIKit:GetElementById("WUISettingFrame.Sidebar.Image")
WUISettingFrame.Sidebar.Tab = UIKit:GetElementById("WUISettingFrame.Sidebar.Tab")
WUISettingFrame.Sidebar.Footer = UIKit:GetElementById("WUISettingFrame.Sidebar.Footer")
WUISettingFrame.Content = UIKit:GetElementById("WUISettingFrame.Content")
WUISettingFrame.Content.Container = UIKit:GetElementById("WUISettingFrame.Content.Container")



-- Selection Menu
--------------------------------

WUISettingFrame.SelectionMenu = UICGame.SelectionMenu("WUISelectionMenu")
    :parent(WUISettingFrame)
    :frameStrata(UIKit.Enum.FrameStrata.FullscreenDialog)
    :size(UIKit.Define.Num{ value = 175 }, UIKit.Define.Fit{})
    :_Render()
