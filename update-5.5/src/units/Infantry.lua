local function getForwardDirs(team)
    return team == "blue"
        and { {0, -1}, {-1, 0}, {-1, 1} }
        or  { {0, 1}, {1, 0}, {1, -1} }
end

Infantry = Class{__includes = Piece}

local radius = INFANTRY_MOVE_RADIUS

function Infantry:init(team, q, r)
    Piece.init(self, "infantry", team, q, r)
end

function Infantry:getLabel()
    return "I"
end

function Infantry:getName()
    return "Infantry"
end

function Infantry:computeValidMoves()
    local forwardDirs = getForwardDirs(self.team)

    local raw = getNeighbors(self.q, self.r, radius, true, forwardDirs)
    local reachableTiles = getReachableTiles(self.q, self.r, raw, self:getMaxMoveCost(), self)

    return self:filterAccessibleTiles(reachableTiles)
end

function Infantry:computeValidAttacks()
    local forwardDirs = getForwardDirs(self.team)
    local raw = getNeighbors(self.q, self.r, radius, true, forwardDirs)
    return self:filterAttackableTiles(raw)
end

function Infantry:canAttack(q, r)
    return true -- placeholder
end