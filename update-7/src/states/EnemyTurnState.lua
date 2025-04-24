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
    if self.timer < self.actionDelay then return end
    self.timer = 0

    -- Try units one by one until one acts or all fail
    while self.unitIndex <= #self.teamUnits do
        local unit = self.teamUnits[self.unitIndex]

        if unit then
            Helpers.selectUnit(unit)

            -- 1. Try melee attack
            local meleeTargets = getAttackableTilesMelee(unit.q, unit.r, unit)
            if #meleeTargets > 0 then
                local target = meleeTargets[1]
                if Helpers.resolveAttack(unit, target.q, target.r) then
                    gStateMachine:change('player-turn', { team = 'blue' })
                    return
                end
            end

            -- 2. Try ranged attack (if applicable)
            if unit.isRanged then
                local rangedTargets = getAttackableTilesRanged(unit.q, unit.r, unit)
                if #rangedTargets > 0 then
                    local target = rangedTargets[1]
                    if Helpers.resolveAttack(unit, target.q, target.r) then
                        gStateMachine:change('player-turn', { team = 'blue' })
                        return
                    end
                end
            end

            -- 3. Try move
            local validMoves = unit:getValidMoves()
            if #validMoves > 0 then
                local tile = validMoves[1]
                if moveUnit(unit.q, unit.r, tile.q, tile.r) then
                    gStateMachine:change('player-turn', { team = 'blue' })
                    return
                end
            end
        end

        -- Skip to next unit
        self.unitIndex = self.unitIndex + 1
    end

    -- All units exhausted or no valid actions → end turn
    gStateMachine:change('player-turn', { team = 'blue' })
end

function EnemyTurnState:render()
    love.graphics.print(self.team .. "'s Turn (AI)", 10, 10)
end

function EnemyTurnState:exit() end
