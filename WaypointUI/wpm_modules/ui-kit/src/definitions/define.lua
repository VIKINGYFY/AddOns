local env             = select(2, ...)
local struct          = env.WPM:Import("wpm_modules/struct").New
local UIKit_Define = env.WPM:New("wpm_modules/ui-kit/define")

do -- Values
    UIKit_Define.Num = struct{
        value = nil
    }

    UIKit_Define.Percentage = struct{
        value    = nil,
        operator = nil,
        delta    = nil
    }

    UIKit_Define.Fit = struct{
        delta = nil
    }

    UIKit_Define.Fill = struct{
        -- Apply padding to all sides
        delta  = nil,

        -- or, apply padding to each sides
        left   = nil,
        right  = nil,
        top    = nil,
        bottom = nil
    }
end

do -- Color
    UIKit_Define.Color_RGBA = struct{
        r = 0,
        g = 0,
        b = 0,
        a = 1
    }

    UIKit_Define.Color_HEX = struct{
        hex = "ffffffff"
    }
end

do -- Texture
    UIKit_Define.Texture = struct{
        path = nil
    }

    UIKit_Define.Texture_NineSlice = struct{
        path  = nil,
        inset = nil,
        scale = nil,
        sliceMode = nil
    }

    UIKit_Define.Texture_Backdrop = struct{
        bgFile   = nil,
        edgeFile = nil,
        tile     = nil,
        tileSize = nil,
        edgeSize = nil,
        insets   = nil
    }

    UIKit_Define.Texture_Atlas = struct{
        -- Atlas info
        path   = nil,
        inset  = nil,
        scale  = nil,
        sliceMode = nil,

        -- Texture info (Recommended to declare as a substruct)
        left   = nil,
        top    = nil,
        right  = nil,
        bottom = nil
    }
end

do -- Font
    UIKit_Define.FontFamily = struct{
        path = nil
    }

    UIKit_Define.FontFlags = struct{
        flags = nil
    }
end
