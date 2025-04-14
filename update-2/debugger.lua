local debugger = {}

function debugger.log(str)
    local file = io.open("debug_log.txt", "a")
    if file then
        file:write(os.date("[%H:%M:%S] ") .. tostring(str) .. "\n")
        file:close()
    end
end

function debugger.logAllTiles(tiles)
    debugger.log("=== Full Tile State ===")
    for _, tile in ipairs(tiles) do
        debugger.log("Tile at " .. tile.q .. "," .. tile.r)
        for k, v in pairs(tile) do
            debugger.log("  " .. k .. ": " .. tostring(v))
        end
        debugger.log("---")
    end
    debugger.log("=== End of Tile State ===")
end

return debugger
