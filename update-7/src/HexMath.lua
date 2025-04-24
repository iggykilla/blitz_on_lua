local HexMath = {}

-- Cube coordinate helpers
function HexMath.axialToCube(q, r)
    return { q, -q - r, r }
end

function HexMath.cubeToAxial(cube)
    return cube[1], cube[3]
end

function HexMath.cubeLerp(a, b, t)
    return {
        a[1] + (b[1] - a[1]) * t,
        a[2] + (b[2] - a[2]) * t,
        a[3] + (b[3] - a[3]) * t
    }
end

function HexMath.cubeRound(cube)
    local rx = math.floor(cube[1] + 0.5)
    local ry = math.floor(cube[2] + 0.5)
    local rz = math.floor(cube[3] + 0.5)

    local dx = math.abs(rx - cube[1])
    local dy = math.abs(ry - cube[2])
    local dz = math.abs(rz - cube[3])

    if dx > dy and dx > dz then
        rx = -ry - rz
    elseif dy > dz then
        ry = -rx - rz
    else
        rz = -rx - ry
    end

    return { rx, ry, rz }
end

function HexMath.getLine(q1, r1, q2, r2, includeStart, includeEnd)
    local a = HexMath.axialToCube(q1, r1)
    local b = HexMath.axialToCube(q2, r2)

    local N = math.max(
        math.abs(q1 - q2),
        math.abs(r1 - r2),
        math.abs((-q1 - r1) - (-q2 - r2))
    )

    local results = {}
    local from = includeStart and 0 or 1
    local to = includeEnd and N or N - 1

    for i = from, to do
        local t = i / N
        local interpolated = HexMath.cubeLerp(a, b, t)
        local rounded = HexMath.cubeRound(interpolated)
        local q, r = HexMath.cubeToAxial(rounded)
        local tile = getTile(q, r)
        if tile then table.insert(results, tile) end
    end

    return results
end

function HexMath.hexDistance(q1, r1, q2, r2)
    local a = HexMath.axialToCube(q1, r1)
    local b = HexMath.axialToCube(q2, r2)

    return math.max(
        math.abs(a[1] - b[1]), -- dx
        math.abs(a[2] - b[2]), -- dy
        math.abs(a[3] - b[3])  -- dz
    )
end

return HexMath