local Visuals = {}

function Visuals.drawTile(tile, smallFont, mediumFont)
    local hexPoints = getHexPoints(tile.x, tile.y, HEX_RADIUS)

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
        love.graphics.setColor(1, 1, 0)
        love.graphics.setLineWidth(4)
        love.graphics.polygon("line", hexPoints)
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
    local tiles = {}
    if mode == "move" then
        tiles = unit:getValidMoves()
    --    debug.log(string.format("[highlightTiles] Highlighting %d move tiles for %s (%s)", #tiles, unit.type, unit.team))
        for _, tile in ipairs(tiles) do
            tile.highlighted = true
    --        debug.log(string.format("  → Move tile: (%d, %d)", tile.q, tile.r))
        end

    elseif mode == "attack" then
        tiles = unit:getValidAttacks()
     --   debug.log(string.format("[highlightTiles] Highlighting %d attack tiles for %s (%s)", #tiles, unit.type, unit.team))
        for _, tile in ipairs(tiles) do
            tile.attackable = true
        --    debug.log(string.format("  → Attack tile: (%d, %d)", tile.q, tile.r))
        end
    end
end

function Visuals.refreshHighlights(unit)
    clearHighlights()
    Visuals.highlightTiles(unit, "move")
    Visuals.highlightTiles(unit, "attack")
end

return Visuals