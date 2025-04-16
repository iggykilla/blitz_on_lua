--[[
    Piece:init(unitType, team, q, r)
    Piece:getLabel()
    Piece:getColor()
    Piece:render(x, y, font)
    Piece:setPosition(q, r)
    Piece:canMoveTo(q, r)
]]

Piece = Class{}

function Piece:init(unitType, team, q, r)
    self.type = unitType                -- e.g., "infantry", "tank"
    self.team = team                    -- "red" or "blue"
    self.label = self:getLabel()        -- I, T, G, C
    self.q = q or nil
    self.r = r or nil
end

function Piece:getLabel()
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
    for _, tile in ipairs(self:getValidMoves()) do
        if tile.q == q and tile.r == r and not tile.occupied then
            return true
        end
    end
    return false
end

function Piece:getValidMoves()
    return {} -- Base unit can’t move
end
