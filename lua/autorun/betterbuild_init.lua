print("[BetterBuild] LOADER EXECUTED")

include("autorun/shared/sh_framework.lua")
AddCSLuaFile("autorun/shared/sh_framework.lua")

if SERVER then
    local files = file.Find("autorun/server/*.lua", "LUA")

    table.sort(files)

    for _, f in ipairs(files) do
        print("[BetterBuild] [OK] autorun/server/" .. f)
        include("autorun/server/" .. f)
    end

    local cfiles = file.Find("autorun/client/*.lua", "LUA")

    table.sort(cfiles)

    for _, f in ipairs(cfiles) do
        print("[BetterBuild] [OK] autorun/client/" .. f)
        AddCSLuaFile("autorun/client/" .. f)
    end
end

if CLIENT then
    local files = file.Find("autorun/client/*.lua", "LUA")

    table.sort(files)

    for _, f in ipairs(files) do
        print("[BetterBuild] [OK] autorun/client/" .. f)
        include("autorun/client/" .. f)
    end
end