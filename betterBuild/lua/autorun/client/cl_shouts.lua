BuildSystem:print("Loaded cl_shouts!")

net.Receive("BetterBuild_ChatMsg", function()
    local msg = net.ReadString()
    local showPrefix = net.ReadBool()
    local msgColor = net.ReadColor()
    
    if showPrefix then
        chat.AddText(
            Color(255, 165, 0), "[Build] ",
            msgColor, msg
        )
    else
        chat.AddText(
            msgColor, msg
        )
    end
end)

net.Receive("BetterBuild_warning", function()
    local msg = net.ReadString()
    chat.AddText(
        Color(255, 0, 0), msg
    )
end)