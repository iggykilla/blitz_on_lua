--[[
    drawHex(x, y, radius)
    getHexCorner(x, y, i, radius)    
    hexToPixel(q, r)    
    generateHexGrid()
]]

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

function generateHexGrid()
    local tiles = {}

    local size = 4 -- this gives us 5-6-7-8-9-8-7-6-5 rows

    for q = -size, size do
        local r1 = math.max(-size, -q - size)
        local r2 = math.min(size, -q + size)

        for r = r1, r2 do
            table.insert(tiles, { q = q, r = r })
        end
    end

    return tiles
end
