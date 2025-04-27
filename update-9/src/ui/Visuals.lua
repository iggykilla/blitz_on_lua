local Visuals = {}

function Visuals.drawTile(tile, smallFont, mediumFont)
    local hexPoints = HexBoard:getHexPoints(tile.x, tile.y, HEX_RADIUS)

    -- works for functions in Test.lua
    if tile.debugColor then
        love.graphics.setColor(tile.debugColor[1], tile.debugColor[2], tile.debugColor[3], 0.4)
        love.graphics.polygon("fill", hexPoints)
    end

    --  Fill red if attack tile
    if tile.attackable then
        love.graphics.setColor(1, 0, 0, 0.4)
        love.graphics.polygon("fill", hexPoints)

    -- Fill green if move tile
    elseif tile.highlighted then
        love.graphics.setColor(0, 1, 0, 0.3)
        love.graphics.polygon("fill", hexPoints)
    end

    -- Draw hex outline
    love.graphics.setColor(1, 1, 1)
    love.graphics.setLineWidth(1)
    love.graphics.polygon("line", hexPoints)

    -- Selected outline (drawn after normal border)
    if tile.selected then
        love.graphics.setColor(1, 1, 0, 0.7)
        love.graphics.setLineWidth(3)
        love.graphics.polygon("line", hexPoints)
    end

    -- Hover Visuals
    if tile.isHovered then     
        love.graphics.setColor(0.7,0.7,0.7,0.4)
        love.graphics.setLineWidth(3)
        love.graphics.polygon("fill", hexPoints)
        love.graphics.setColor(1,1,1,1)
    end

    -- Coordinates (q,r)
    local coordLabel = string.format("%d,%d", tile.q, tile.r)
    local textW = smallFont:getWidth(coordLabel)
    local textH = smallFont:getHeight()
    love.graphics.setFont(smallFont)
    love.graphics.print(coordLabel, tile.x + HEX_RADIUS / 2 - textW, tile.y - HEX_RADIUS / 2 - textH)

    -- Unit label (centered)
    if tile.unit then
        local label = tile.unit.label
        local textW = mediumFont:getWidth(label)
        local textH = mediumFont:getHeight()

        tile.unit:render(tile.x - textW / 2, tile.y - textH / 2, mediumFont)
    end
end

function Visuals.highlightTiles(unit, mode)
    if not unit or not mode then return end

    local tilesToMark = (mode == "move")
        and unit:getValidMoves()
        or (mode == "attack" and unit:getValidAttacks())
        or {}

    for _, tile in ipairs(tilesToMark) do
        if mode == "move" then
            tile.highlighted = true
        else  -- mode == "attack"
            tile.attackable  = true
        end
    end
end

function Visuals.clearHighlights()
    for _, tile in ipairs(tiles) do
        tile.highlighted = false
        tile.attackable = false
    end
end

function Visuals.refreshHighlights(unit)
    Visuals.clearHighlights()
    Visuals.highlightTiles(unit, "move")
    Visuals.highlightTiles(unit, "attack")
end

function Visuals.clearHover()
    for _, tile in ipairs(tiles) do
        tile.isHovered = false
    end
end

function Visuals.highlightHover(q, r)
    -- first clear the old hover
    Visuals.clearHover()

    local tile = HexBoard:getTile(q, r)
    if tile then
        tile.isHovered = true
    end
end

function Visuals.showVictory(team)
    love.graphics.setFont(largeFont)
    local message
    if team == "tie" then
        message = "Draw!"
    else
        message = string.format("Victory, %s player!", team)
    end
    love.graphics.printf(
        message,
        0,
        OFFSET_Y - 23,
        VIRTUAL_WIDTH,
        "center"
    )
end

return Visuals