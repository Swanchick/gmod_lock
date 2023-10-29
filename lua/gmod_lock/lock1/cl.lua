

local backgroundModel = Color(0, 0, 0, 200)
local lockModel = ClientsideModel("models/door_handle.mdl")
local lockModelPos = Vector(0, -35, 20)
local lockModelAngle = Angle(0, 90, 0)

local lockPickModel= ClientsideModel("models/lockpick.mdl")

do
    local PANEL = {}

    function PANEL:Init()
        self:MakePopup()

        self.RotateGoal = {1000, 1000}

        self.PreviousAngle = 0
        self.CanPlaySound = true
    end

    function PANEL:PerformLayout()
        local scrW, scrH = ScrW(), ScrH()

        self:SetSize(scrW, scrH)
    end

    function PANEL:Setup(lockName, data)
        self.LockName = lockName
        local angle = data[1]
        local offset = math.pi / 80

        self.RotateGoal = {angle - offset, angle + offset}
    end

    function PANEL:GetAngle(sX, sY, eX, eY)
        local dx = eX - sX
        local dy = eY - sY
        local angle = math.atan2(dy, dx)
        return math.Clamp(angle, -math.pi + 0.001, 0.001)
    end

    function PANEL:GetAngleSpeed(sX, sY, eX, eY)
        local delta = FrameTime()
        local angle = self:GetAngle(sX, sY, eX, eY)
        
        local speed = (angle - self.PreviousAngle) / delta

        self.PreviousAngle = angle
        
        return speed
    end

    function PANEL:OnMousePressed(keyPressed)
        if keyPressed ~= MOUSE_LEFT then return end
        
        local scrW, scrH = ScrW(), ScrH()
        local mouseX, mouseY = self:LocalCursorPos()

        if not self.CanPlaySound then return end
        local speedAngle = self:GetAngleSpeed(scrW / 2, scrH / 2, mouseX, mouseY)
        if math.abs(speedAngle) > 0.5 then return end
        
        self.Angle = self:GetAngle(scrW / 2, scrH / 2, mouseX, mouseY)

        LOCKSYSTEM:CheckResult(self.LockName, {self.Angle})
        
        surface.PlaySound("buttons/combine_button7.wav")
    end

    function PANEL:Think()
        local scrW, scrH = ScrW(), ScrH()
        local mouseX, mouseY = self:LocalCursorPos()

        self.Angle = self:GetAngle(scrW / 2, scrH / 2, mouseX, mouseY)
        if self.Angle < self.RotateGoal[1] or self.Angle > self.RotateGoal[2] then return end
        
        if not self.CanPlaySound then return end
        local speedAngle = self:GetAngleSpeed(scrW / 2, scrH / 2, mouseX, mouseY)
        
        if math.abs(speedAngle) > 0.5 or math.abs(speedAngle) < 0.001 then return end

        self.CanPlaySound = false
        
        timer.Simple(1, function ()
            self.CanPlaySound = true
        end)

        surface.PlaySound("buttons/combine_button7.wav")
    end

    function PANEL:Paint(w, h)
        local eyeAngle = EyeAngles()
        local pos = eyeAngle:Forward() * lockModelPos.y + eyeAngle:Up() * lockModelPos.z
    
        surface.SetDrawColor(backgroundModel)
        surface.DrawRect(0, 0, w, h)
        
        local mouseX, mouseY = self:LocalCursorPos()
        local lockAng = Angle(0, eyeAngle.y - lockModelAngle.y, -eyeAngle.x)
        local lockPickAng = Angle(0, eyeAngle.y, eyeAngle.z + math.deg(self.Angle) - 180)

        cam.Start3D(pos)
            lockModel:SetAngles(lockAng)
            lockModel:DrawModel()

            lockPickModel:SetPos(Vector(-10, 0, 20.5))
            lockPickModel:SetAngles(lockPickAng)
            lockPickModel:DrawModel()
        cam.End3D()
    end

    vgui.Register("Lock.Lock1", PANEL, "EditablePanel")
end

if IsValid(LOCK1) then
    LOCK1:Remove()
end

local function OnActivate(lockName, data)
    if IsValid(LOCK1) then return end 

    LOCK1 = vgui.Create("Lock.Lock1", GetHUDPanel())
    LOCK1:Setup(lockName, data)
end

local function OnSuccess()
    LOCK1:Remove()
end

local function OnFail()
    LOCK1:Remove()
end

LOCKSYSTEM:RegisterLock("lock_1", OnActivate, OnSuccess, OnFail)