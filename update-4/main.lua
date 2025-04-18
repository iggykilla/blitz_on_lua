_G.love = require 'love'
---@diagnostic disable-next-line: lowercase-global

-- all the libraries are store here
require 'src/Dependencies'

function love.load()
    debug.log("Game started")
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- seed the RNG so that calls to random are always random
    math.randomseed(os.time())

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,    -- or true if you want fullscreen
        resizable = true,      -- true if you want dynamic resizing
        vsync = true,          -- smooth frames
        canvas = false         -- false = better for sharp lines
    })

    local offsetX = VIRTUAL_WIDTH / 2
    local offsetY = VIRTUAL_HEIGHT / 2

    tilesByCoordinates = {} -- define this first so tiles = generateHexGrid can populate
    tiles = generateHexGrid(offsetX, offsetY) -- ✅ store your tile data
    
    -- safe setup of test unit

    -- blue back row
    placeUnit(0, 0, "tank", "blue")
    placeUnit(4, 0, "general", "blue")
    placeUnit(3, 0, "commander", "blue")
    placeUnit(2, 2, "horse", "blue")

    -- blue infantry
    local blue_infantry_placement = {{2,-1}, {2,0}}
    for _, pos in ipairs(blue_infantry_placement) do
        placeUnit(pos[1], pos[2], "infantry", "blue")
    end

    smallFont = love.graphics.newFont(8)
    mediumFont = love.graphics.newFont(20)
    
    -- Get all placed units
    placedUnits = {}

    for _, tile in ipairs(tiles) do
        if tile.unit then
            table.insert(placedUnits, tile.unit)
        end
    end

    unitIndex = 1
    selectedUnit = placedUnits[unitIndex]
    selectedQ = selectedUnit.q
    selectedR = selectedUnit.r

--[[
    -- tracks tile state 
    debug.logAllTiles(tiles)
        
    -- test tilesByCoordinates
    local test = getTile(4, 0)
    if test then
        debug.log("Test getTile(4,0): unit = " .. (test.unit and test.unit.type or "none"))
    else
        debug.log("Test getTile(4,0): tile not found")
    end]]
    
end

function love.update(dt)

end

function love.draw()
    push:start()
    love.graphics.setFont(smallFont)

    -- draw all hexes
    for _, tile in ipairs(tiles) do
        Visuals.drawTile(tile, smallFont, mediumFont)
    end

     -- highlight selected unit's moves
    if selectedUnit then
        Visuals.highlightValidMovesFor(selectedUnit)
    end

    -- Draw selected unit info
    if selectedUnit then
        local label = string.format("Selected: %s (%s)", selectedUnit:getName(), selectedUnit.team)
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(mediumFont)
        love.graphics.print(label, 10, VIRTUAL_HEIGHT - 30)
    end

    love.graphics.setColor(1, 1, 1)
    push:finish()
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    if key == "m" then
        moveUnit(2, 0, 2, -1)
    elseif key == "n" then
        moveUnit(2, 0, 1, 0)
    elseif key == "escape" then
        love.event.quit()
    elseif key == "tab" then
        unitIndex = unitIndex + 1
        if unitIndex > #placedUnits then
            unitIndex = 1
        end
        selectedUnit = placedUnits[unitIndex]
        selectedQ = selectedUnit.q
        selectedR = selectedUnit.r
    end
end