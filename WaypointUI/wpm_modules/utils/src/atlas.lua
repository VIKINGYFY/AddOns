local env = select(2, ...)

local assert = assert
local CreateAtlasMarkup = CreateAtlasMarkup

local Utils_Atlas = env.WPM:New("wpm_modules/utils/atlas")

-- Creates an inline icon.
---@param path string
---@param height number
---@param width number
---@param horizontalOffset? number
---@param verticalOffset? number
---@param textureType? string: "Atlas" or "Texture"
function Utils_Atlas:InlineIcon(path, height, width, horizontalOffset, verticalOffset, textureType)
    assert(path, "`InlineIcon`: expected string `path`, got " .. type(path))
    assert(height, "`InlineIcon`: expected number `height`, got " .. type(height))
    assert(width, "`InlineIcon`: expected number `width`, got " .. type(width))

    horizontalOffset = horizontalOffset or 0
    verticalOffset   = verticalOffset or 0

    if textureType == "Atlas" then
        return CreateAtlasMarkup(path, width, height, horizontalOffset, verticalOffset)
    else
        return "|T" .. path .. ":" .. height .. ":" .. width .. ":" .. horizontalOffset .. ":" .. verticalOffset .. "|t"
    end
end

-- Offsets an inline icon.
---@param iconString string
---@param newXOffset number
---@param newYOffset number
function Utils_Atlas:IconOffset(iconString, newXOffset, newYOffset)
    return iconString:gsub(":(%d+):(%d+)|a", ":" .. newXOffset .. ":" .. newYOffset .. "|a")
end
