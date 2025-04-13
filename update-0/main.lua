_G.love = require 'love'
---@diagnostic disable-next-line: lowercase-global


-- all the libraries are store here
require 'src/Dependencies'

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- seed the RNG so that calls to random are always random
    math.randomseed(os.time())

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT)
end

function love.update(dt)

end

function love.draw()
    push:start()

    -- draw hexes here
    drawHex(VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2, 40)


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