local backgroundMat = Material("gmod_lock/ui/background.png", "smooth")

do
    local PANEL = {}

    local WIRE_COLORS = {
        [1] = Color(255, 0, 0),
        [2] = Color(0, 0, 255),
        [3] = Color(255, 255, 0),
        [4] = Color(255, 0, 255)
    }

    local wireMat = Material("gmod_lock/ui/wire.png", "noclamp")

    function PANEL:Init()
        self:MakePopup()

        self.DrawWire = false

        self.Wires = {}

        self.BlockedWires = {}
        self.ConnectedWires = {}

        local buttonUnlock = vgui.Create("Lock.Button", self)
        if IsValid(buttonUnlock) then
            self.ButtonUnlock = buttonUnlock

            buttonUnlock:SetNewText("Unlock")
            buttonUnlock.OnPressed = function ()
                local lockName = self.LockName

                LOCKSYSTEM:CheckResult(lockName, self.Wires)
            end
        end
    end

    function PANEL:Setup(lockName, data)
        self.LockName = lockName
        self.Wires = data
    end

    function PANEL:PerformLayout()
        local wide, tall = ScreenScale(350), ScreenScale(250)

        self:SetSize(wide, tall)
        self:Center()

        local buttonUnlock = self.ButtonUnlock
        if IsValid(buttonUnlock) then
            buttonUnlock:CenterHorizontal()
            local buttonTall = buttonUnlock:GetTall()
            local margin = ScreenScale(3)

            buttonUnlock:SetY(tall - buttonTall - margin)
        end
    end

    function PANEL:GetWirePos(mouseY)
        local h = self:GetTall()
        local mH, mH2 = ScreenScale(14), ScreenScale(41)

        local tall = ScreenScale(45), ScreenScale(20)
        local offset = (h - mH - mH2) / 4

        return math.floor((mouseY - mH * 2 + offset) / offset)
    end

    function PANEL:SetWires(startWire, endWire, sX, sY, eX, eY)
        local wire = self.Wires[endWire]

        if wire[1] == startWire then
            wire[2] = startWire
            
            self.BlockedWires[startWire] = true
            table.insert(self.ConnectedWires, {sX, sY, eX, eY, startWire})
        end
    end

    function PANEL:OnMousePressed(keyPressed)
        if keyPressed ~= MOUSE_LEFT then return end

        local mW, mH, mH2 = ScreenScale(18), ScreenScale(14), ScreenScale(41)
        local wide, tall = self:GetSize()
        local mouseX, mouseY = self:LocalCursorPos()
        local wireWide, wireTall = ScreenScale(45), ScreenScale(20)
        
        if mouseX < mW or mouseX > mW + wireWide then return end

        local wire = self:GetWirePos(mouseY)
        if wire <= 0 or wire > 4 then return end
        if self.BlockedWires[wire] then return end


        local offset = (tall - mH - mH2) / 4

        self.StartX = mW + wireWide
        self.StartY = mH * 2 + offset * (wire - 1) + wireTall / 2
        self.DrawWire = true
        self.WireColor = WIRE_COLORS[wire]
        self.CurrentWire = wire
    end

    function PANEL:OnMouseReleased(keyPressed)
        if keyPressed ~= MOUSE_LEFT then return end

        self.DrawWire = false 

        local mW, mH, mH2 = ScreenScale(18), ScreenScale(14), ScreenScale(41)
        local wide, tall = self:GetSize()
        local mouseX, mouseY = self:LocalCursorPos()
        local wireWide, wireTall = ScreenScale(45), ScreenScale(20)

        if mouseX < wide - mW - wireWide or mouseX > wide - mW then return end

        local wire = self:GetWirePos(mouseY)
        if wire <= 0 or wire > 4 then return end

        local offset = (tall - mH - mH2) / 4

        local endX = wide - mW - wireWide
        local endY = mH * 2 + offset * (wire - 1) + wireTall / 2

        self:SetWires(self.CurrentWire, wire, self.StartX, self.StartY, endX, endY)
    end

    function PANEL:GetWireAngle(startX, startY, endX, endY)
        local dx = endX - startX
        local dy = endY - startY
        local angle = math.atan2(dy, dx)
        return math.deg(angle)
    end
    
    function PANEL:DrawRectRotated(x, y, w, h, rot, x0, y0)
        local c = math.cos(math.rad(rot))
        local s = math.sin(math.rad(rot))
        
        local newx = y0 * s - x0 * c
        local newy = y0 * c + x0 * s
        
        surface.DrawTexturedRectRotated(x + newx, y + newy, w, h, rot)
    end

    function PANEL:CalculateWide(startX, startY, endX, endY)
        local dx = endX - startX
        local dy = endY - startY
        local width = math.sqrt(dx * dx + dy * dy)

        return width
    end

    function PANEL:DrawWires(sX, sY, eX, eY)
        local tall = ScreenScale(20)
        
        local angle = self:GetWireAngle(sX, sY, eX, eY)
        local wide = self:CalculateWide(sX, sY, eX, eY)
        
        self:DrawRectRotated(sX, sY, wide, tall, -angle, -wide / 2, 0)
    end

    function PANEL:Paint(w, h)
        local mW, mH, mH2 = ScreenScale(18), ScreenScale(14), ScreenScale(41)
        surface.SetDrawColor(COLOR_BACKGROUND)
        surface.DrawRect(mW, mH, w - mW * 2, h - mH - mH2)

        local wide, tall = ScreenScale(45), ScreenScale(20)
        local offset = (h - mH - mH2) / 4

        surface.SetMaterial(wireMat)
        if self.Wires then
            for k, wire in ipairs(self.Wires) do
                surface.SetDrawColor(WIRE_COLORS[k])
                surface.DrawTexturedRect(mW, mH * 2 + offset * (k - 1), wide, tall)
    
                surface.SetDrawColor(WIRE_COLORS[wire[1]])
                surface.DrawTexturedRect(w - mW - wide, mH * 2 + offset * (k - 1), wide, tall)
            end
        end
        
        for k, wire in ipairs(self.ConnectedWires) do
            surface.SetDrawColor(WIRE_COLORS[wire[5]])
            
            self:DrawWires(wire[1], wire[2], wire[3], wire[4])
        end

        if self.DrawWire then
            local mouseX, mouseY = self:LocalCursorPos()

            surface.SetDrawColor(self.WireColor)
            self:DrawWires(self.StartX, self.StartY, mouseX, mouseY)
        end
        
        surface.SetDrawColor(COLOR_WHITE)
        surface.SetMaterial(backgroundMat)
        surface.DrawTexturedRect(0, 0, w, h)
    end

    vgui.Register("Lock.Lock2", PANEL, "EditablePanel")
end

if IsValid(LOCK2) then
    LOCK2:Remove()
end

local function OnActivate(lockName, data)
    if IsValid(LOCK2) then return end
    
    LOCK2 = vgui.Create("Lock.Lock2")
    LOCK2:Setup(lockName, data)
end

local function OnSuccess()
    if not IsValid(LOCK2) then return end

    LOCK2:Remove()
end

local function OnFail()

end

LOCKSYSTEM:RegisterLock("lock_2", OnActivate, OnSuccess, OnFail)