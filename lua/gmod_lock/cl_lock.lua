print("Client lock")

function LOCKSYSTEM:Activate(lockName)
    local lock = self.Locks[lockName]
    if not lock then return end

    local onActivate = lock["onActivate"]
    if not onActivate then return end

    onActivate(lockName)
end

function LOCKSYSTEM:CheckResult(lockName, result)
    net.Start("Lock.CheckResult")
        net.WriteString(lockName)
        net.WriteTable(result)
    net.SendToServer()
end

function LOCKSYSTEM:OnGetResponse(lockName, response)
    local lock = self.Locks[lockName]
    if not lock then return end

    if response then
        local onSuccess = lock["onSuccess"]
        if not onSuccess then return end

        onSuccess()
    else
        local onFail = lock["onFail"]
        if not onFail then return end

        onFail()
    end
end

net.Receive("Lock.Activate", function (len, ply)
    local lockName = net.ReadString()
    local data = net.ReadTable()

    LOCKSYSTEM:Activate(lockName, data)
end)

net.Receive("Lock.CheckResult", function (len)
    local lockName = net.ReadString()
    local response = net.ReadBool()

    LOCKSYSTEM:OnGetResponse(lockName, response)
end)