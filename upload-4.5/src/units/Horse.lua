Horse = Class{__includes = Piece}

function Horse:init(team, q, r)
    Piece.init(self, "horse", team, q, r)
end

function Horse:getLabel()
    return "C"
end

function Horse:getName()
    return "Cavalry"
end

function Horse:getValidMoves()
    local raw = getNeighbors(self.q, self.r, HORSE_JUMP_RADIUS, true)
    return self:filterAccessibleTiles(raw)
end

function Horse:canAttack(q, r)
    -- Placeholder for Update 5
    return false
end

function Horse:getMaxMoveCost()
    return 2 -- or whatever value you want
end
