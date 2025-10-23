local env = select(2, ...)

local Utils_Color = env.WPM:New("wpm_modules/utils/color")

--Removes color codes from the given string.
---@param text string
---@return string
function Utils_Color:StripColorCodes(text)
    if text ~= nil then
        local new = string.gsub(text, "|cff%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
        new = string.gsub(new, "|cn.-:", "")

        return new
    else
        return ""
    end
end

--Parses a RGBA value (range 0-255) to (range 0-1)
---@param rgba table
---@return table
function Utils_Color:ParseRGBA(rgba)
    rgba.r = math.min(rgba.r / 255, 1)
    rgba.g = math.min(rgba.g / 255, 1)
    rgba.b = math.min(rgba.b / 255, 1)
    rgba.a = math.min(rgba.a or 1, 1)
    return rgba
end

--Parses a HEX value to (range 0-1)
---@param hex string
---@return table
function Utils_Color:ParseHex(hex)
    assert(type(hex) == "string", "`hex` must be a string")
    hex = hex:gsub("^#?%s*", "")
    if #hex == 6 then hex = hex .. "FF" end
    return {
        r = tonumber(hex:sub(1, 2), 16) / 255,
        g = tonumber(hex:sub(3, 4), 16) / 255,
        b = tonumber(hex:sub(5, 6), 16) / 255,
        a = tonumber(hex:sub(7, 8), 16) / 255
    }
end
