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
    placeUnit(4, -2, "horse", "blue")
    placeUnit(4, -1, "tank",  "blue")
    placeUnit(4, 0, "general", "blue")
    placeUnit(3, 0, "commander", "blue")
    placeUnit(3, 1, "tank",  "blue")
    placeUnit(2, 2, "horse", "blue")

    -- blue infantry
    local blue_infantry_placement = {{1,3}, {1,2}, {2,1}, {2,0}, {2,-1}, {3,-2}, {4,-3}}
    for _, pos in ipairs(blue_infantry_placement) do
        placeUnit(pos[1], pos[2], "infantry", "blue")
    end
    
    -- red back row
    placeUnit(-4, 2, "horse", "red")
    placeUnit(-4, 1, "tank",  "red")
    placeUnit(-4, 0, "general", "red")
    placeUnit(-3, 0, "commander", "red")
    placeUnit(-3, -1, "tank",  "red")
    placeUnit(-2, -2, "horse", "red")

    -- red infantry
    local red_infantry_placement = {{-1,-3}, {-1,-2}, {-2,-1}, {-2,0}, {-3,1}, {-3,2}, {-4,3}}
    for _, pos in ipairs(red_infantry_placement) do
        placeUnit(pos[1], pos[2], "infantry", "red")
    end

    smallFont = love.graphics.newFont(8)
    mediumFont = love.graphics.newFont(20)
    
    --[[ 
        tracks tile state
    debug.logAllTiles(tiles)
        
        test tilesByCoordinates
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
        drawHex(tile.x, tile.y, HEX_RADIUS)

        local label = string.format("%d,%d", tile.q, tile.r)
        local textWidth = smallFont:getWidth(label)
        local textHeight = smallFont:getHeight()
        love.graphics.setFont(smallFont)
        love.graphics.print(label, tile.x + HEX_RADIUS / 2 - textWidth, tile.y - HEX_RADIUS / 2 - textHeight)
    
        if tile.unit then
            local label = tile.unit.label
            local textWidth = mediumFont:getWidth(label)
            local textHeight = mediumFont:getHeight()
        
            tile.unit:render(tile.x - textWidth / 2, tile.y - textHeight / 2, mediumFont)
        end
    end

    -- DEBUG: Highlight all neighbors of selected tile
    local selectedTileQ, selectedTileR = 2, 0
    local from = getTile(selectedTileQ, selectedTileR)

    if from and from.unit then
        for _, tile in ipairs(getNeighbors(selectedTileQ, selectedTileR)) do
            if from.unit:canMoveTo(tile.q, tile.r) then
                love.graphics.setColor(0, 1, 0, 0.4) -- green for valid
            elseif tile.occupied then
                love.graphics.setColor(1, 0, 0, 0.4) -- red for occupied
            else
                love.graphics.setColor(1, 1, 0, 0.3) -- optional: yellow for invalid
            end

            love.graphics.circle("fill", tile.x, tile.y, HEX_RADIUS / 3)
        end

        love.graphics.setColor(1, 1, 1)
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
    end
end
