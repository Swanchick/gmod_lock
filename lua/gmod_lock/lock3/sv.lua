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
    for k, v in ipairs(result) do
        if not v[2] then
            return false 
        end
    end
    
    return true
end

LOCKSYSTEM:RegisterLock("lock_3", OnActivate, OnSucces, OnFail, CheckResults)