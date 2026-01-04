---@class BuildSystem
---@field Version string
BuildSystem = BuildSystem or {}
BuildSystem.Version = "[BetterBuild - 1.0.0]"

BuildSystem.Colors = {
    ["Server"] = Color(13, 221, 176),
    ["Client"] = Color(6, 240, 37),
    ["Version"] = Color(0, 153, 255)
}

---@param arg any
---@return nil
function BuildSystem:print(arg)
    local msg = ""
    
    if IsValid(arg) and arg:IsPlayer() then
        msg = msg .. " [PLAYER] " .. arg:Nick()
    elseif IsValid(arg) then
        msg = msg .. " [ENTITY] " .. arg:GetClass()
    elseif isstring(arg) then
        msg = msg .. " " .. arg
    end
    
    if SERVER then
        MsgC(
            BuildSystem.Colors["Version"], self.Version,
            BuildSystem.Colors["Server"], " [SERVER]",
            color_white, msg, "\n"
        )
    end
    
    if CLIENT then
        MsgC(
            BuildSystem.Colors["Version"], self.Version,
            BuildSystem.Colors["Client"], " [CLIENT]",
            color_white, msg, "\n"
        )
    end
end

