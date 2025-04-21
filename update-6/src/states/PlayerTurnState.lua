PlayerTurnState = Class{}

function PlayerTurnState:init() end

function PlayerTurnState:enter(params)
    self.team = params.team
    self.unitIndex = 1
    self.teamUnits = {}

    -- cache all units belonging to this team
    for i, unit in ipairs(placedUnits) do
        if unit.team == self.team then
            table.insert(self.teamUnits, unit)
        end
    end

    Helpers.selectUnit(self.teamUnits[self.unitIndex])

end

function PlayerTurnState:update(dt)
    if love.keyboard.wasPressed("m") then
        moveUnit(2, 0, 2, -1)
    elseif love.keyboard.wasPressed("n") then
        moveUnit(2, 0, 1, 0)
    elseif love.keyboard.wasPressed("tab") then
        -- cycle to the next unit on the same team
        self.unitIndex = self.unitIndex + 1
        if self.unitIndex > #self.teamUnits then
            self.unitIndex = 1
        end

        Helpers.selectUnit(self.teamUnits[self.unitIndex])
    end
end

function PlayerTurnState:render()
    love.graphics.print(self.team .. "'s Turn", 10, 10)
end

function PlayerTurnState:exit() end