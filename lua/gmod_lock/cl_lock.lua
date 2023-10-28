print("Client lock")

---
--- COLORS
--- 

COLOR_BACKGROUND = Color(51, 51, 51)
COLOR_RED = Color(155, 27, 27)
COLOR_WHITE = Color(255, 255, 255)
COLOR_GREEN = Color(0, 177, 0)

---
--- Locksystem functions 
---

function LOCKSYSTEM:Activate(lockName, data)
    local lock = self.Locks[lockName]
    if not lock then return end

    local onActivate = lock["onActivate"]
    if not onActivate then return end

    onActivate(lockName, data)
end

function LOCKSYSTEM:CheckResult(lockName, result)
    net.Start("Lock.CheckResult")
        net.WriteString(lockName)
        net.WriteTable(result)
    net.SendToServer()
end

function LOCKSYSTEM:OnGetResponse(lockName, response)
    local lock = self.Locks[lockName]
    if not lock then return end

    if response then
        local onSuccess = lock["onSuccess"]
        if not onSuccess then return end

        onSuccess()
    else
        local onFail = lock["onFail"]
        if not onFail then return end

        onFail()
    end
end

---
--- Net functions
---

net.Receive("Lock.Activate", function (len, ply)
    local lockName = net.ReadString()
    local data = net.ReadTable()

    LOCKSYSTEM:Activate(lockName, data)
end)

net.Receive("Lock.CheckResult", function (len)
    local lockName = net.ReadString()
    local response = net.ReadBool()

    LOCKSYSTEM:OnGetResponse(lockName, response)
end)


---
--- UI Elements
---

-- Custom button

do
    local button = Material("gmod_lock/ui/button.png", "smooth")
    local buttonHovered = Material("gmod_lock/ui/button_hovered.png", "smooth")
    local buttonActivated = Material("gmod_lock/ui/button_activated.png", "smooth")
    
    local PANEL = {}

    function PANEL:Init()
        self.CurrentButtonMaterial = button

        self:SetText("")
        self.Text = ""

        self.Activated = false 
    end

    function PANEL:PerformLayout(w, h)
        local wide, tall = ScreenScale(110), ScreenScale(30)

        self:SetSize(wide, tall)
    end

    function PANEL:SetNewText(text)
        self.Text = text
    end

    function PANEL:OnMousePressed(keyCode)
        if keyCode ~= MOUSE_LEFT then return end

        self:OnPressed()

        self.Activated = true
        self.CurrentButtonMaterial = buttonActivated
    end

    function PANEL:OnPressed()
    end

    function PANEL:OnMouseReleased(keyCode)
        if keyCode ~= MOUSE_LEFT then return end

        self.Activated = false 
        self.CurrentButtonMaterial = button
    end

    function PANEL:Paint(w, h)
        surface.SetDrawColor(COLOR_WHITE)

        if not self.Activated then
            if self:IsHovered() then
                self.CurrentButtonMaterial = buttonHovered
            else
                self.CurrentButtonMaterial = button
            end
        end
        

        surface.SetMaterial(self.CurrentButtonMaterial)
        surface.DrawTexturedRect(0, 0, w, h)

        if self.Activated then
            draw.DrawText(self.Text, "Lock.Button", w / 2, h / 3, COLOR_WHITE, TEXT_ALIGN_CENTER)
        else
            draw.DrawText(self.Text, "Lock.Button", w / 2, h / 4 , COLOR_WHITE, TEXT_ALIGN_CENTER)
        end
    end

    vgui.Register("Lock.Button", PANEL, "DButton")
end