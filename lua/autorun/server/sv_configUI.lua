local addNetwork = util.AddNetworkString
local receive = net.Receive
local format = string.format

local function normalizeCmd(str)
    return string.Trim(string.lower(str or ""))
end

addNetwork("BetterBuild_OpenConfig")
addNetwork("BetterBuild_SaveConfig")

hook.Add("PlayerSay", "BetterBuild.OpenConfigPanel", function(ply, text)
    if normalizeCmd(text) ~= "!buildconfig" then return end
    if not ply:IsSuperAdmin() then return "" end
    
    net.Start("BetterBuild_OpenConfig")
    net.Send(ply)
    
    return ""
end)

receive("BetterBuild_SaveConfig", function(len, ply)
    if not ply:IsSuperAdmin() then return end
    
    local configs = net.ReadTable()
    
    for cvar, value in pairs(configs) do
        RunConsoleCommand(cvar, tostring(value))
    end
    
    BuildSystem:print(format("%s saved build config", ply:Nick()))
end)