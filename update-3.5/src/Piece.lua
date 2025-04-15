Piece = Class{}

function Piece:init(type, team, q, r)
    self.type = type                    -- e.g., "infantry", "tank"
    self.team = team                    -- "red" or "blue"
    self.label = self:getLabel()        -- I, T, G, C
    self.q = q or nil
    self.r = r or nil
end

function Piece:getLabel()
    if self.type == "horse" then return "C" end
    if self.type == "commander" then return "K" end
    return self.type:sub(1, 1):upper()
end

function Piece:getColor()
    if self.team == "red" then return {1, 0, 0}
    else return {0, 0.4, 1} end
end

function Piece:render(x, y, font)
    local r, g, b = self:getColor()
    love.graphics.setColor(r, g, b)
    love.graphics.setFont(font)
    love.graphics.print(self.label, x, y)
    love.graphics.setColor(1, 1, 1)
end

function Piece:setPosition(q, r)
    self.q = q
    self.r = r
end

function Piece:canMoveTo(q, r)
    local tile = getTile(q, r)
    if not tile or tile.occupied then
        return false
    end

    local neighbors = getNeighbors(self.q, self.r)
    for _, neighbor in ipairs(neighbors) do
        if neighbor.q == q and neighbor.r == r then
            return true
        end
    end

    return false
end

