LOCKSYSTEM = {}
LOCKSYSTEM.Locks = {}

function LOCKSYSTEM:RegisterLock(lockName, onActivate, onSuccess, onFail, checkResult)

    local lockSettings = {
        ["data"] = {},
        ["dataToSend"] = {},
        ["onActivate"] = onActivate,
        ["onSuccess"] = onSuccess,
        ["onFail"] = onFail,
        ["checkResult"] = checkResult
    }

    LOCKSYSTEM.Locks[lockName] = lockSettings
end
