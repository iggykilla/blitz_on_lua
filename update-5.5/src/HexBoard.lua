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

function getHexPoints(x, y, radius)
    local points = {}
    for i = 0, 5 do
        local cornerX, cornerY = getHexCorner(x, y, i, radius)
        table.insert(points, cornerX)
        table.insert(points, cornerY)
    end
    return points
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
                q = q,                                  -- q coordinate for the hex tile
                r = r,                                  -- r coordinate for the hex tile
                x = x + offsetX,                        -- x position for rendering
                y = y + offsetY,                        -- y position for rendering
                unit = nil,                             -- The unit occupying the tile (if any)
                team = nil,                             -- The team of the unit occupying the tile (if any)
                occupied = false,                       -- Whether the tile is occupied by a unit
                selected = false,                       -- Whether the tile is selected
                highlightType = nil,                     -- Whether the tile is highlightType
                flashTimer = 0,                         -- Timer for flashing the tile (if needed)
                moveCost = 1,                           -- The movement cost of the tile (e.g., 1 for normal terrain)
                attackable = false                      -- New flag to mark the tile as attackable (if occupied by enemy)
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

    --[[if DEBUG_MODE then
        debug.log(string.format("[getNeighbors] q=%d r=%d radius=%d exact=%s dirs=%s",
            q, r, radius, tostring(exact), allowedDirections and "yes" or "none"))
    end]]

    for dq = -radius, radius do
        for dr = math.max(-radius, -dq - radius), math.min(radius, -dq + radius) do
            if dq == 0 and dr == 0 then goto continue end

            local distance = math.max(math.abs(dq), math.abs(dr), math.abs(-dq - dr))
            if exact and distance ~= radius then goto continue end

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
                --[[if DEBUG_MODE then
                    debug.log(string.format("  → found tile (%d, %d)", tile.q, tile.r))
                end]]
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
    to.unit:invalidateMoves() -- 🧼 Clear cached moves
    to.unit:invalidateAttacks()
    to.occupied = true
    to.flashTimer = 0.8

    from.unit = nil
    from.occupied = false

    debug.log(string.format("Moved %s (%s) from %d,%d to %d,%d",
        to.unit.type, to.unit.team, q1, r1, q2, r2))

    return true
end

