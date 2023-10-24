local files, dirs = file.Find("gmod_lock/*", "LUA")

if SERVER then
    include("gmod_lock/sh_lock.lua")
    include("gmod_lock/sv_lock.lua")

    AddCSLuaFile("gmod_lock/sh_lock.lua")
    AddCSLuaFile("gmod_lock/cl_lock.lua")

    for _, dir in ipairs(dirs) do
        local path = "gmod_lock/" .. dir .. "/"

        include(path .. "sv.lua")
        AddCSLuaFile(path .. "cl.lua")
    end
end

if CLIENT then
    include("gmod_lock/sh_lock.lua")
    include("gmod_lock/cl_lock.lua")

    for _, dir in ipairs(dirs) do
        include("gmod_lock/" .. dir .. "/cl.lua")
    end
end