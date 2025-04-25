local HexMath = {}

-- Converts axial (q, r) to cube (x, y, z)
function HexMath.axialToCube(q, r)
    return { q, -q - r, r }
end

-- Converts cube back to axial (q, r)
function HexMath.cubeToAxial(cube)
    local q = cube[1]
    local r = cube[3]

    -- Normalize -0 to 0 to avoid issues with string formatting
    if r == -0 then r = 0 end

    return q, r
end

-- Linear interpolation between two cube coordinates
function HexMath.cubeLerp(a, b, t)
    return {
        a[1] + (b[1] - a[1]) * t,
        a[2] + (b[2] - a[2]) * t,
        a[3] + (b[3] - a[3]) * t
    }
end

-- Rounds a floating-point cube coordinate to the nearest hex
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

-- Returns the maximum difference in cube coords, i.e. hex distance
function HexMath.hexDistance(q1, r1, q2, r2)
    local a = HexMath.axialToCube(q1, r1)
    local b = HexMath.axialToCube(q2, r2)
    return math.max(
        math.abs(a[1] - b[1]),
        math.abs(a[2] - b[2]),
        math.abs(a[3] - b[3])
    )
end

-- Returns a list of axial coordinate tables {q=,r=} between two hexes (with debug)
-- includeStart/includeEnd default to true
function HexMath.getLineCoords(q1, r1, q2, r2, includeStart, includeEnd)
    if includeStart == nil then includeStart = true end
    if includeEnd   == nil then includeEnd   = true end

    local N    = HexMath.hexDistance(q1, r1, q2, r2)
    local from = includeStart and 0 or 1
    local to   = includeEnd   and N or (N - 1)

--    debug.log(string.format("[getLineCoords] From=(%d,%d) To=(%d,%d) N=%d, from=%d, to=%d", q1, r1, q2, r2, N, from, to))

    local a      = HexMath.axialToCube(q1, r1)
    local b      = HexMath.axialToCube(q2, r2)
    local coords = {}

    for i = from, to do
        local t      = (N == 0) and 0 or (i / N)
        local interp = HexMath.cubeLerp(a, b, t)
        local cube   = HexMath.cubeRound(interp)
        local q, r   = HexMath.cubeToAxial(cube)

        --[[
        debug.log(string.format(
            "  step=%d t=%.2f interp=(%.2f,%.2f,%.2f) rounded=(%d,%d,%d) axial=(%d,%d)",
            i, t,
            interp[1], interp[2], interp[3],
            cube[1], cube[2], cube[3],
            q, r
        ))]]

        table.insert(coords, { q = q, r = r })
    end

    return coords
end

-- Returns an array of tiles along the line, wrapping getLineCoords
function HexMath.getLine(q1, r1, q2, r2, includeStart, includeEnd)
    local coords = HexMath.getLineCoords(q1, r1, q2, r2, includeStart, includeEnd)
    local results = {}
    for _, c in ipairs(coords) do
        local tile = getTile(c.q, c.r)
        if tile then
         --   debug.log(string.format("[getLine] getTile(%d,%d) → found tile q=%d, r=%d", c.q, c.r, tile.q, tile.r))
            table.insert(results, tile)
       -- else
          --  debug.log(string.format("[getLine] getTile(%d,%d) → nil", c.q, c.r))
        end
    end
    return results
end

function HexMath.screenToHex(x, y)
    local gx, gy = push:toGame(x, y)
    local dx, dy = gx - OFFSET_X, gy - OFFSET_Y

    local rf = dx / (HEX_RADIUS * 1.5)
    local qf = (dy / (SQRT3 * HEX_RADIUS)) - (rf * 0.5)
    local sf = -qf - rf

    local roundedCube = HexMath.cubeRound({ qf, sf, rf })
    return HexMath.cubeToAxial(roundedCube)
end

return HexMath