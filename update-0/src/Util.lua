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
    local angle_deg = 60 * i - 30
    local angle_rad = math.rad(angle_deg)
    return x + radius * math.cos(angle_rad), y + radius * math.sin(angle_rad)
end
