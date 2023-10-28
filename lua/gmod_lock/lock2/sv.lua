local function OnActivate(ply)
    return {}, {}
end

local function OnSucces(ply, door)
    door:Fire("Unlock")
    door:Fire("Open")
end 

local function OnFail(ply)

end

local function CheckResults(result, data)
    
    
    return true
end

LOCKSYSTEM:RegisterLock("lock_2", OnActivate, OnSucces, OnFail, CheckResults)