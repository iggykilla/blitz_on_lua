local Visuals = {}

function Visuals.drawTile(tile, smallFont, mediumFont)
    local hexPoints = getHexPoints(tile.x, tile.y, HEX_RADIUS)

    -- Highlight attackable enemies first (in red)
    if tile.attackable then
        love.graphics.setColor(1, 0, 0)  -- Red color for enemy tiles (attackable enemies)
        love.graphics.polygon("fill", hexPoints)
    elseif tile.highlighted then
        -- Green for valid move (already set by highlightValidMovesFor)
        love.graphics.setColor(0, 1, 0, 0.3)  -- Green for valid move
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

function Visuals.highlightValidMovesFor(unit)
    -- Clear previous highlights
    for _, tile in ipairs(tiles) do
        tile.highlighted = false
    end

    local moves = unit:getValidMoves()
    if not moves or type(moves) ~= "table" then
        debug.log("[highlightValidMovesFor] Warning: getValidMoves() returned non-table")
        return
    end

    -- Highlight valid moves
    for _, tile in ipairs(moves) do
        tile.highlighted = true
    end
end

function Visuals.highlightAttackableEnemies(unit)
    -- Reset all tiles
    for _, tile in ipairs(tiles) do
        tile.attackable = false
        tile.highlighted = false
    end

    -- Get attackable tiles (logic only)
    local attackableTiles = unit:getValidAttacks()

    -- Mark visuals
    for _, tile in ipairs(attackableTiles) do
        tile.attackable = true
        tile.highlighted = true
        debug.log(string.format("[highlightAttackableEnemies] Highlighting enemy at (%d,%d) in red", tile.q, tile.r))
    end
end


return Visuals