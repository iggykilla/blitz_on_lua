local debuger = {}

function debuger.log(str)
    local file = io.open("debug_log.txt", "a")
    if file then
        file:write(os.date("[%H:%M:%S] ") .. tostring(str) .. "\n")
        file:close()
    end
end

function debuger.logAllTiles(tiles)
    debuger.log("=== Full Tile State ===")
    for _, tile in ipairs(tiles) do
        debuger.log("Tile at " .. tile.q .. "," .. tile.r)
        for k, v in pairs(tile) do
            debuger.log("  " .. k .. ": " .. tostring(v))
        end
        debuger.log("---")
    end
    debuger.log("=== End of Tile State ===")
end

return debuger
