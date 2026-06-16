include("autorun/shared/sh_framework.lua")
AddCSLuaFile("autorun/shared/sh_framework.lua")

if SERVER then
    local files, dirs = file.Find("autorun/server/*.lua", "LUA")

    for _, f in ipairs(files) do
        include("autorun/server/" .. f)
    end

    local subdirs = { "db", "interfaces", "reports" }

    for _, dir in ipairs(subdirs) do
        local sfiles = file.Find("autorun/server/" .. dir .. "/*.lua", "LUA")
        for _, f in ipairs(sfiles) do
            include("autorun/server/" .. dir .. "/" .. f)
        end
    end

    local cfiles = file.Find("autorun/client/*.lua", "LUA")
    for _, f in ipairs(cfiles) do
        AddCSLuaFile("autorun/client/" .. f)
    end
end


if CLIENT then
    local function loadAddon()
        BuildSystem:print("Loading client scripts")
        
        local files = file.Find("autorun/client/*.lua", "LUA")
        for _, f in ipairs(files) do
            AddCSLuaFile("autorun/client/" .. f)
        end

        BuildSystem:print("Loaded successfully!")
    end

    loadAddon()
end
