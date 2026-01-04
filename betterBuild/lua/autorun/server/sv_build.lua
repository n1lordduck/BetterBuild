local CVAR_SERVER = FCVAR_ARCHIVE + FCVAR_NOTIFY

local CVAR_SHARED = FCVAR_ARCHIVE + FCVAR_NOTIFY + FCVAR_REPLICATED

CreateConVar("betterbuild_text", "Building", CVAR_SHARED, "The text that's gonna apear above the player")
CreateConVar("betterbuild_font", "DermaDefault", CVAR_SHARED, "Font")
CreateConVar("betterbuild_textcolor", "255, 165, 0", CVAR_SHARED, "The RGB color of the building text")
CreateConVar("betterbuild_enterBuildCommand", "!build", CVAR_SERVER, "The command to toggle build mode (You can just do it again to leave/enter build mode)")
CreateConVar("betterbuild_enterLeaveCommand", "!pvp", CVAR_SERVER, "The command to leave build mode (You can just do it again to leave/enter build mode)")
CreateConVar("betterbuild_chatCooldown", "5", CVAR_SERVER, "The chat commands cooldown")
    
CreateConVar("betterbuild_announceEnteringBuildMode", "true", CVAR_SERVER, "If the server should tell everyone who's entering build mode")
CreateConVar("betterbuild_announceEnterMessage", "{addonprefix} {player} has entered build mode!", CVAR_SERVER, "How the entering notification message should look like, feel free to remove addon prefix!")
CreateConVar("betterbuild_announceEnterMessageColor", "255 255 255", CVAR_SERVER, "The color in RGB of the entering notification message")

CreateConVar("betterbuild_announceExitingBuildMode", "true", CVAR_SERVER, "If the server should tell everyone who's leaving build mode")
CreateConVar("betterbuild_announceExitMessage", "{addonprefix} {player} has left build mode!", CVAR_SERVER, "How the leaving notification message should look like, feel free to remove addon prefix!")
CreateConVar("betterbuild_announceExitMessageColor", "255 255 255", CVAR_SERVER, "The color in RGB of the exit notification message")


CreateConVar("betterbuild_detectPVP", "true", CVAR_SERVER, "Only players that aren't actively taking or giving damage can enter buildmode")
CreateConVar("betterbuild_pvpCooldown", "60", CVAR_SERVER, "Time in seconds after combat before leaving PVP mode")
CreateConVar("betterbuild_pvpWarningMessage", "You can't join build mode while in combat!", CVAR_SHARED, "Warning message that will be displayed to the player if he tries to enter build in combat")

--// todo: improve
CreateConVar(
    "betterbuild_allowNoclipOutsideBuildMode",
    "false",
    CVAR_SERVER,
    "If false, players can only noclip while in build mode"
)

local addNetwork = util.AddNetworkString
local receive = net.Receive
local format = string.format

local BuildingPlayers = {}
local PvpPlayers = {}

addNetwork("BetterBuild_ChatMsg")
addNetwork("Betterbuild_enter")
addNetwork("BetterBuild_warning")
addNetwork("BetterBuild_SyncAll")

local function toBool(cvar)
    local val = cvar:GetString():lower()
    return val == "true" or val == "1"
end



local function warning(ply)
    local message = GetConVar("betterbuild_pvpWarningMessage"):GetString()
    
    net.Start("BetterBuild_warning")
    net.WriteString(message)
    net.Send(ply)
end

local function parseColor(str)
    local r, g, b = string.match(str, "(%d+)%s*[, ]%s*(%d+)%s*[, ]%s*(%d+)")
    return Color(
        tonumber(r) or 255,
        tonumber(g) or 255,
        tonumber(b) or 255,
        255
    )
end

local function shout(ply)
    if not toBool(GetConVar("betterbuild_announceEnteringBuildMode")) then return end
    
    local template = GetConVar("betterbuild_announceEnterMessage"):GetString()
    local msg = string.gsub(template, "{player}", ply:Nick())
    local showPrefix = string.find(msg, "{addonprefix}") ~= nil
    msg = string.gsub(msg, "{addonprefix}", "")
    msg = string.Trim(msg)
    
    local color = parseColor(GetConVar("betterbuild_announceEnterMessageColor"):GetString())
    
    net.Start("BetterBuild_ChatMsg")
    net.WriteString(msg)
    net.WriteBool(showPrefix)
    net.WriteColor(color)
    net.Broadcast()
