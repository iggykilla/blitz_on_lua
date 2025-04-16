Commander = Class{__includes = Piece}

function Commander:init(team, q, r)
    Piece.init(self, "commander", team, q, r)
end

function Commander:getLabel()
    return "K"
end

function Commander:getName()
    return "Commander"
end

function Commander:getValidMoves()
    return getNeighbors(self.q, self.r, COMMANDER_MOVE_RADIUS)
end

function Commander:canAttack(q, r)
    -- Placeholder for Update 5
    return false
end