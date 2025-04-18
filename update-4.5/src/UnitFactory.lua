return function(unitType, team, q, r)
    if unitType == "infantry" then
        return Infantry(team, q, r)
    
    elseif unitType == "tank" then
        return Tank(team, q, r)
    
    elseif unitType == "horse" then
        return Horse(team, q, r)
    
    elseif unitType == "general" then
        return General(team, q, r)
    
    elseif unitType == "commander" then
        return Commander(team, q, r)
    
    else
        error("Unknown unit type: " .. tostring(unitType))
    end
end