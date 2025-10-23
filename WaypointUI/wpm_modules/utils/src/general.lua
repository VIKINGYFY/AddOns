local env = select(2, ...)
local Utils_General = env.WPM:New("wpm_modules/utils/general")

function Utils_General:GetMouseDelta(originX, originY)
    assert(originX, "`GetMouseDelta`: expected originX, got " .. type(originX))
    assert(originY, "`GetMouseDelta`: expected originY, got " .. type(originY))

    local mouseX, mouseY = GetCursorPosition()
    local frameX = originX
    local frameY = originY

    local deltaX = (mouseX - frameX)
    local deltaY = (frameY - mouseY)     -- Invert Y axis because WoW's coordinate system has Y increasing upwards.

    return deltaX, deltaY
end
