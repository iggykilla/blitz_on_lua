local Visuals = {}

function Visuals.drawTile(tile, smallFont, mediumFont)
    local hexPoints = getHexPoints(tile.x, tile.y, HEX_RADIUS)

    -- Highlighted fill first (so outlines draw over)
    if tile.highlighted then
        love.graphics.setColor(0, 1, 0, 0.3) -- green for valid move
        love.graphics.polygon("fill", hexPoints)
    end  

    -- Optional flash overlay
    if tile.flashTimer > 0 then
        love.graphics.setColor(1, 1, 1, tile.flashTimer)
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

    -- Highlight valid moves
    for _, tile in ipairs(unit:getValidMoves()) do
        tile.highlighted = true
    end
end

return Visuals


