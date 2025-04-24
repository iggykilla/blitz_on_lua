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

            -- 1) Gather all *valid* attacks (both melee & ranged)
            local validAttacks = unit:computeValidAttacks()

            if #validAttacks > 0 then
                -- separate into melee (dist==1) and ranged (dist>1)
                local meleeTargets, rangedTargets = {}, {}
                for _, t in ipairs(validAttacks) do
                    local d = HexMath.hexDistance(unit.q, unit.r, t.q, t.r)
                    if d == 1 then
                        table.insert(meleeTargets, t)
                    elseif unit.isRanged and d > 1 then
                        table.insert(rangedTargets, t)
                    end
                end

                -- 2) Prefer melee, then ranged
                local choice = nil
                if #meleeTargets > 0 then
                    choice = meleeTargets[1]
                elseif #rangedTargets > 0 then
                    choice = rangedTargets[1]
                end

                if choice then
                    if Helpers.resolveAttack(unit, choice.q, choice.r) then
                        gStateMachine:change('player-turn', { team = 'blue' })
                        return
                    end
                end
            end

            -- 3) No attack possible → try moving
            local validMoves = unit:getValidMoves()
            if #validMoves > 0 then
                local moveTo = validMoves[1]
                if moveUnit(unit.q, unit.r, moveTo.q, moveTo.r) then
                    gStateMachine:change('player-turn', { team = 'blue' })
                    return
                end
            end
        end

        -- Skip to next unit
        self.unitIndex = self.unitIndex + 1
    end

    -- All units exhausted / no actions left → end turn
    gStateMachine:change('player-turn', { team = 'blue' })
end

function EnemyTurnState:render()
    love.graphics.print(self.team .. "'s Turn (AI)", 10, 10)
end

function EnemyTurnState:exit() end
