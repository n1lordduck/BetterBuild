BetterBuild = BetterBuild or {}
BetterBuild.Config = BetterBuild.Config or {}

surface.CreateFont("BetterBuild_Display", {
    font   = "DermaDefault",
    size   = 18,
    weight = 500
})

net.Receive("BetterBuild_SyncAll", function()
    BetterBuild.Config.text    = net.ReadString()
    BetterBuild.Config.font    = net.ReadString()
    BetterBuild.Config.color   = net.ReadColor()
    BetterBuild.Config.warning = net.ReadString()
    
    surface.CreateFont("BetterBuild_Display", {
        font   = BetterBuild.Config.font,
        size   = 18,
        weight = 500
    })
end)

hook.Add("HUDPaint", "BetterBuild_DrawBillboardText", function()
    local lp = LocalPlayer()
    if not IsValid(lp) then return end

    local text = BetterBuild.Config.text
    if not text or text == "" then return end

    local localPos = lp:GetPos()
    local maxDist = 10 * 39.37 

    for _, ply in ipairs(player.GetAll()) do
        if ply == lp then continue end
        if not IsValid(ply) then continue end
        if not ply:GetNWBool("InBuildMode", false) then continue end

        local plyPos = ply:GetPos()
        local dist = localPos:Distance(plyPos)

        if dist > maxDist then continue end

        local pos = plyPos + Vector(0, 0, ply:OBBMaxs().z + 12)
        local scrPos = pos:ToScreen()

        if not scrPos.visible then continue end

        local col = BetterBuild.Config.color or color_white
        local x, y = scrPos.x, scrPos.y

        draw.SimpleTextOutlined(
            text,
            "BetterBuild_Display",
            x,
            y,
            col,
            TEXT_ALIGN_CENTER,
            TEXT_ALIGN_CENTER,
            1,
            Color(0, 0, 0, 200)
        )
    end
end)

concommand.Add("build_mode", function()
    net.Start("Betterbuild_enter")
    net.SendToServer()
end)