end

local function shout_leave(ply)
    if not toBool(GetConVar("betterbuild_announceExitingBuildMode")) then return end
    
    local template = GetConVar("betterbuild_announceExitMessage"):GetString()
    local msg = string.gsub(template, "{player}", ply:Nick())
    local showPrefix = string.find(msg, "{addonprefix}") ~= nil
    msg = string.gsub(msg, "{addonprefix}", "")
    msg = string.Trim(msg)
    
    local color = parseColor(GetConVar("betterbuild_announceExitMessageColor"):GetString())
    
    net.Start("BetterBuild_ChatMsg")
    net.WriteString(msg)
    net.WriteBool(showPrefix)
    net.WriteColor(color)
    net.Broadcast()
end

local function toggleBuildMode(ply)
    local steamID = ply:SteamID64()

    if PvpPlayers[steamID] then
        BuildSystem:print(format("%s is in combat right now, declining request", ply:Nick()))
        warning(ply)
        return 
    end

    if BuildingPlayers[steamID] then 
        BuildSystem:print(format("Removed %s from buildmode", ply:Nick()))
        BuildingPlayers[steamID] = nil 
        ply:SetNWBool("InBuildMode", false)
        shout_leave(ply)
        return 
    end 

    BuildSystem:print(format("Added %s to build mode", ply:Nick()))

    BuildingPlayers[steamID] = true 
    ply:SetNWBool("InBuildMode", true)

    shout(ply)

end

receive("Betterbuild_enter", function(len, ply)
    BuildSystem:print(format("Received build_mode request from %s", ply:Nick()))
    BuildSystem:print("Len: " .. len)

    toggleBuildMode(ply)

    
end)

local function getEntityOwner(ent)
    if not IsValid(ent) then return nil end
    
    if ent.CPPIGetOwner then
        local owner = ent:CPPIGetOwner()
        if IsValid(owner) then return owner end
    end
    
    if ent.FPPOwner then
        local owner = Player(ent.FPPOwner)
        if IsValid(owner) then return owner end
    end
    
    local owner = ent:GetOwner()
    if IsValid(owner) then return owner end
    
    if ent:IsVehicle() then
        local driver = ent:GetDriver()
        if IsValid(driver) then return driver end
    end
    
    return nil
end

hook.Add("EntityTakeDamage", "BetterBuild.PreventDamage", function(target, dmg)
    if not IsValid(target) then return end
    
    local attacker = dmg:GetAttacker()
    if not IsValid(attacker) then return end 
    
    local inflictor = dmg:GetInflictor()
    if not IsValid(inflictor) then return end
    
    local attackerID = attacker:IsPlayer() and attacker:SteamID64() or nil
    local targetID = target:IsPlayer() and target:SteamID64() or nil
    
    if (attackerID and BuildingPlayers[attackerID]) or (targetID and BuildingPlayers[targetID]) then
        dmg:SetDamage(0)
        return true
    end
    
   
    local inflictorClass = inflictor:GetClass()
    if inflictorClass == "prop_physics" or inflictor:IsVehicle() then
        local owner = getEntityOwner(inflictor)
        if IsValid(owner) and owner:IsPlayer() then
            if BuildingPlayers[owner:SteamID64()] then
                dmg:SetDamage(0)
                return true
            end
        end
    end
    
    if attacker:IsVehicle() then
        local driver = attacker:GetDriver()
        if IsValid(driver) and driver:IsPlayer() then
            if BuildingPlayers[driver:SteamID64()] then
                dmg:SetDamage(0)
                return true
            end
        end
    end
end)

