local function OnActivate(ply)
    local rightAnswer = math.random(1, 10)
    
    return {rightAnswer}, {}
end

local function OnSucces(ply, door)
    door:Fire("Unlock")
    door:Fire("Open")
end 

local function OnFail(ply)

end

local function CheckResults(result, data)
    local numberResult = result[1]
    local rightAnswer = data[1]

    return tonumber(numberResult) == tonumber(rightAnswer)
end

LOCKSYSTEM:RegisterLock("lock_3", OnActivate, OnSucces, OnFail, CheckResults)