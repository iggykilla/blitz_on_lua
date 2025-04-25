HexBoard = {}

--[[
    HexBoard functions moved from globals to module methods:
    getHexPoints
    getHexCorner
    hexToPixel
    generateHexGrid
    getTile
    getNeighbors
    isTileEmpty
    placeUnit
    moveUnit
    getReachableTiles
    getAttackableTilesRanged
    isTileBlocked
    canMoveThrough
    canAttackThrough
    hasLineOfSight
    getAttackableTilesMelee
    selectUnitAt
]]

function HexBoard:getHexPoints(x, y, radius)
    local points = {}
    for i = 0, 5 do
        local cornerX, cornerY = self:getHexCorner(x, y, i, radius)
        table.insert(points, cornerX)
        table.insert(points, cornerY)
    end
    return points
end

function HexBoard:getHexCorner(x, y, i, radius)
    local angle_deg = 60 * i + 0
    local angle_rad = math.rad(angle_deg)
    return x + radius * math.cos(angle_rad), y + radius * math.sin(angle_rad)
end

function HexBoard:hexToPixel(q, r)
    local x = HEX_RADIUS * 1.5 * r
    local y = HEX_RADIUS * SQRT3 * (q + r / 2)
    return x, y
end

function HexBoard:generateHexGrid(OFFSET_X, OFFSET_Y)
    local tiles = {}
    local size = 4

    for q = -size, size do
        local r1 = math.max(-size, -q - size)
        local r2 = math.min(size, -q + size)

        for r = r1, r2 do
            local x, y = self:hexToPixel(q, r)
            local tile = {
                q = q,
                r = r,
                x = x + OFFSET_X,
                y = y + OFFSET_Y,
                unit = nil,
                team = nil,
                occupied = false,
                selected = false,
                highlightType = nil,
                flashTimer = 0,
                moveCost = 1,
                attackable = false
            }

            -- Log the key being used to store the tile
         --   debug.log(string.format("[generateHexGrid] Storing tile at (%d,%d) with key: %s", q, r, q .. "," .. r))

            table.insert(tiles, tile)

            -- store by coordinate key
            tilesByCoordinates[q .. "," .. r] = tile
        end
    end

    return tiles
end

function HexBoard:getTile(q, r)
    local key = q .. "," .. r
   -- debug.log(string.format("[getTile] Looking for tile with key: %s", key))
    local tile = tilesByCoordinates[key]
    
    if not tile then
   --     debug.log(string.format("[getTile] Tile with key %s not found", key))
    else
   --     debug.log(string.format("[getTile] Tile found: q = %d, r = %d", tile.q, tile.r))
    end

    return tile
end

function HexBoard:getNeighbors(q, r, radius, exact, allowedDirections)
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
            local tile = self:getTile(neighborQ, neighborR)
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

function HexBoard:isTileEmpty(q, r)
    local tile = self:getTile(q, r)
    return tile and tile.unit == nil
end

function HexBoard:placeUnit(q, r, unitType, team)
    local tile = self:getTile(q, r)
    if not tile then
        debug.log(string.format("❌ No tile at (%d,%d) for placing %s (%s)", q, r, type, team))
        return
    end

    local unit = UnitFactory(unitType, team, q, r)
    unit.q = q
    unit.r = r
    tile.unit = unit
    tile.occupied = true
  --  debug.log(string.format("✅ Placed %s (%s) at (%d,%d)", unit:getName(), team, q, r))
end

function HexBoard:moveUnit(q1, r1, q2, r2)
    local from = self:getTile(q1, r1)
    local to = self:getTile(q2, r2)

    if not from or not from.unit then return false end
    if not to or to.occupied then return false end
    if not from.unit:canMoveTo(q2, r2) then return false end

    debug.log(string.format("[moveUnit] from (%d,%d) to (%d,%d)", q1, r1, q2, r2))

    if not from then debug.log("[moveUnit] ❌ 'from' tile not found") end
    if not from.unit then debug.log("[moveUnit] ❌ no unit on 'from' tile") end
    if not to then debug.log("[moveUnit] ❌ 'to' tile not found") end
    if to and to.occupied then debug.log("[moveUnit] ❌ 'to' tile is occupied") end

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