function getReachableTiles(startQ, startR, maxCost, unit, includeBlocked)
    local start = getTile(startQ, startR)
    if not start then
        debug.log("[getReachableTiles] ❌ Invalid start tile")
        return {}
    end
    debug.log(string.format("[getReachableTiles] 🚀 Start at (%d,%d)", startQ, startR))

    local reachable = {}
    local visited = {}
    local queue = {{tile = start, cost = 0}}

    while #queue > 0 do
        local current = table.remove(queue, 1)
        local tile = current.tile
        local cost = current.cost
        local key = tile.q .. "," .. tile.r

        if not visited[key] or cost < visited[key] then
            debug.log(string.format("[getReachableTiles] ✅ Visiting (%d,%d) with cost %d", tile.q, tile.r, cost))
            visited[key] = cost
            tile.costSoFar = cost
            reachable[key] = tile

            for _, neighbor in ipairs(getNeighbors(tile.q, tile.r)) do
                local moveCost = cost + unit:modifyMoveCost(neighbor)
                if canMoveThrough(neighbor, unit) then
                    if moveCost <= maxCost then
                        debug.log(string.format("[getReachableTiles] → ✅ Enqueue (%d,%d) with cost %d", neighbor.q, neighbor.r, moveCost))
                        table.insert(queue, {tile = neighbor, cost = moveCost})
                    else
                        debug.log(string.format("[getReachableTiles] → ❌ Too expensive (%d,%d) with cost %d", neighbor.q, neighbor.r, moveCost))
                    end
                elseif includeBlocked and not reachable[neighbor.q .. "," .. neighbor.r] then
                    debug.log(string.format("[getReachableTiles] 🔒 Including blocked tile (%d,%d)", neighbor.q, neighbor.r))
                    reachable[neighbor.q .. "," .. neighbor.r] = neighbor
                    neighbor.blocked = true -- Optional flag you can use in filtering
                else
                    debug.log(string.format("[getReachableTiles] → ❌ Blocked (%d,%d)", neighbor.q, neighbor.r))
                end
            end
        end
    end

    -- Cleanup and return as list
    local result = {}
    for _, tile in pairs(reachable) do
        tile.costSoFar = nil
        table.insert(result, tile)
    end

    debug.log(string.format("[getReachableTiles] 🟢 Found %d reachable+blocked tiles", #result))
    local coords = {}
    for _, tile in ipairs(result) do
        table.insert(coords, string.format("(%d,%d)", tile.q, tile.r))
    end
    debug.log("[getReachableTiles] Tiles: " .. table.concat(coords, ", "))

    return result
end

function clearHighlights()
    for _, tile in ipairs(tiles) do
        tile.highlighted = false
        tile.attackable = false
    end
end

function getAttackableTilesRanged(startQ, startR, unit, validTiles)
    local start = getTile(startQ, startR)
    if not start then 
        return {}
    end

    local attackable = {}
    local cost = unit:attackCost()
    local maxCost = unit:maxAttackCost()
    local maxRange = unit:maxAttackRange()

    local neighbors = validTiles or getNeighbors(startQ, startR, maxRange)

    for _, neighbor in ipairs(neighbors) do
        -- Must be enemy unit
        if not neighbor.unit or neighbor.unit.team == unit.team then goto continue end

        -- Optional cost filtering (in case we add variable cost per tile later)
        if cost > maxCost then goto continue end

        local distance = math.abs(neighbor.q - startQ) + math.abs(neighbor.r - startR)
        if distance <= maxRange and unit:canAttack(neighbor.q, neighbor.r) then
            attackable[neighbor.q .. "," .. neighbor.r] = neighbor
    --        debug.log(string.format("[getAttackableTilesRanged] ✅ (%d,%d) enemy in range %d", neighbor.q, neighbor.r, distance))
        end

        ::continue::
    end

    -- Return flat list
    local result = {}
    for _, tile in pairs(attackable) do
        table.insert(result, tile)
    end

    return result
end

function isTileBlocked(tile, unit, mode)
    -- Shared terrain rule
    if tile.terrain == "mountain" then return true end

    if tile.unit then
        if mode == "move" then
            return true -- Block movement through any unit
        elseif mode == "attack" then
            -- Can't attack through *any* unit (ally or enemy)
            return true
        end
    end

    return false
end

function canMoveThrough(tile, unit)
    return not isTileBlocked(tile, unit, "move")
end

function canAttackThrough(unit, tile)
    return not isTileBlocked(tile, unit, "attack")
end

function hasLineOfSight(unit, fromTile, toTile)
    local line = HexMath.getLine(fromTile.q, fromTile.r, toTile.q, toTile.r)

    for _, tile in ipairs(line) do
        if not canAttackThrough(unit, tile) then
            debug.log(string.format("[LoS] Blocked at (%d,%d)", tile.q, tile.r))
            return false
        end
    end

    return true
end

function getAttackableTilesMelee(startQ, startR, unit)
    local reachable = getReachableTiles(startQ, startR, unit:getMaxMoveCost(), unit, true)
    local attackable = {}
    local attackCost = unit:attackCost()
    local maxCost = unit:maxAttackCost()

    debug.log(string.format("[getAttackableTilesMelee] 📦 Reachable tiles: %d, Attack cost: %d", #reachable, attackCost))
    local coords = {}
    for _, tile in ipairs(reachable) do
        table.insert(coords, string.format("(%d,%d)", tile.q, tile.r))
    end
    debug.log("[getAttackableTilesMelee] Reachable tiles: " .. table.concat(coords, ", "))

    for _, tile in ipairs(reachable) do
        if tile.unit and tile.unit.team ~= unit.team then
            local key = tile.q .. "," .. tile.r
            if not attackable[key] and attackCost <= maxCost then
                attackable[key] = tile
                debug.log(string.format("[getAttackableTilesMelee] ✅ (%d,%d) reachable enemy", tile.q, tile.r))
            end
        end
    end

    -- Return flat list
    local result = {}
    for _, tile in pairs(attackable) do
        table.insert(result, tile)
    end

    return result
end
