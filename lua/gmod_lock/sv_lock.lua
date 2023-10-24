util.AddNetworkString("Lock.CheckResult")
util.AddNetworkString("Lock.Activate")

local propDoorRotating = "prop_door_rotating"

function LOCKSYSTEM:CheckResult(ply, lockName, result)
    local lock = self.Locks[lockName]
    if not lock then return end

    local checkResult = lock["checkResult"]
    local data = lock["data"]

    local response = checkResult(result, data)

    local door = lock["Door"]
    if not IsValid(door) then return end

    if response then
        local onSuccess = lock["onSuccess"]
        if onSuccess then
            onSuccess(ply, door)
        end
    else
        local onFail = lock["onFail"]
        if onFail then
            onFail(ply)
        end
    end

    net.Start("Lock.CheckResult")
        net.WriteString(lockName)
        net.WriteBool(response)
    net.Send(ply)
end

function LOCKSYSTEM:CallLock(ply, lockName, door)
    if not IsValid(door) or not IsValid(ply) then return end
    
    local lock = self.Locks[lockName]
    if not lock then return end

    local onActivate = lock["onActivate"]
    if not onActivate then return end

    local data, dataToSend = onActivate(ply)

    lock["data"] = data or {}
    lock["dataToSend"] = dataToSend or {}
    lock["Door"] = door

    net.Start("Lock.Activate")
        net.WriteString(lockName)
        net.WriteTable(lock["dataToSend"])
    net.Send(ply)

    return true
end

net.Receive("Lock.CheckResult", function (len, ply)
    if not IsValid(ply) then return end

    local lockName = net.ReadString()
    local result = net.ReadTable()

    LOCKSYSTEM:CheckResult(ply, lockName, result)
end)

concommand.Add("lock_alldoors", function (ply)
    if not IsValid(ply) then return end

    local doors = ents.FindByClass(propDoorRotating)
    for _, door in ipairs(doors) do
        if not IsValid(door) then continue end

        door:Fire("Lock")
    end
end)