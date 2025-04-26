require 'src/HexBoard'

local BoardSetup = {}

local function placeUnits(units)
    for _, u in ipairs(units) do
        HexBoard:placeUnit(u.q, u.r, u.unitType, u.color)
    end
end

local function spawn(unitType, positions, team)
    local list = {}
    for _, pos in ipairs(positions) do
        table.insert(list, {unitType = unitType, q = pos[1], r = pos[2], color = team})
    end
    return list
end

function BoardSetup.setup()
    local blueUnits = BoardSetup.test_positions("blue")
    local redUnits = BoardSetup.test_positions("red")
    placeUnits(blueUnits)
    placeUnits(redUnits)
end

function BoardSetup.standard_positions(team)
    local color = team or "blue"
    local positions = {}

    if color == "blue" then
        for _, group in ipairs({
            spawn("infantry", {{4,-3}, {3,-2}, {3,-1}, {2,0}, {2,1}, {1,2}, {1,3}}, color),
            spawn("tank",     {{4,-1}, {3,1}}, color),
            spawn("horse",    {{4,-2}, {2,2}}, color),
            spawn("commander",{{3,0}}, color),
            spawn("general",  {{4,0}}, color)
        }) do
            for _, u in ipairs(group) do
                table.insert(positions, u)
            end
        end

    elseif color == "red" then
        for _, group in ipairs({
            spawn("infantry", {{-4,3}, {-3,2}, {-3,1}, {-2,0}, {-2,-1}, {-1,-2}, {-1,-3}, {1,0}}, color),
            spawn("tank",     {{-4,1}, {-3,-1}}, color),
            spawn("horse",    {{-4,2}, {-2,-2}}, color),
            spawn("commander",{{-3,0}}, color),
            spawn("general",  {{-4,0}}, color)
        }) do
            for _, u in ipairs(group) do
                table.insert(positions, u)
            end
        end
    end

    return positions
end

function BoardSetup.test_positions(team)
    local color = team or "blue"
    local positions = {}

    if color == "blue" then
        for _, group in ipairs({
            spawn("commander",{{3,0}}, color),
            spawn("general",  {{4,0}}, color)
        }) do
            for _, u in ipairs(group) do
                table.insert(positions, u)
            end
        end

    elseif color == "red" then
        for _, group in ipairs({
            spawn("general",  {{2,0}}, color)
        }) do
            for _, u in ipairs(group) do
                table.insert(positions, u)
            end
        end
    end

    return positions
end

return BoardSetup