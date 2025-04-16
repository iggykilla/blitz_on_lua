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

function Tank:getValidMoves()
    local short = getNeighbors(self.q, self.r, TANK_SHORT_RADIUS)

    local directions = {
        {-2, 0}, {-2, 2}, {0, 2},
        {2, 0}, {2, -2}, {0, -2}
    }

    local long = getNeighbors(self.q, self.r, TANK_LONG_RADIUS, true, directions)

    -- Combine both move types
    for _, tile in ipairs(long) do
        table.insert(short, tile)
    end

    return short
end

function Tank:canAttack(q, r)
    -- Placeholder for Update 5
    return false
end
