local env          = select(2, ...)
local MixinUtil    = env.WPM:Import("wpm_modules/mixin-util")
local LinearSlider = env.WPM:Import("wpm_modules/ui-kit/primitives/linearSlider")
local math         = math

local Mixin        = MixinUtil.Mixin

local ScrollBar    = env.WPM:New("wpm_modules/ui-kit/primitives/scrollBar")





local ScrollBarMixin = {}
do
    -- Update
    --------------------------------

    function ScrollBarMixin:SetThumbVisible(visible)
        if self.__Thumb then
            self.__Thumb:SetShown(visible)
        end
        if self.__ThumbAnchor then
            self.__ThumbAnchor:SetShown(visible)
        end
    end

    function ScrollBarMixin:SetThumbSize()
        local target = self.__target
        local isVertical = self.__isVertical
        if not target or isVertical == nil then return end

        local contentSize = isVertical and (target:GetContentHeight() or 0) or (target:GetContentWidth() or 0)
        local frameSize = isVertical and (target:GetHeight() or 0) or (target:GetWidth() or 0)
        local trackSize = isVertical and (self:GetHeight() or 0) or (self:GetWidth() or 0)

        if contentSize <= 0 or frameSize <= 0 or trackSize <= 0 then
            self:SetThumbVisible(false)
            return
        end

        if contentSize <= frameSize then
            self:SetThumbVisible(false)
            return
        end

        local ratio = frameSize / contentSize
        if ratio <= 0 then
            self:SetThumbVisible(false)
            return
        end

        ratio = math.min(ratio, 1)
        local size = trackSize * ratio

        if isVertical then
            if self.__ThumbAnchor:GetWidth() ~= self:GetWidth() then
                self.__ThumbAnchor:SetWidth(self:GetWidth())
            end
            self.__ThumbAnchor:SetHeight(size)
        else
            if self.__ThumbAnchor:GetHeight() ~= self:GetHeight() then
                self.__ThumbAnchor:SetHeight(self:GetHeight())
            end
            self.__ThumbAnchor:SetWidth(size)
        end

        self:SetThumbVisible(true)
    end

    function ScrollBarMixin:SyncValue()
        local target = self.__target
        local isVertical = self.__isVertical
        if not target or isVertical == nil then return end

        local contentSize
        local frameSize
        local scroll

        local scrollFrame = target.GetScrollFrame and target:GetScrollFrame()

        if isVertical then
            contentSize = target:GetContentHeight() or 0
            frameSize = target:GetHeight() or 0
            if scrollFrame and scrollFrame.GetVerticalScroll then
                scroll = scrollFrame:GetVerticalScroll() or 0
            else
                scroll = target:GetVerticalScroll() or 0
            end
        else
            contentSize = target:GetContentWidth() or 0
            frameSize = target:GetWidth() or 0
            if scrollFrame and scrollFrame.GetHorizontalScroll then
                scroll = scrollFrame:GetHorizontalScroll() or 0
            else
                scroll = target:GetHorizontalScroll() or 0
            end
        end

        local range = contentSize - frameSize
        local offset = 0

        if range and range > 0 then
            offset = scroll / range

            if offset ~= offset or offset == math.huge or offset == -math.huge then
                offset = 0
            elseif offset < 0 then
                offset = 0
            elseif offset > 1 then
                offset = 1
            end
        end

        self:SetValue(offset)
        self:SetThumbSize()
    end

    function ScrollBarMixin:SetTargetScroll()
        local target = self.__target
        local isVertical = self.__isVertical
        if not target or isVertical == nil then return end

        local offset = self:GetValue()
        if isVertical then
            target:SetVerticalScroll(offset * (target:GetContentHeight() - target:GetHeight()), true)
        else
            target:SetHorizontalScroll(offset * (target:GetContentWidth() - target:GetWidth()), true)
        end
    end

    -- Handler
    --------------------------------

    function ScrollBarMixin:OnTargetScroll()
        self:SyncValue()
    end

    function ScrollBarMixin.OnDrag(self, _, userInput)
        if not userInput then return end

        -- If currently dragging thumb, update drag state
        if self.__thumbDragTravel then
            self:UpdateThumbDrag()
        else
            -- Direct track click - apply scroll immediately
            self:SetTargetScroll()
        end
    end

    -- Get
    --------------------------------

    function ScrollBarMixin:GetVertical()
        return self.__isVertical
    end

    function ScrollBarMixin:GetTarget()
        return self.__target
    end

    -- Set
    --------------------------------

    function ScrollBarMixin:SetVertical(value)
        self:SetOrientation(value and "VERTICAL" or "HORIZONTAL")
        self.__isVertical = value
    end

    function ScrollBarMixin:SetTarget(target)
        local prevTarget = self.__target
        if prevTarget then
            prevTarget:UnhookEvent("OnVerticalScroll", self)
            prevTarget:UnhookEvent("OnHorizontalScroll", self)
        end

        target:HookEvent("OnVerticalScroll", function() self:OnTargetScroll() end)
        target:HookEvent("OnHorizontalScroll", function() self:OnTargetScroll() end)
        self.__target = target
    end

    -- Thumb
    --------------------------------

    local function updateThumbDrag(self)
        local travel = self.__thumbDragTravel
        local range = self.__thumbDragRange
        if not travel or travel <= 0 or not range or range <= 0 then return end

        local minValue = self.__thumbDragMin
        local maxValue = self.__thumbDragMax
        local originValue = self.__thumbDragValueOrigin
        if not minValue or not maxValue or not originValue then return end

        local cursorX, cursorY = GetCursorPosition()
        local cursor = (self.__isVertical and cursorY or cursorX) * self.__thumbDragCursorScale
        local originCursor = self.__thumbDragCursorOrigin or cursor

        local delta = (cursor - originCursor) * self.__thumbDragDirection
        local newValue = originValue + (delta / travel) * range

        if newValue < minValue then
            newValue = minValue
        elseif newValue > maxValue then
            newValue = maxValue
        end

        if newValue ~= self:GetValue() then
            self:SetValue(newValue)
            self:SetTargetScroll()
        end
    end

    function ScrollBarMixin:UpdateThumbDrag()
        if not self:IsEnabled() then return end

        updateThumbDrag(self)
    end

    function ScrollBarMixin:OnThumbMouseDown(button)
        if not self:IsEnabled() then return end
        if button ~= "LeftButton" then return end

        local thumbAnchor = self.__ThumbAnchor
        local isVertical = self.__isVertical
        if not thumbAnchor or isVertical == nil then return end

        local minValue, maxValue = self:GetMinMaxValues()
        if not minValue or not maxValue or maxValue <= minValue then return end

        local trackSize = isVertical and (self:GetHeight() or 0) or (self:GetWidth() or 0)
        local thumbSize = isVertical and (thumbAnchor:GetHeight() or 0) or (thumbAnchor:GetWidth() or 0)
        local travel = trackSize - thumbSize
        if travel <= 0 then return end

        local cursorX, cursorY = GetCursorPosition()
        local effectiveScale = self:GetEffectiveScale()
        if not effectiveScale or effectiveScale == 0 then effectiveScale = 1 end
        local cursorScale = 1 / effectiveScale
        local cursor = (isVertical and cursorY or cursorX) * cursorScale

        self.__thumbDragMin = minValue
        self.__thumbDragMax = maxValue
        self.__thumbDragRange = maxValue - minValue
        self.__thumbDragTravel = travel
        self.__thumbDragCursorScale = cursorScale
        self.__thumbDragCursorOrigin = cursor
        self.__thumbDragValueOrigin = self:GetValue()
        self.__thumbDragDirection = isVertical and -1 or 1
        self:SetScript("OnUpdate", updateThumbDrag)
        self:UpdateThumbDrag()
    end

    function ScrollBarMixin:OnThumbMouseUp(button)
        if not self:IsEnabled() then return end
        if button ~= "LeftButton" then return end

        self:SetScript("OnUpdate", nil)
        self.__thumbDragMin = nil
        self.__thumbDragMax = nil
        self.__thumbDragRange = nil
        self.__thumbDragTravel = nil
        self.__thumbDragCursorScale = nil
        self.__thumbDragCursorOrigin = nil
        self.__thumbDragValueOrigin = nil
        self.__thumbDragDirection = nil
    end
end





function ScrollBar:New(name, parent)
    name = name or "undefined"


    local scrollBar = LinearSlider:New(name, parent)
    Mixin(scrollBar, ScrollBarMixin)
    scrollBar:SetMinMaxValues(0, 1)


    -- Initialize
    --------------------------------

    scrollBar.__isVertical = true
    scrollBar.__target = nil

    
    -- Events
    --------------------------------

    scrollBar:HookEvent("OnValueChanged", scrollBar.OnDrag)
    scrollBar:HookEvent("OnThumbMouseDown", scrollBar.OnThumbMouseDown)
    scrollBar:HookEvent("OnThumbMouseUp", scrollBar.OnThumbMouseUp)


    return scrollBar
end
