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
    return getNeighbors(self.q, self.r, HORSE_JUMP_RADIUS, true)
end

function Horse:canAttack(q, r)
    -- Placeholder for Update 5
    return false
end