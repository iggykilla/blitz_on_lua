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
        -- Example: try to move 1 tile northeast
        local q, r = selectedQ, selectedR
        local dq, dr = 0, -1
        if moveUnit(q, r, q + dq, r + dr) then
            gStateMachine:change('enemy-turn', { team = 'red' })
        end

    elseif love.keyboard.wasPressed("a") then
        -- Example: melee attack north
        local q, r = selectedQ, selectedR
        local dq, dr = -1, 0
        if Helpers.resolveAttack(selectedUnit, q + dq, r + dr) then
            gStateMachine:change('enemy-turn', { team = 'red' })
        end

    elseif love.keyboard.wasPressed("r") then
        -- Example: ranged attack east
        local q, r = selectedQ, selectedR
        local dq, dr = 1, 0
        if Helpers.resolveAttack(selectedUnit, q + dq, r + dr) then
            gStateMachine:change('enemy-turn', { team = 'red' })
        end

    elseif love.keyboard.wasPressed("tab") then
        -- Cycle selected unit
        self.unitIndex = self.unitIndex + 1
        if self.unitIndex > #self.teamUnits then
            self.unitIndex = 1
        end
        Helpers.selectUnit(self.teamUnits[self.unitIndex])

    elseif love.keyboard.wasPressed("e") then
        gStateMachine:change('enemy-turn', { team = 'red' })
    end
end


function PlayerTurnState:render()
    love.graphics.print(self.team .. "'s Turn", 10, 10)
end

function PlayerTurnState:exit() end