surface.CreateFont("Lock.Button", {
    ["font"] = "Roboto",
    ["size"] = ScreenScale(14),
    ["extended"] = true,
    ["weight"] = 700
})

local backgroundMat = Material("gmod_lock/ui/background.png", "smooth")

---
--- LOCK 3
---

do
    local PANEL = {}

    function PANEL:Init()
        self:MakePopup()

        self.Speed = 1
        self.Times = {}
        self.Current = 1

        self.Max = 10

        for i=1, self.Max do
            local number = math.random(1, 1000)
            table.insert(self.Times, {number, false})
        end

        local buttonUnlock = vgui.Create("Lock.Button", self)
        if IsValid(buttonUnlock) then
            self.ButtonUnlock = buttonUnlock

            buttonUnlock:SetNewText("Unlock")
            buttonUnlock.OnPressed = function ()
                local lockName = self.LockName

                LOCKSYSTEM:CheckResult(lockName, self.Times)
            end
        end
    end

    function PANEL:OnMousePressed(keyCode)
        if keyCode ~= MOUSE_LEFT then return end
        
        if self.Current > self.Max then return end

        local h = self:GetTall()
        local mH, mH2 = ScreenScale(14), ScreenScale(41)

        local time = self.Times[self.Current]
        local size = ScreenScale(10)
        local lineTall = ScreenScale(50)
        local center = (h/2 - (lineTall * 2 + size) / 2)
        local size = ScreenScale(10)
        local move = mH - size + math.sin((CurTime() + time[1]) * self.Speed) * center

        if move >= 0 and move <= size then
            time[2] = true
            self.Current = self.Current + 1
        end
    end

    function PANEL:SetLockName(name)
        self.LockName = name
    end

    function PANEL:PerformLayout(w, h)
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

    function PANEL:DrawLine(x, w, h, maringH, marginH2, time, queue)
        local tableTime = self.Times[queue]

        local size = ScreenScale(10)
        local lineTall = ScreenScale(50)

        local center = ((h - maringH - marginH2) / 2 - (lineTall * 2 + size) / 2)
        
        if tableTime[2] then
            surface.SetDrawColor(COLOR_GREEN)
            surface.DrawRect(x, center + maringH, size, lineTall)
            surface.DrawRect(x, center + size + lineTall + maringH, size, lineTall)
            
            return 
        end
        
        local move = maringH + math.sin((CurTime() + time) * self.Speed) * center

        surface.SetDrawColor(COLOR_WHITE)
        surface.DrawRect(x, center + move, size, lineTall)
        surface.DrawRect(x, center + move + size + lineTall, size, lineTall)

        if self.Current == queue then
            surface.SetDrawColor(COLOR_GREEN)
            
            surface.DrawOutlinedRect(x, center + move, size, lineTall, ScreenScale(2))
            surface.DrawOutlinedRect(x, center + move + size + lineTall, size, lineTall, ScreenScale(2))
        end
    end

    function PANEL:Paint(w, h)
        local mW, mH, mH2 = ScreenScale(18), ScreenScale(14), ScreenScale(41)

        surface.SetDrawColor(COLOR_BACKGROUND)
        surface.DrawRect(mW, mH, w - mW * 2, h - mH - mH2)

        local size = ScreenScaleH(10)
        local yPos = mH + (h - mH - mH2) / 2 - size / 2
        surface.SetDrawColor(COLOR_RED)
        surface.DrawRect(mW, yPos, w - mW * 2, size)
        
        local screenWide = w - mW * 2
        local xpos = (screenWide / self.Max) / 2

        for k, number in ipairs(self.Times) do
            self:DrawLine(mW + xpos + (screenWide / self.Max) * (k - 1), screenWide, h, mH, mH2, number[1], k)
        end

        surface.SetDrawColor(COLOR_WHITE)
        surface.SetMaterial(backgroundMat)
        surface.DrawTexturedRect(0, 0, w, h)
    end

    vgui.Register("Lock.Lock3", PANEL, "EditablePanel")
end

if IsValid(LOCK3) then
    LOCK3:Remove()
end

local function OnActivate(lockName, data)    
    if IsValid(LOCK3) then 
        return
    end

    LOCK3 = vgui.Create("Lock.Lock3")
    if not IsValid(LOCK3) then return end
    LOCK3:SetLockName(lockName)
end

local function OnSuccess()
    if not IsValid(LOCK3) then return end

    LOCK3:Remove()
end

local function OnFail()

end

LOCKSYSTEM:RegisterLock("lock_3", OnActivate, OnSuccess, OnFail)