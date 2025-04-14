_G.love = require 'love'
---@diagnostic disable-next-line: lowercase-global


-- all the libraries are store here
require 'src/Dependencies'

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- seed the RNG so that calls to random are always random
    math.randomseed(os.time())

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,    -- or true if you want fullscreen
        resizable = true,     -- true if you want dynamic resizing
        vsync = true,          -- smooth frames
        canvas = true         -- false = better for sharp lines
    })
end

function love.update(dt)

end

function love.draw()
    push:start()

    -- draw hexes here
    local offsetX = VIRTUAL_WIDTH / 2
    local offsetY = VIRTUAL_HEIGHT / 2

    for _, hex in ipairs(generateHexGrid()) do
        local x, y = hexToPixel(hex.q, hex.r)
        drawHex(x + offsetX, y + offsetY, HEX_RADIUS)
    end

    push:finish()
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    -- keys can be accessed by string name
    if key == 'escape' then
        -- function LÖVE gives us to terminate application
        love.event.quit()
    end
end