hook.Add("PlayerHurt", "BetterBuild.DetectPVP", function(victim, attacker, healthRemaining, damageTaken)
    if not IsValid(victim) or not IsValid(attacker) then return end 

    local filterPvP = toBool(GetConVar("betterbuild_detectPVP"))

    if not filterPvP then return end 
    
    local pvpCooldown = GetConVar("betterbuild_pvpCooldown"):GetInt()

    --// BuildSystem:print(victim)
    
    if not victim:IsPlayer() or not attacker:IsPlayer() then return end
    
    local victimSteamID = victim:SteamID64()
    local attackerSteamID = attacker:SteamID64()
    
    if BuildingPlayers[victimSteamID] or BuildingPlayers[attackerSteamID] then return end 
    
    PvpPlayers[victimSteamID] = true 
    PvpPlayers[attackerSteamID] = true 
    
    timer.Create("PVP_COOLDOWN_" .. victimSteamID, pvpCooldown, 1, function()
        PvpPlayers[victimSteamID] = nil
    end)
    
    timer.Create("PVP_COOLDOWN_" .. attackerSteamID, pvpCooldown, 1, function()
        PvpPlayers[attackerSteamID] = nil
    end)
end)

hook.Add("PlayerDisconnected", "BetterBuild.RemovePVPonExit", function(ply)
    local id = ply:SteamID64()
    BuildingPlayers[id] = nil
    PvpPlayers[id] = nil
    timer.Remove("PVP_COOLDOWN_" .. id)
end)

hook.Add("PlayerDeath", "BetterBuild.RemovePvP", function(victim)
    if not IsValid(victim) then return end 
    local steamID = victim:SteamID64()

    if timer.Exists("PVP_COOLDOWN_" .. steamID) then
        timer.Remove("PVP_COOLDOWN_" .. steamID)
    end

    PvpPlayers[steamID] = nil 
end)

local function normalizeCmd(str)
    return string.Trim(string.lower(str or ""))
end

local function canUseChatCommand(ply)
    local cd = GetConVar("betterbuild_chatCooldown"):GetFloat()
    if cd <= 0 then return true end

    ply._bbNextChatCmd = ply._bbNextChatCmd or 0

    if CurTime() < ply._bbNextChatCmd then
        return false
    end

    ply._bbNextChatCmd = CurTime() + cd
    return true
end

hook.Add("PlayerNoClip", "BetterBuild.RestrictNoclip", function(ply, desiredState)
    if tobool(GetConVar("betterbuild_allowNoclipOutsideBuildMode"):GetBool()) then
        return
    end

    local steamID = ply:SteamID64()

    if not BuildingPlayers[steamID] then
        return false
    end

end)

hook.Add("PlayerSay", "BetterBuild.ChatCommands", function(ply, text)
    local msg = normalizeCmd(text)

    local buildCmd = normalizeCmd(GetConVar("betterbuild_enterBuildCommand"):GetString())
    local leaveCmd = normalizeCmd(GetConVar("betterbuild_enterLeaveCommand"):GetString())

    if msg ~= buildCmd and msg ~= leaveCmd then
        return
    end

    if not canUseChatCommand(ply) then
        return ""
    end

    toggleBuildMode(ply)
    return ""
end)

--// this is needed as the player won't necessarily have the addon installed and cl_draw will error as it can't fetch convarss
--// todo: improve heavily

local function sendConfig(ply)
    net.Start("BetterBuild_SyncAll")
        net.WriteString(GetConVar("betterbuild_text"):GetString())
        net.WriteString(GetConVar("betterbuild_font"):GetString())
        net.WriteColor(parseColor(GetConVar("betterbuild_textcolor"):GetString()))
        net.WriteString(GetConVar("betterbuild_pvpWarningMessage"):GetString())
    if ply then
        net.Send(ply)
    else
        net.Broadcast()
    end
end

hook.Add("PlayerInitialSpawn", "BetterBuild.SyncOnJoin", function(ply)
    timer.Simple(2, function()
        if IsValid(ply) then
            sendConfig(ply)
        end
    end)
end)

--// re-sync
cvars.AddChangeCallback("betterbuild_text", function() sendConfig() end, "BB_Sync_Text")
cvars.AddChangeCallback("betterbuild_font", function() sendConfig() end, "BB_Sync_Font")
cvars.AddChangeCallback("betterbuild_textcolor", function() sendConfig() end, "BB_Sync_Color")
cvars.AddChangeCallback("betterbuild_showBuildTextonHover", function() sendConfig() end, "BB_Sync_Hover")
cvars.AddChangeCallback("betterbuild_pvpWarningMessage", function() sendConfig() end, "BB_Sync_Warning")
