local function getTankRangedDirections()
    return {
        {-2, 0}, {-2, 2}, {0, 2},
        {2, 0}, {2, -2}, {0, -2}
    }
end

Tank = Class{__includes = Piece}

function Tank:init(team, q, r)
    Piece.init(self, "tank", team, q, r)
end

function Tank:getLabel()
    return "T"
end

function Tank:getName()
    return "Tank"
end

function Tank:specialMoves()
    -- Get neighbors within the short radius
    local short = getNeighbors(self.q, self.r, TANK_SHORT_RADIUS)

    -- Define custom movement directions for long radius
    local directions = getTankRangedDirections()

    -- Get neighbors within the long radius with specific directions
    local long = getNeighbors(self.q, self.r, TANK_LONG_RADIUS, true, directions)

    -- Combine into a new result table
    local result = {}
    for _, tile in ipairs(short) do
        table.insert(result, tile)
    end
    for _, tile in ipairs(long) do
        table.insert(result, tile)
    end

    return result
end

function Tank:computeValidMoves()
    local reachable = getReachableTiles(self.q, self.r, self:getMaxMoveCost(), self)
    
    -- Quick lookup table to compare
    local reachableMap = {}
    for _, tile in ipairs(reachable) do
        reachableMap[tile.q .. "," .. tile.r] = true
    end

    -- Now only keep special moves that are reachable
    local raw = self:specialMoves()
    local filtered = {}
    for _, tile in ipairs(raw) do
        if reachableMap[tile.q .. "," .. tile.r] then
            table.insert(filtered, tile)
        end
    end

    return self:filterAccessibleTiles(filtered)
end

function Tank:getMaxMoveCost()
    return 2
end

function Tank:computeValidAttacks()
    local raw = self:specialMoves()
    local attackable = getAttackableTilesRanged(self.q, self.r, self, raw)
    return self:filterAttackableTiles(attackable)
end