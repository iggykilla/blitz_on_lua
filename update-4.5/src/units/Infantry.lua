Infantry = Class{__includes = Piece}

function Infantry:init(team, q, r)
    Piece.init(self, "infantry", team, q, r)
end

function Infantry:getLabel()
    return "I"
end

function Infantry:getName()
    return "Infantry"
end

function Infantry:getValidMoves()
    local radius = INFANTRY_MOVE_RADIUS
    local forwardDirs = self.team == "blue"
        and { {0, -1}, {-1, 0}, {-1, 1} }
        or  { {0, 1}, {1, 0}, {1, -1} }

    local raw = getNeighbors(self.q, self.r, radius, true, forwardDirs)
    return self:filterAccessibleTiles(raw)
end

function Infantry:canAttack(q, r)
    -- Placeholder for Update 5: attack logic
    return false
end