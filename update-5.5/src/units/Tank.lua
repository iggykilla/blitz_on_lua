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
    -- Get the short and long-range valid moves from specialMoves
    local raw = self:specialMoves()

    -- Get reachable tiles based on the valid moves
    local reachableTiles = getReachableTiles(self.q, self.r, raw, self:getMaxMoveCost(), self)

    -- Return the filtered accessible tiles
    return self:filterAccessibleTiles(reachableTiles)
end

function Tank:getMaxMoveCost()
    return 2
end

function Tank:computeValidAttacks()
    local raw = self:specialMoves()
    return self:filterAttackableTiles(raw)
end

function Tank:canAttack(q, r)
    -- Placeholder for Update 5
    return false
end