local function OnActivate(ply)
    local numbers = {1, 2, 3, 4}

    local dataToSend = {}

    for i=1, 4 do
        local n = table.Random(numbers)
        table.RemoveByValue(numbers, n)

        table.insert(dataToSend, {n, 0})
    end
    
    return {}, dataToSend
end

local function OnSucces(ply, door)
    door:Fire("Unlock")
    door:Fire("Open")
end 

local function OnFail(ply)

end

local function CheckResults(result, data)
    for k, wire in ipairs(result) do
        if wire[1] ~= wire[2] then return false end
    end
    
    return true
end

LOCKSYSTEM:RegisterLock("lock_2", OnActivate, OnSucces, OnFail, CheckResults)