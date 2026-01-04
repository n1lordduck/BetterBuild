BetterBuild = BetterBuild or {}
BetterBuild.Config = BetterBuild.Config or {}

net.Receive("BetterBuild_SyncAll", function()
    BetterBuild.Config.text        = net.ReadString()
    BetterBuild.Config.font        = net.ReadString()
    BetterBuild.Config.color       = net.ReadColor()
    BetterBuild.Config.showOnHover = net.ReadBool()
    BetterBuild.Config.warning     = net.ReadString()

    surface.CreateFont("BetterBuild_Display", {
        font = BetterBuild.Config.font,
        size = 24,
        weight = 500
    })
end)

hook.Add("PostPlayerDraw", "BetterBuild_DrawBillboardText", function(ply)
    if not ply:GetNWBool("InBuildMode", false) then return end
    if not BetterBuild.Config.text then return end

    local pos = ply:GetPos() + Vector(0, 0, 85)

    local ang = EyeAngles()
    ang = Angle(0, ang.y - 90, 90)

    cam.Start3D2D(pos, ang, 0.25)
        draw.SimpleTextOutlined(
            BetterBuild.Config.text,
            "BetterBuild_Display",
            0,
            0,
            BetterBuild.Config.color or color_white,
            TEXT_ALIGN_CENTER,
            TEXT_ALIGN_TOP,
            1,
            color_black
        )
    cam.End3D2D()
end)

concommand.Add("build_mode", function()
    net.Start("Betterbuild_enter")
    net.SendToServer()
end)
