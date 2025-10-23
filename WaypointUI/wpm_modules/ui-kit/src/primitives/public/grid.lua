local env            = select(2, ...)
local MixinUtil      = env.WPM:Import("wpm_modules/mixin-util")
local UIKit_Define   = env.WPM:Import("wpm_modules/ui-kit/define")
local UIKit_Utils    = env.WPM:Import("wpm_modules/ui-kit/utils")
local Frame          = env.WPM:Import("wpm_modules/ui-kit/primitives/frame")

local Mixin          = MixinUtil.Mixin
local ipairs         = ipairs
local math           = math
local tonumber       = tonumber
local type           = type

local Grid           = env.WPM:New("wpm_modules/ui-kit/primitives/grid")




local GridMixin = {}
do
    -- Init
    --------------------------------

    function GridMixin:Init()
        self.__gridCache = {
            templateCols = {},
            templateRows = {},
            colWidths    = {},
            rowHeights   = {},
            colOffsets   = {},
            rowOffsets   = {},
            occ          = {},
            vis          = {},
            colStart     = {},
            rowStart     = {},
            spanCols     = {},
            spanRows     = {}
        }
    end


    -- Helper
    --------------------------------

    local function trimWhitespace(text)
        if not text then
            return text
        end

        return (text:gsub("^%s*(.-)%s*$", "%1"))
    end

    local function parseTrackValue(trackToken)
        if not trackToken then
            return { kind = "auto", value = 0 }
        end

        trackToken = trimWhitespace(trackToken)
        if trackToken == "auto" then
            return { kind = "auto", value = 0 }
        end

        local pixelValue = trackToken:match("^(%-?%d+%.?%d*)px$")
        if pixelValue then
            return { kind = "px", value = tonumber(pixelValue) }
        end

        local percentageValue = trackToken:match("^(%-?%d+%.?%d*)%%$")
        if percentageValue then
            return { kind = "percent", value = tonumber(percentageValue) }
        end

        local fractionValue = trackToken:match("^(%-?%d+%.?%d*)fr$")
        if fractionValue then
            return { kind = "fr", value = tonumber(fractionValue) }
        end

        local numericValue = trackToken:match("^(%-?%d+%.?%d*)$")
        if numericValue then
            return { kind = "px", value = tonumber(numericValue) }
        end

        return { kind = "auto", value = 0 }
    end

    local function populateTrackDefinitions(outputTracks, templateDefinition)
        local trackIndex = 0

        if not templateDefinition then
            for index = 1, #outputTracks do
                outputTracks[index] = nil
            end
            return
        end

        if type(templateDefinition) == "table" then
            for _, trackEntry in ipairs(templateDefinition) do
                if type(trackEntry) == "table" and trackEntry.kind then
                    trackIndex = trackIndex + 1
                    outputTracks[trackIndex] = trackEntry
                elseif type(trackEntry) == "string" then
                    local repetitions, repeatedToken = trackEntry:match("^repeat%((%d+),%s*(.+)%)$")
                    if repetitions and repeatedToken then
                        local repeatCount = tonumber(repetitions) or 0
                        local trimmedToken = trimWhitespace(repeatedToken)
                        for _ = 1, repeatCount do
                            trackIndex = trackIndex + 1
                            outputTracks[trackIndex] = parseTrackValue(trimmedToken)
                        end
                    else
                        for token in trackEntry:gmatch("%S+") do
                            trackIndex = trackIndex + 1
                            outputTracks[trackIndex] = parseTrackValue(token)
                        end
                    end
                elseif type(trackEntry) == "number" then
                    trackIndex = trackIndex + 1
                    outputTracks[trackIndex] = { kind = "px", value = trackEntry }
                end
            end
        elseif type(templateDefinition) == "string" then
            local trimmedDefinition = trimWhitespace(templateDefinition)
            local repetitions, repeatedToken = trimmedDefinition:match("^repeat%((%d+),%s*(.+)%)$")

            if repetitions and repeatedToken then
                local repeatCount = tonumber(repetitions) or 0
                local trimmedToken = trimWhitespace(repeatedToken)
                for _ = 1, repeatCount do
                    trackIndex = trackIndex + 1
                    outputTracks[trackIndex] = parseTrackValue(trimmedToken)
                end
            else
                for token in trimmedDefinition:gmatch("%S+") do
                    trackIndex = trackIndex + 1
                    outputTracks[trackIndex] = parseTrackValue(token)
                end
            end
        elseif type(templateDefinition) == "number" then
            trackIndex = trackIndex + 1
            outputTracks[trackIndex] = { kind = "px", value = templateDefinition }
        end

        for index = trackIndex + 1, #outputTracks do
            outputTracks[index] = nil
        end
    end

    local function parsePlacementSpecification(placement)
        if not placement then
            return nil, nil
        end

        if type(placement) == "number" then
            return tonumber(placement), 1
        end

        if type(placement) ~= "string" then
            return nil, nil
        end

        local spanOnly = placement:match("^span%s+(%d+)$")
        if spanOnly then
            return nil, tonumber(spanOnly)
        end

        local startWithSpanStart, startWithSpanSpan = placement:match("^(%d+)%s*/%s*span%s+(%d+)$")
        if startWithSpanStart and startWithSpanSpan then
            return tonumber(startWithSpanStart), tonumber(startWithSpanSpan)
        end

        local explicitStart, explicitEnd = placement:match("^(%d+)%s*/%s*(%d+)$")
        if explicitStart and explicitEnd then
            local startIndex = tonumber(explicitStart)
            local endIndex = tonumber(explicitEnd)
            return startIndex, math.max(1, endIndex - startIndex)
        end

        local singlePosition = placement:match("^(%d+)$")
        if singlePosition then
            return tonumber(singlePosition), 1
        end

        return nil, nil
    end

    local function clampToBounds(value, minimum, maximum)
        if minimum and value < minimum then
            value = minimum
        end
        if maximum and value > maximum then
            value = maximum
        end
        return value
    end

    local function calculateTrackSizesInto(targetSizes, trackDefinitions, containerSize, totalGap, getAutoSizeForTrack)
        local fixedTrackTotal = 0
        local totalFraction = 0
        local fractionTracks = {}

        for index = 1, #trackDefinitions do
            local trackDefinition = trackDefinitions[index]

            if not trackDefinition or trackDefinition.kind == "auto" then
                targetSizes[index] = 0
            elseif trackDefinition.kind == "px" then
                local pixelValue = trackDefinition.value or 0
                targetSizes[index] = pixelValue
                fixedTrackTotal = fixedTrackTotal + pixelValue
            elseif trackDefinition.kind == "percent" then
                local percentageSize = containerSize * ((trackDefinition.value or 0) / 100)
                targetSizes[index] = percentageSize
                fixedTrackTotal = fixedTrackTotal + percentageSize
            elseif trackDefinition.kind == "fr" then
                targetSizes[index] = 0
                local fractionWeight = trackDefinition.value or 1
                totalFraction = totalFraction + fractionWeight
                fractionTracks[#fractionTracks + 1] = { index, fractionWeight }
            else
                targetSizes[index] = 0
            end
        end

        for index = 1, #trackDefinitions do
            local trackDefinition = trackDefinitions[index]
            if not trackDefinition or trackDefinition.kind == "auto" then
                local autoSize = 0
                if getAutoSizeForTrack then
                    autoSize = getAutoSizeForTrack(index) or 0
                end
                targetSizes[index] = autoSize
                fixedTrackTotal = fixedTrackTotal + autoSize
            end
        end

        local remainingSpace = containerSize - fixedTrackTotal - totalGap
        if remainingSpace < 0 then
            remainingSpace = 0
        end

        if totalFraction > 0 then
            for fractionIndex = 1, #fractionTracks do
                local entry = fractionTracks[fractionIndex]
                local trackIndex = entry[1]
                local weight = entry[2]
                local calculatedSize = remainingSpace * (weight / totalFraction)
                targetSizes[trackIndex] = calculatedSize
            end
        end

        for index = 1, #targetSizes do
            if targetSizes[index] == nil or targetSizes[index] < 0 then
                targetSizes[index] = 0
            end
        end
    end

    local function ensureOccupancyGridSize(occupancyGrid, columnCount, rowCount)
        for rowIndex = 1, rowCount do
            local row = occupancyGrid[rowIndex]
            if not row then
                row = {}
                occupancyGrid[rowIndex] = row
            end

            for columnIndex = 1, columnCount do
                row[columnIndex] = false
            end

            for columnIndex = columnCount + 1, #row do
                row[columnIndex] = nil
            end
        end

        for rowIndex = rowCount + 1, #occupancyGrid do
            occupancyGrid[rowIndex] = nil
        end
    end

    local function markCellsAsOccupied(occupancyGrid, startColumn, startRow, columnSpan, rowSpan)
        for rowIndex = startRow, startRow + rowSpan - 1 do
            local row = occupancyGrid[rowIndex]
            if not row then
                row = {}
                occupancyGrid[rowIndex] = row
            end

            for columnIndex = startColumn, startColumn + columnSpan - 1 do
                row[columnIndex] = true
            end
        end
    end

    local function isCellRangeUnclaimed(occupancyGrid, startColumn, startRow, columnSpan, rowSpan)
        for rowIndex = startRow, startRow + rowSpan - 1 do
            local row = occupancyGrid[rowIndex]
            if row then
                for columnIndex = startColumn, startColumn + columnSpan - 1 do
                    if row[columnIndex] then
                        return false
                    end
                end
            end
        end

        return true
    end

    local function findNextAvailableCell(occupancyGrid, columnCount, rowCount, columnSpan, rowSpan, isRowMajorOrder)
        if isRowMajorOrder == nil then
            isRowMajorOrder = true
        end

        if isRowMajorOrder then
            for rowIndex = 1, rowCount do
                for columnIndex = 1, columnCount do
                    local fitsWithinColumns = columnIndex + columnSpan - 1 <= columnCount
                    local fitsWithinRows = rowIndex + rowSpan - 1 <= rowCount
                    if fitsWithinColumns and fitsWithinRows and isCellRangeUnclaimed(occupancyGrid, columnIndex, rowIndex, columnSpan, rowSpan) then
                        return columnIndex, rowIndex
                    end
                end
            end
        else
            for columnIndex = 1, columnCount do
                for rowIndex = 1, rowCount do
                    local fitsWithinColumns = columnIndex + columnSpan - 1 <= columnCount
                    local fitsWithinRows = rowIndex + rowSpan - 1 <= rowCount
                    if fitsWithinColumns and fitsWithinRows and isCellRangeUnclaimed(occupancyGrid, columnIndex, rowIndex, columnSpan, rowSpan) then
                        return columnIndex, rowIndex
                    end
                end
            end
        end

        return nil, nil
    end

    -- Layout Helpers
    --------------------------------

    local function calculateOffsets(offsets, sizes, count, gap)
        local accumulator = 0
        for index = 1, count do
            offsets[index] = accumulator
            accumulator = accumulator + (sizes[index] or 0)
            if index < count then
                accumulator = accumulator + gap
            end
        end
        -- Clear unused entries
        for index = count + 1, #offsets do
            offsets[index] = nil
        end
    end

    local function calculateSpacing(spacingSetting, spacingType, containerWidth, containerHeight)
        if type(spacingSetting) == "number" then
            return spacingSetting, spacingSetting
        elseif spacingSetting and spacingSetting == UIKit_Define.Num then
            local value = spacingSetting.value or 0
            return value, value
        elseif spacingSetting and spacingSetting == UIKit_Define.Percentage then
            local hSpacing = UIKit_Utils:CalculateRelativePercentage(containerWidth, spacingSetting.value or 0, spacingSetting.operator, spacingSetting.delta)
            local vSpacing = UIKit_Utils:CalculateRelativePercentage(containerHeight, spacingSetting.value or 0, spacingSetting.operator, spacingSetting.delta)
            return hSpacing, vSpacing
        end
        return 0, 0
    end

    local function calculateAlignmentOffset(alignment, containerSize, contentSize)
        if alignment == "JUSTIFIED" then
            return (containerSize - contentSize) * 0.5
        elseif alignment == "TRAILING" then
            return containerSize - contentSize
        end
        return 0
    end

    -- Layout
    --------------------------------

    function GridMixin:RenderElements()
        -- Initialize cache and collect visible children
        local gridCache = self.__gridCache
        local allChildren = self:GetFrameChildren()
        if not allChildren or #allChildren == 0 then return end

        local visibleChildren = gridCache.vis
        local visibleChildCount = 0
        for childIndex = 1, #allChildren do
            local childFrame = allChildren[childIndex]
            if childFrame and childFrame:IsShown() and not childFrame.uk_flag_excludeFromCalculations then
                visibleChildCount = visibleChildCount + 1
                visibleChildren[visibleChildCount] = childFrame
            end
        end
        -- Clear unused entries
        for childIndex = visibleChildCount + 1, #visibleChildren do
            visibleChildren[childIndex] = nil
        end

        if visibleChildCount == 0 then return end

        -- Cache container dimensions
        local parent = self:GetParent()
        local containerWidth = self:GetWidth() or (parent and parent:GetWidth()) or UIParent:GetWidth()
        local containerHeight = self:GetHeight() or (parent and parent:GetHeight()) or UIParent:GetHeight()

        -- Calculate spacing
        local layoutSpacing = self:GetSpacing()
        local spacingHorizontal, spacingVertical = calculateSpacing(layoutSpacing, nil, containerWidth, containerHeight)
        if spacingHorizontal < 0 then spacingHorizontal = 0 end
        if spacingVertical < 0 then spacingVertical = 0 end

        -- Calculate gaps
        local layoutDirection = self.uk_prop_layoutDirection or "vertical"
        local contentGap = self.uk_prop_gap
        local columnGap = self.uk_prop_columnGap or contentGap or spacingHorizontal
        local rowGap = self.uk_prop_rowGap or contentGap or spacingVertical
        columnGap = math.max(0, tonumber(columnGap) or 0)
        rowGap = math.max(0, tonumber(rowGap) or 0)

        -- Estimate average child dimensions from first visible child
        local firstChild = visibleChildren[1]
        local averageChildWidth = (firstChild and firstChild:GetWidth() or 0) > 0 and firstChild:GetWidth() or 50
        local averageChildHeight = (firstChild and firstChild:GetHeight() or 0) > 0 and firstChild:GetHeight() or 50

        populateTrackDefinitions(gridCache.templateCols, self.uk_prop_gridTemplateColumns)
        populateTrackDefinitions(gridCache.templateRows, self.uk_prop_gridTemplateRows)

        local iterateRowMajor = true
        if layoutDirection == "VERTICAL" then
            iterateRowMajor = false
        end

        local maxColumns = self.uk_gridColumns
        local maxRows = self.uk_gridRows
        local columnCount, rowCount

        if #gridCache.templateCols > 0 then
            columnCount = #gridCache.templateCols
        else
            if type(maxColumns) == "number" and maxColumns > 0 then
                columnCount = math.min(maxColumns, visibleChildCount)
            else
                columnCount = math.max(1, math.floor(containerWidth / (averageChildWidth + columnGap)))
                columnCount = math.min(columnCount, visibleChildCount)
            end
        end

        if #gridCache.templateRows > 0 then
            rowCount = #gridCache.templateRows
        else
            if type(maxRows) == "number" and maxRows > 0 then
                rowCount = math.min(maxRows, visibleChildCount)
            else
                rowCount = math.max(1, math.floor(containerHeight / (averageChildHeight + rowGap)))
                rowCount = math.min(rowCount, visibleChildCount)
            end
        end

        if #gridCache.templateCols == 0 and #gridCache.templateRows == 0 then
            if layoutDirection == "VERTICAL" then
                local estimatedRows = math.max(1, math.floor(containerHeight / (averageChildHeight + rowGap)))
                local calculatedColumns = math.max(1, math.floor(visibleChildCount / math.max(1, estimatedRows)))
                columnCount = math.max(1, calculatedColumns)
                rowCount = math.ceil(visibleChildCount / columnCount)
            else
                columnCount = math.max(1, columnCount)
                rowCount = math.ceil(visibleChildCount / columnCount)
            end
        end

        if columnCount < 1 then columnCount = 1 end
        if rowCount < 1 then rowCount = 1 end

        local autoColumnToken = self.uk_prop_gridAutoColumns or "auto"
        local autoRowToken = self.uk_prop_gridAutoRows or "auto"

        if #gridCache.templateCols == 0 then
            for columnIndex = 1, columnCount do
                gridCache.templateCols[columnIndex] = parseTrackValue(autoColumnToken)
            end
            for columnIndex = columnCount + 1, #gridCache.templateCols do
                gridCache.templateCols[columnIndex] = nil
            end
        end
        if #gridCache.templateRows == 0 then
            for rowIndex = 1, rowCount do
                gridCache.templateRows[rowIndex] = parseTrackValue(autoRowToken)
            end
            for rowIndex = rowCount + 1, #gridCache.templateRows do
                gridCache.templateRows[rowIndex] = nil
            end
        end

        local totalColumnGaps = (columnCount > 1) and (columnCount - 1) * columnGap or 0
        local totalRowGaps = (rowCount > 1) and (rowCount - 1) * rowGap or 0

        local function resolveAutoColumnSize(columnIndex)
            local maxWidth = 0
            for visibleIndex = 1, visibleChildCount do
                local childFrame = visibleChildren[visibleIndex]
                local columnProperty = childFrame.uk_prop_gridColumn or childFrame.uk_prop_gridColumnStart
                if columnProperty then
                    local startColumn, columnSpan = parsePlacementSpecification(columnProperty)
                    if startColumn == columnIndex and (not columnSpan or columnSpan == 1) then
                        local childWidth = childFrame:GetWidth() or 0
                        if childWidth > maxWidth then maxWidth = childWidth end
                    end
                else
                    local childWidth = childFrame:GetWidth() or 0
                    if childWidth > maxWidth then maxWidth = childWidth end
                end
            end
            if maxWidth == 0 then maxWidth = averageChildWidth end
            return maxWidth
        end

        local function resolveAutoRowSize(rowIndex)
            local maxHeight = 0
            for visibleIndex = 1, visibleChildCount do
                local childFrame = visibleChildren[visibleIndex]
                local rowProperty = childFrame.uk_prop_gridRow or childFrame.uk_prop_gridRowStart
                if rowProperty then
                    local startRow, rowSpan = parsePlacementSpecification(rowProperty)
                    if startRow == rowIndex and (not rowSpan or rowSpan == 1) then
                        local childHeight = childFrame:GetHeight() or 0
                        if childHeight > maxHeight then maxHeight = childHeight end
                    end
                else
                    local childHeight = childFrame:GetHeight() or 0
                    if childHeight > maxHeight then maxHeight = childHeight end
                end
            end
            if maxHeight == 0 then maxHeight = averageChildHeight end
            return maxHeight
        end

        calculateTrackSizesInto(gridCache.colWidths, gridCache.templateCols, containerWidth, totalColumnGaps, resolveAutoColumnSize)
        calculateTrackSizesInto(gridCache.rowHeights, gridCache.templateRows, containerHeight, totalRowGaps, resolveAutoRowSize)

        -- Calculate offsets for columns and rows
        calculateOffsets(gridCache.colOffsets, gridCache.colWidths, columnCount, columnGap)
        calculateOffsets(gridCache.rowOffsets, gridCache.rowHeights, rowCount, rowGap)

        local occupancyGrid = gridCache.occ
        ensureOccupancyGridSize(occupancyGrid, columnCount, rowCount)

        local columnStartList = gridCache.colStart
        local rowStartList = gridCache.rowStart
        local columnSpanList = gridCache.spanCols
        local rowSpanList = gridCache.spanRows

        for visibleIndex = 1, visibleChildCount do
            local childFrame = visibleChildren[visibleIndex]
            columnStartList[visibleIndex] = nil
            rowStartList[visibleIndex] = nil
            columnSpanList[visibleIndex] = 1
            rowSpanList[visibleIndex] = 1

            if childFrame.uk_prop_gridColumnStart then
                columnStartList[visibleIndex] = tonumber(childFrame.uk_prop_gridColumnStart)
            end
            if childFrame.uk_prop_gridColumnEnd and columnStartList[visibleIndex] then
                local columnEnd = tonumber(childFrame.uk_prop_gridColumnEnd)
                if columnEnd then
                    columnSpanList[visibleIndex] = math.max(1, columnEnd - columnStartList[visibleIndex])
                end
            end
            if childFrame.uk_prop_gridRowStart then
                rowStartList[visibleIndex] = tonumber(childFrame.uk_prop_gridRowStart)
            end
            if childFrame.uk_prop_gridRowEnd and rowStartList[visibleIndex] then
                local rowEnd = tonumber(childFrame.uk_prop_gridRowEnd)
                if rowEnd then
                    rowSpanList[visibleIndex] = math.max(1, rowEnd - rowStartList[visibleIndex])
                end
            end

            if childFrame.uk_prop_gridColumn then
                local startColumn, columnSpan = parsePlacementSpecification(childFrame.uk_prop_gridColumn)
                if startColumn then columnStartList[visibleIndex] = startColumn end
                if columnSpan then columnSpanList[visibleIndex] = columnSpan end
            end
            if childFrame.uk_prop_gridRow then
                local startRow, rowSpan = parsePlacementSpecification(childFrame.uk_prop_gridRow)
                if startRow then rowStartList[visibleIndex] = startRow end
                if rowSpan then rowSpanList[visibleIndex] = rowSpan end
            end

            columnSpanList[visibleIndex] = clampToBounds(columnSpanList[visibleIndex] or 1, 1, columnCount)
            rowSpanList[visibleIndex] = clampToBounds(rowSpanList[visibleIndex] or 1, 1, rowCount)
        end

        for visibleIndex = 1, visibleChildCount do
            local startColumn = columnStartList[visibleIndex]
            local startRow = rowStartList[visibleIndex]
            if startColumn and startRow then
                startColumn = clampToBounds(startColumn, 1, columnCount)
                startRow = clampToBounds(startRow, 1, rowCount)
                columnStartList[visibleIndex] = startColumn
                rowStartList[visibleIndex] = startRow
                if startColumn + columnSpanList[visibleIndex] - 1 > columnCount then
                    columnSpanList[visibleIndex] = columnCount - startColumn + 1
                end
                if startRow + rowSpanList[visibleIndex] - 1 > rowCount then
                    rowSpanList[visibleIndex] = rowCount - startRow + 1
                end
                markCellsAsOccupied(occupancyGrid, startColumn, startRow, columnSpanList[visibleIndex], rowSpanList[visibleIndex])
            end
        end

        for visibleIndex = 1, visibleChildCount do
            if not (columnStartList[visibleIndex] and rowStartList[visibleIndex]) then
                local resolvedColumnStart, resolvedRowStart = findNextAvailableCell(occupancyGrid, columnCount, rowCount, columnSpanList[visibleIndex], rowSpanList[visibleIndex], iterateRowMajor)
                if not resolvedColumnStart or not resolvedRowStart then
                    if layoutDirection == "VERTICAL" then
                        columnCount = columnCount + 1
                        for rowIndex = 1, rowCount do
                            local rowCells = occupancyGrid[rowIndex]
                            if not rowCells then
                                rowCells = {}
                                occupancyGrid[rowIndex] = rowCells
                            end
                            rowCells[columnCount] = false
                        end
                        local trackDefinition = parseTrackValue(autoColumnToken)
                        gridCache.colWidths[columnCount] = (trackDefinition.kind == "px" and trackDefinition.value) or averageChildWidth
                        calculateOffsets(gridCache.colOffsets, gridCache.colWidths, columnCount, columnGap)
                        resolvedColumnStart, resolvedRowStart = findNextAvailableCell(occupancyGrid, columnCount, rowCount, columnSpanList[visibleIndex], rowSpanList[visibleIndex], iterateRowMajor)
                    else
                        rowCount = rowCount + 1
                        occupancyGrid[rowCount] = {}
                        for columnIndex = 1, columnCount do
                            occupancyGrid[rowCount][columnIndex] = false
                        end
                        local trackDefinition = parseTrackValue(autoRowToken)
                        gridCache.rowHeights[rowCount] = (trackDefinition.kind == "px" and trackDefinition.value) or averageChildHeight
                        calculateOffsets(gridCache.rowOffsets, gridCache.rowHeights, rowCount, rowGap)
                        resolvedColumnStart, resolvedRowStart = findNextAvailableCell(occupancyGrid, columnCount, rowCount, columnSpanList[visibleIndex], rowSpanList[visibleIndex], iterateRowMajor)
                    end
                end
                if resolvedColumnStart and resolvedRowStart then
                    columnStartList[visibleIndex] = resolvedColumnStart
                    rowStartList[visibleIndex] = resolvedRowStart
                    markCellsAsOccupied(occupancyGrid, resolvedColumnStart, resolvedRowStart, columnSpanList[visibleIndex], rowSpanList[visibleIndex])
                else
                    columnStartList[visibleIndex] = 1
                    rowStartList[visibleIndex] = 1
                    markCellsAsOccupied(occupancyGrid, 1, 1, columnSpanList[visibleIndex], rowSpanList[visibleIndex])
                end
            end
        end

        -- Calculate alignment properties
        local justifyItems = self.uk_prop_justifyItems or "LEADING"
        local alignItems = self.uk_prop_alignItems or "LEADING"
        local justifyContent = self.uk_prop_justifyContent or "LEADING"
        local alignContent = self.uk_prop_alignContent or "LEADING"

        -- Calculate total grid dimensions
        local totalGridWidth = 0
        for columnIndex = 1, columnCount do
            totalGridWidth = totalGridWidth + (gridCache.colWidths[columnIndex] or 0)
        end
        totalGridWidth = totalGridWidth + ((columnCount > 1) and ((columnCount - 1) * columnGap) or 0)

        local totalGridHeight = 0
        for rowIndex = 1, rowCount do
            totalGridHeight = totalGridHeight + (gridCache.rowHeights[rowIndex] or 0)
        end
        totalGridHeight = totalGridHeight + ((rowCount > 1) and ((rowCount - 1) * rowGap) or 0)

        -- Apply content alignment (may adjust gaps for justified content)
        local gridOriginX = calculateAlignmentOffset(justifyContent, containerWidth, totalGridWidth)
        local gridOriginY = calculateAlignmentOffset(alignContent, containerHeight, totalGridHeight)

        if justifyContent == "JUSTIFIED" and columnCount > 1 then
            columnGap = math.max(0, (containerWidth - (totalGridWidth - ((columnCount - 1) * columnGap))) / (columnCount - 1))
            totalGridWidth = totalGridWidth - ((columnCount - 1) * columnGap) + ((columnCount - 1) * columnGap)
        end

        if alignContent == "JUSTIFIED" and rowCount > 1 then
            rowGap = math.max(0, (containerHeight - (totalGridHeight - ((rowCount - 1) * rowGap))) / (rowCount - 1))
            totalGridHeight = totalGridHeight - ((rowCount - 1) * rowGap) + ((rowCount - 1) * rowGap)
        end

        -- Recalculate offsets if gaps changed
        calculateOffsets(gridCache.colOffsets, gridCache.colWidths, columnCount, columnGap)
        calculateOffsets(gridCache.rowOffsets, gridCache.rowHeights, rowCount, rowGap)

        -- Position all children
        local columnOffsets = gridCache.colOffsets
        local rowOffsets = gridCache.rowOffsets
        local isJustifyStretch = justifyItems == "stretch"
        local isAlignStretch = alignItems == "stretch"

        for visibleIndex = 1, visibleChildCount do
            local childFrame = visibleChildren[visibleIndex]
            local startColumn = clampToBounds(columnStartList[visibleIndex] or 1, 1, columnCount)
            local startRow = clampToBounds(rowStartList[visibleIndex] or 1, 1, rowCount)
            local columnSpan = clampToBounds(columnSpanList[visibleIndex] or 1, 1, columnCount - startColumn + 1)
            local rowSpan = clampToBounds(rowSpanList[visibleIndex] or 1, 1, rowCount - startRow + 1)

            local cellOffsetX = columnOffsets[startColumn] or 0
            local cellOffsetY = rowOffsets[startRow] or 0

            -- Calculate allocated space for this cell
            local allocatedWidth = 0
            for columnIndex = startColumn, startColumn + columnSpan - 1 do
                allocatedWidth = allocatedWidth + (gridCache.colWidths[columnIndex] or 0)
            end
            if columnSpan > 1 then
                allocatedWidth = allocatedWidth + ((columnSpan - 1) * columnGap)
            end

            local allocatedHeight = 0
            for rowIndex = startRow, startRow + rowSpan - 1 do
                allocatedHeight = allocatedHeight + (gridCache.rowHeights[rowIndex] or 0)
            end
            if rowSpan > 1 then
                allocatedHeight = allocatedHeight + ((rowSpan - 1) * rowGap)
            end

            -- Apply stretch or calculate alignment offset
            local offsetX, offsetY = 0, 0
            if isJustifyStretch and childFrame.SetWidth then
                childFrame:SetWidth(allocatedWidth)
            else
                offsetX = calculateAlignmentOffset(justifyItems, allocatedWidth, childFrame:GetWidth() or 0)
            end

            if isAlignStretch and childFrame.SetHeight then
                childFrame:SetHeight(allocatedHeight)
            else
                offsetY = calculateAlignmentOffset(alignItems, allocatedHeight, childFrame:GetHeight() or 0)
            end

            -- Position child
            childFrame:ClearAllPoints()
            childFrame:SetPoint("TOPLEFT", self, "TOPLEFT", gridOriginX + cellOffsetX + offsetX, -(gridOriginY + cellOffsetY + offsetY))
        end

        local fitWidthToContent, fitHeightToContent = self:GetFitContent()
        if fitWidthToContent then
            local resolvedWidth = self:ResolveFitSize("width", totalGridWidth, self.uk_prop_width)
            self:SetWidth(resolvedWidth)
        end
        if fitHeightToContent then
            local resolvedHeight = self:ResolveFitSize("height", totalGridHeight, self.uk_prop_height)
            self:SetHeight(resolvedHeight)
        end
    end


    -- Property
    --------------------------------

    function GridMixin:GetAlignment()
        return self.uk_prop_layoutAlignment or "LEADING"
    end

    function GridMixin:SetAlignment(layoutAlignment)
        self.uk_prop_layoutAlignment = layoutAlignment
        self:RenderElements()
    end
end




function Grid:New(name, parent)
    name = name or "undefined"


    local grid = Frame:New("Frame", name, parent)
    Mixin(grid, GridMixin)
    grid:Init()

    
    return grid
end
