local env                 = select(2, ...)
local Utils_LazyTable     = env.WPM:Import("wpm_modules/utils/lazy-table")
local UIKit_FrameCache = env.WPM:Import("wpm_modules/ui-kit/frame-cache")

local Frame               = env.WPM:Import("wpm_modules/ui-kit/primitives/frame")
local Grid                = env.WPM:Import("wpm_modules/ui-kit/primitives/grid")
local HStack              = env.WPM:Import("wpm_modules/ui-kit/primitives/hStack")
local VStack              = env.WPM:Import("wpm_modules/ui-kit/primitives/vStack")
local Text                = env.WPM:Import("wpm_modules/ui-kit/primitives/text")
local LazyScrollView      = env.WPM:Import("wpm_modules/ui-kit/primitives/lazyScrollView")
local ScrollView          = env.WPM:Import("wpm_modules/ui-kit/primitives/scrollView")
local ScrollBar           = env.WPM:Import("wpm_modules/ui-kit/primitives/scrollBar")
local Input               = env.WPM:Import("wpm_modules/ui-kit/primitives/input")
local LinearSlider        = env.WPM:Import("wpm_modules/ui-kit/primitives/linearSlider")
local InteractiveRect     = env.WPM:Import("wpm_modules/ui-kit/primitives/interactiveRect")
local List                = env.WPM:Import("wpm_modules/ui-kit/primitives/list")

local UIKit_UI_Parser  = env.WPM:New("wpm_modules/ui-kit/ui/parser")




local FRAME_CONSTRUCTORS = {
    Frame           = function(self, name) return Frame:New("Frame", name, nil) end,
    Grid            = Grid.New,
    HStack          = HStack.New,
    VStack          = VStack.New,
    Text            = Text.New,
    LazyScrollView  = LazyScrollView.New,
    ScrollView      = ScrollView.New,
    ScrollBar       = ScrollBar.New,
    Input           = Input.New,
    LinearSlider    = LinearSlider.New,
    InteractiveRect = InteractiveRect.New,
    List            = List.New
}



local id = 0

local function isScrollContainer(frameType)
    return frameType == "ScrollView" or frameType == "LazyScrollView"
end

local function getActualParentFrame(parentFrame, parentFrameType)
    if isScrollContainer(parentFrameType) and parentFrame.GetContentFrame then
        return parentFrame:GetContentFrame()
    end

    return parentFrame
end

local function setupRegularFrameParent(childFrame, parentFrame, parentFrameType)
    local aliasName = childFrame.uk_prop_under
    local alias = aliasName and parentFrame:GetAlias(aliasName)

    if alias then
        -- Parent to the alias instead of the main frame
        childFrame:SetParent(alias)
        childFrame.uk_parent = alias
    else
        -- Parent to the actual frame (or its ContentFrame for scroll view
        local actualParent = getActualParentFrame(parentFrame, parentFrameType)
        childFrame:SetParent(actualParent)

        -- Store reference to the logical parent (always their main frame, not ContentFrame)
        childFrame.uk_parent = parentFrame
    end

    if childFrame.uk_prop_frameLevel then
        childFrame:SetFrameLevel(childFrame.uk_prop_frameLevel)
    else
        childFrame:SetFrameLevel(parentFrame:GetFrameLevel() + 1)
    end
end

local function attachChildToParent(childFrame, parentFrame, parentFrameType)
    -- InteractiveRect uses a different parenting mechanism
    if childFrame.uk_type == "InteractiveRect" then
        childFrame:RegisterParent(parentFrame)
        return
    end

    -- Regular frames with SetParent method
    if childFrame and childFrame.SetParent then
        setupRegularFrameParent(childFrame, parentFrame, parentFrameType)
    end

    -- Track child in parent's children list (for all frame types)
    parentFrame:AddFrameChild(childFrame)
end

function UIKit_UI_Parser:CreateFrameFromType(frameType, name, children)
    local constructor = FRAME_CONSTRUCTORS[frameType]
    if not constructor then return end

    -- Handle overloaded parameters: if name is a table and children is nil,
    -- treat name as children (allows calling without explicit name)
    if children == nil and type(name) == "table" then
        children = name
        name = nil
    end

    id = id + 1
    local frameName = name or "undefined"
    local frame = constructor(nil, frameName)
    UIKit_FrameCache:Add(id, frame)

    frame.uk_id = id
    frame.uk_type = frameType
    frame.uk_ready = false
    Utils_LazyTable.New(frame, "uk_children")

    -- Attach all children to this frame
    if children then
        for i = 1, #children do
            attachChildToParent(children[i], frame, frameType)
        end
    end

    return frame
end
