--[[
    drawHex(x, y, radius)
    getHexCorner(x, y, i, radius)    
    hexToPixel(q, r)    
    generateHexGrid()
    getTile(q, r)
    getNeighbors(q, r)
    isTileEmpty(q, r)
    placeUnit(tiles, q, r, unitType, team)
    moveUnit(q1, r1, q2, r2)
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

function getNeighbors(q, r, radius, exact, allowedDirections)
    radius = radius or 1
    local results = {}

    for dq = -radius, radius do
        for dr = math.max(-radius, -dq - radius), math.min(radius, -dq + radius) do
            if dq == 0 and dr == 0 then goto continue end

            local distance = math.max(math.abs(dq), math.abs(dr), math.abs(-dq - dr))

            -- Check both booleans if they pass skips to continue (if exact was set to false skips this line)
            if exact and distance ~= radius then goto continue end

            -- direction filter (optional)
            if allowedDirections then
                local match = false
                for _, dir in ipairs(allowedDirections) do
                    if dq == dir[1] and dr == dir[2] then
                        match = true
                        break
                    end
                end
                if not match then goto continue end
            end         

            local neighborQ = q + dq
            local neighborR = r + dr
            local tile = getTile(neighborQ, neighborR)
            if tile then
                table.insert(results, tile)
            end
                
            ::continue::
        end
    end
    
    return results
end

function isTileEmpty(q, r)
    local tile = getTile(q, r)
    return tile and tile.unit == nil
end

function placeUnit(q, r, unitType, team)
    local tile = getTile(q, r)
    if tile then
        tile.unit = UnitFactory(unitType, team, q, r)
        tile.occupied = true
    end
end

function moveUnit(q1, r1, q2, r2)
    local from = getTile(q1, r1)
    local to = getTile(q2, r2)

    if not from or not from.unit then return false end
    if not to or to.occupied then return false end
    if not from.unit:canMoveTo(q2, r2) then return false end

    -- Move unit
    to.unit = from.unit
    to.unit:setPosition(q2, r2)
    to.occupied = true

    from.unit = nil
    from.occupied = false

    debug.log(string.format("Moved %s (%s) from %d,%d to %d,%d",
        to.unit.type, to.unit.team, q1, r1, q2, r2))

    return true
end
