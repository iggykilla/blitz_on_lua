EnemyTurnState = Class{}

function EnemyTurnState:init() end

function EnemyTurnState:enter(params)
    self.team = params.team
    self.unitIndex = 1
    self.teamUnits = {}

    for _, unit in ipairs(placedUnits) do
        if unit.team == self.team then
            table.insert(self.teamUnits, unit)
        end
    end

    self.timer = 0
    self.actionDelay = 0.5

    -- select first enemy unit
    Helpers.selectUnit(self.teamUnits[self.unitIndex])
end

function EnemyTurnState:update(dt)
    self.timer = self.timer + dt

    if self.timer >= self.actionDelay then
        self.timer = 0

        -- pretend to "act", just move to next unit for now
        self.unitIndex = self.unitIndex + 1

        if self.unitIndex > #self.teamUnits then
            -- end turn (replace this with actual state switch later)
            gStateMachine:change('player-turn', { team = 'blue' })
        else
            Helpers.selectUnit(self.teamUnits[self.unitIndex])
        end
    end
end

function EnemyTurnState:render()
    love.graphics.print(self.team .. "'s Turn (AI)", 10, 10)
end

function EnemyTurnState:exit() end