function HexBoard:getReachableTiles(startQ, startR, maxCost, unit, includeBlocked)
    local start = self:getTile(startQ, startR)
    if not start then
    --    debug.log("[getReachableTiles] ❌ Invalid start tile")
        return {}
    end
   -- debug.log(string.format("[getReachableTiles] 🚀 Start at (%d,%d)", startQ, startR))

    local reachable = {}
    local visited = {}
    local queue = {{tile = start, cost = 0}}

    while #queue > 0 do
        local current = table.remove(queue, 1)
        local tile = current.tile
        local cost = current.cost
        local key = tile.q .. "," .. tile.r

        if not visited[key] or cost < visited[key] then
         --   debug.log(string.format("[getReachableTiles] ✅ Visiting (%d,%d) with cost %d", tile.q, tile.r, cost))
            visited[key] = cost
            tile.costSoFar = cost
            reachable[key] = tile

            for _, neighbor in ipairs(HexBoard:getNeighbors(tile.q, tile.r)) do
                local moveCost = cost + unit:modifyMoveCost(neighbor)
                if self:canMoveThrough(neighbor, unit) then
                    if moveCost <= maxCost then
                     --   debug.log(string.format("[getReachableTiles] → ✅ Enqueue (%d,%d) with cost %d", neighbor.q, neighbor.r, moveCost))
                        table.insert(queue, {tile = neighbor, cost = moveCost})
                    else
                    --    debug.log(string.format("[getReachableTiles] → ❌ Too expensive (%d,%d) with cost %d", neighbor.q, neighbor.r, moveCost))
                    end
                elseif includeBlocked and not reachable[neighbor.q .. "," .. neighbor.r] then
                  --  debug.log(string.format("[getReachableTiles] 🔒 Including blocked tile (%d,%d)", neighbor.q, neighbor.r))
                    reachable[neighbor.q .. "," .. neighbor.r] = neighbor
                    neighbor.blocked = true -- Optional flag you can use in filtering
                else
                   -- debug.log(string.format("[getReachableTiles] → ❌ Blocked (%d,%d)", neighbor.q, neighbor.r))
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

    -- debug.log(string.format("[getReachableTiles] 🟢 Found %d reachable+blocked tiles", #result))
    local coords = {}
    for _, tile in ipairs(result) do
        table.insert(coords, string.format("(%d,%d)", tile.q, tile.r))
    end
    -- debug.log("[getReachableTiles] Tiles: " .. table.concat(coords, ", "))

    return result
end

function HexBoard:getAttackableTilesRanged(startQ, startR, unit)
    local start = self:getTile(startQ, startR)
    if not start then 
        return {}
    end

    local attackable = {}
    local maxCost   = unit:maxAttackCost()
    local maxRange  = unit:maxAttackRange()

    local neighbors = self:getNeighbors(startQ, startR, maxRange)

    for _, neighbor in ipairs(neighbors) do
        local nq, nr = neighbor.q, neighbor.r

        if not neighbor.unit then
            goto continue
        end

        if neighbor.unit.team == unit.team then
            goto continue
        end

        local distance = HexMath.hexDistance(startQ, startR, nq, nr)
        local cost     = unit:attackCost(distance)
        if cost > maxCost then
            goto continue
        end

        if distance <= maxRange and unit:canAttack(nq, nr) then
            attackable[nq .. "," .. nr] = neighbor
        end

        ::continue::
    end

    local result = {}
    for _, tile in pairs(attackable) do
        table.insert(result, tile)
    end

    --[[
    for _, tile in ipairs(result) do
        debug.log(string.format("Attackable tile at (%d, %d)", tile.q, tile.r))
    end]]

    return result
end

function HexBoard:isTileBlocked(tile, unit, mode)
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

function HexBoard:canMoveThrough(tile, unit)
    return not self:isTileBlocked(tile, unit, "move")
end

function HexBoard:canAttackThrough(unit, tile)
    return not self:isTileBlocked(tile, unit, "attack")
end

function HexBoard:hasLineOfSight(unit, fromTile, toTile)
  --  debug.log("🧠 hasLineOfSight called from " .. fromTile.q .. "," .. fromTile.r .. " to " .. toTile.q .. "," .. toTile.r)

    local line = HexMath.getLine(fromTile.q, fromTile.r, toTile.q, toTile.r, false, false)

    for _, tile in ipairs(line) do
        -- Block both friendly and enemy units for LoS
        if tile.unit then
        --    debug.log(string.format("[LoS] Tile (%d,%d) has unit %s (%s)", tile.q, tile.r, tile.unit.type, tile.unit.team))
            return false  -- Block LoS if any unit is in the path
        end
    end

    return true  -- Clear LoS
end

function HexBoard:getAttackableTilesMelee(startQ, startR, unit)
    local reachable = self:getReachableTiles(startQ, startR, unit:getMaxMoveCost(), unit, true)
    local attackable = {}
    local attackCost = unit:attackCost()
    local maxCost = unit:maxAttackCost()

    -- debug.log(string.format("[getAttackableTilesMelee] 📦 Reachable tiles: %d, Attack cost: %d", #reachable, attackCost))
    local coords = {}
    for _, tile in ipairs(reachable) do
        table.insert(coords, string.format("(%d,%d)", tile.q, tile.r))
    end
    -- debug.log("[getAttackableTilesMelee] Reachable tiles: " .. table.concat(coords, ", "))

    for _, tile in ipairs(reachable) do
        if tile.unit and tile.unit.team ~= unit.team then
            local key = tile.q .. "," .. tile.r
            if not attackable[key] and attackCost <= maxCost then
                attackable[key] = tile
            --    debug.log(string.format("[getAttackableTilesMelee] ✅ (%d,%d) reachable enemy", tile.q, tile.r))
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

function HexBoard:getUnitAt(q, r)
    local tile = self:getTile(q, r)
    return tile and tile.unit or nil
end

return HexBoard

