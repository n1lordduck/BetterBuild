print("[BetterBuild] LOADER EXECUTED")

include("autorun/shared/sh_framework.lua")
AddCSLuaFile("autorun/shared/sh_framework.lua")

if SERVER then
    local serverFiles = {
        "sv_build.lua",
        "sv_configUI.lua"
    }

    for _, f in ipairs(serverFiles) do
        print("[BetterBuild] [OK] autorun/server/" .. f)
        include("autorun/server/" .. f)
    end

    local clientFiles = {
        "cl_configUI.lua",
        "cl_draw.lua",
        "cl_shouts.lua"
    }

    for _, f in ipairs(clientFiles) do
        print("[BetterBuild] [OK] autorun/client/" .. f)
        AddCSLuaFile("autorun/client/" .. f)
    end
end

if CLIENT then
    local clientFiles = {
        "cl_configUI.lua",
        "cl_draw.lua",
        "cl_shouts.lua"
    }

    for _, f in ipairs(clientFiles) do
        print("[BetterBuild] [OK] autorun/client/" .. f)
        include("autorun/client/" .. f)
    end
end