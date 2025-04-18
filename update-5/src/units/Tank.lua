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
    local directions = {
        {-2, 0}, {-2, 2}, {0, 2},
        {2, 0}, {2, -2}, {0, -2}
    }

    -- Get neighbors within the long radius with specific directions
    local long = getNeighbors(self.q, self.r, TANK_LONG_RADIUS, true, directions)

    -- Combine short and long-range moves
    for _, tile in ipairs(long) do
        table.insert(short, tile)
    end

    return short
end

function Tank:computeValidMoves()
    -- Get the short and long-range valid moves from specialMoves
    local raw = self:specialMoves()

    -- Get reachable tiles based on the valid moves
    local reachableTiles = getReachableTiles(self.q, self.r, raw, self:getMaxMoveCost(), self)

    -- Return the filtered accessible tiles
    return self:filterAccessibleTiles(reachableTiles)
end

function Tank:canAttack(q, r)
    -- Placeholder for Update 5
    return false
end

function Tank:getMaxMoveCost()
    return 2
end
