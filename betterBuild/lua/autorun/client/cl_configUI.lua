-- CLIENT
net.Receive("BetterBuild_OpenConfig", function()
    local scrW, scrH = ScrW(), ScrH()
    local panelW, panelH = 700, 600
    
    local frame = vgui.Create("DFrame")
    frame:SetSize(panelW, panelH)
    frame:Center()
    frame:SetTitle("")
    frame:SetDraggable(true)
    frame:ShowCloseButton(false)
    frame:MakePopup()
    
    frame.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(25, 25, 30))
        draw.RoundedBox(8, 0, 0, w, 50, Color(35, 35, 40))
        draw.SimpleText("Build Mode Configuration", "DermaLarge", w/2, 25, Color(255, 165, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    local closeBtn = vgui.Create("DButton", frame)
    closeBtn:SetText("")
    closeBtn:SetSize(40, 40)
    closeBtn:SetPos(panelW - 45, 5)
    closeBtn.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, self:IsHovered() and Color(200, 50, 50) or Color(150, 40, 40))
        draw.SimpleText("×", "DermaLarge", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    closeBtn.DoClick = function() frame:Close() end
    
    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:SetPos(20, 60)
    scroll:SetSize(panelW - 40, panelH - 130)
    
    local y = 10
    local configs = {}
    
    local function addSection(title)
        local lbl = vgui.Create("DLabel", scroll)
        lbl:SetText(title)
        lbl:SetFont("DermaDefaultBold")
        lbl:SetTextColor(Color(255, 165, 0))
        lbl:SetPos(10, y)
        lbl:SizeToContents()
        y = y + 30
    end
    
    local function addTextEntry(label, cvar, default)
        local container = vgui.Create("DPanel", scroll)
        container:SetPos(10, y)
        container:SetSize(panelW - 60, 60)
        container.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(35, 35, 40))
        end
        
        local lbl = vgui.Create("DLabel", container)
        lbl:SetText(label)
        lbl:SetFont("DermaDefault")
        lbl:SetTextColor(Color(220, 220, 220))
        lbl:SetPos(10, 10)
        lbl:SizeToContents()
        
        local entry = vgui.Create("DTextEntry", container)
        entry:SetPos(10, 30)
        entry:SetSize(panelW - 80, 25)
        entry:SetText(GetConVar(cvar):GetString())
        entry.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(20, 20, 25))
            self:DrawTextEntryText(Color(255, 255, 255), Color(100, 100, 255), Color(255, 255, 255))
        end
        
        configs[cvar] = entry
        y = y + 70
    end
    
    local function addCheckbox(label, cvar)
        local container = vgui.Create("DPanel", scroll)
        container:SetPos(10, y)
        container:SetSize(panelW - 60, 40)
        container.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(35, 35, 40))
        end
        
        local lbl = vgui.Create("DLabel", container)
        lbl:SetText(label)
        lbl:SetFont("DermaDefault")
        lbl:SetTextColor(Color(220, 220, 220))
        lbl:SetPos(10, 12)
        lbl:SizeToContents()
        
        local check = vgui.Create("DCheckBoxLabel", container)
        check:SetPos(panelW - 90, 10)
        check:SetText("")
        check:SetValue(GetConVar(cvar):GetString() == "true" or GetConVar(cvar):GetString() == "1")
        
        configs[cvar] = check
        y = y + 50
    end
    
    addSection("Display Settings")
    addTextEntry("Build Text", "betterbuild_text")
    addTextEntry("Font", "betterbuild_font")
    addTextEntry("Text Color (R, G, B)", "betterbuild_textcolor")
    
    addSection("Chat Commands")
    addTextEntry("Enter Build Command", "betterbuild_enterBuildCommand")
    addTextEntry("Leave Build Command", "betterbuild_enterLeaveCommand")
    addTextEntry("Chat Cooldown (seconds)", "betterbuild_chatCooldown")
    
    addSection("Announcements")
    addCheckbox("Announce Entering Build", "betterbuild_announceEnteringBuildMode")
    addTextEntry("Enter Message", "betterbuild_announceEnterMessage")
    addTextEntry("Enter Message Color (R G B)", "betterbuild_announceEnterMessageColor")
    addCheckbox("Announce Exiting Build", "betterbuild_announceExitingBuildMode")
    addTextEntry("Exit Message", "betterbuild_announceExitMessage")
    addTextEntry("Exit Message Color (R G B)", "betterbuild_announceExitMessageColor")
    
    addSection("PVP Detection")
    addCheckbox("Detect PVP", "betterbuild_detectPVP")
    addTextEntry("PVP Cooldown (seconds)", "betterbuild_pvpCooldown")
    addTextEntry("PVP Warning Message", "betterbuild_pvpWarningMessage")
    
    addSection("Other")
    addCheckbox("Allow Noclip Outside Build", "betterbuild_allowNoclipOutsideBuildMode")
    
    local saveBtn = vgui.Create("DButton", frame)
    saveBtn:SetText("")
    saveBtn:SetPos(20, panelH - 60)
    saveBtn:SetSize(panelW - 40, 50)
    saveBtn.Paint = function(self, w, h)
        local col = self:IsHovered() and Color(255, 185, 50) or Color(255, 165, 0)
        draw.RoundedBox(6, 0, 0, w, h, col)
        draw.SimpleText("SAVE CONFIGS HERE, CLICK!", "DermaLarge", w/2, h/2, Color(25, 25, 30), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    saveBtn.DoClick = function()
        local data = {}
        for cvar, ctrl in pairs(configs) do
            if ctrl.GetChecked then
                data[cvar] = ctrl:GetChecked() and "true" or "false"
            else
                data[cvar] = ctrl:GetValue()
            end
        end
        
        net.Start("BetterBuild_SaveConfig")
        net.WriteTable(data)
        net.SendToServer()
        
        chat.AddText(Color(0, 255, 0), "[Build] ", Color(255, 255, 255), "Configuration saved!")
        frame:Close()
    end
end)