--[[
    drawHex(x, y, radius)
    getHexCorner(x, y, i, radius)    
    hexToPixel(q, r)    
    generateHexGrid()
    getTile(q, r)
    getNeighbors(q, r)
    isTileEmpty(q, r)
    placeUnit(tiles, q, r, unit, team)
]]

local directions = {
    {1, 0}, {1, -1}, {0, -1},
    {-1, 0}, {-1, 1}, {0, 1}
}

function drawHex(x, y, radius)
    local points = {}

    for i = 0, 5 do
        local cornerX, cornerY = getHexCorner(x, y, i, radius)
        table.insert(points, cornerX)
        table.insert(points, cornerY)
    end

    love.graphics.polygon("line", points)
end

function getHexCorner(x, y, i, radius)
    local angle_deg = 60 * i + 0
    local angle_rad = math.rad(angle_deg)
    return x + radius * math.cos(angle_rad), y + radius * math.sin(angle_rad)
end

function hexToPixel(q, r)
    local x = HEX_RADIUS * 1.5 * r
    local y = HEX_RADIUS * math.sqrt(3) * (q + r / 2)
    return x, y
end

function generateHexGrid(offsetX, offsetY)
    local tiles = {}
    local size = 4

    for q = -size, size do
        local r1 = math.max(-size, -q - size)
        local r2 = math.min(size, -q + size)

        for r = r1, r2 do
            local x, y = hexToPixel(q, r)
            local tile = {
                q = q,
                r = r,
                x = x + offsetX,
                y = y + offsetY,
                unit = nil,
                team = nil,
                occupied = false,
                selected = false,
                highlighted = false
            }
            
        table.insert(tiles, tile)

        -- store by coordinate key
        tilesByCoordinates[q .. "," .. r] = tile
        end
    end

    return tiles
end

function getTile(q, r)
    return tilesByCoordinates[q .. "," .. r] or nil
end

function getNeighbors(q, r)
    local neighbors = {}
    for _, dir in ipairs(directions) do
        local neighbor = getTile(q + dir[1], r + dir[2])
        if neighbor then
            table.insert(neighbors, neighbor)
        end
    end
    return neighbors
end

function isTileEmpty(q, r)
    local tile = getTile(q, r)
    return tile and tile.unit == nil
end

function placeUnit(q, r, type, team)
    local tile = getTile(q, r)
    if tile then
        tile.unit = Piece(type, team, q, r)
        tile.occupied = true
    end
end
