local function OnActivate(ply)
    local angle = math.Rand(0, -math.pi)
    local offset = math.pi / 80
    local min = angle - offset
    local max = angle + offset
    
    return {min, max}, {angle}
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

    return numberResult >= data[1] and numberResult <= data[2]
end

LOCKSYSTEM:RegisterLock("lock_1", OnActivate, OnSucces, OnFail, CheckResults)