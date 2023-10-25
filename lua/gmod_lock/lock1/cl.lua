do
    local PANEL = {}

    function PANEL:Init()
        self:MakePopup()

        self.Buttons = {}

        for i=1, 10 do
            local button = vgui.Create("DButton", self)
            if not IsValid(button) then continue end
            table.insert(self.Buttons, button)

            button:SetText(tostring(i))
            button:Dock(RIGHT)

            function button:DoClick()
                local parent = self:GetParent()
                if not IsValid(parent) then return end
                
                local lockName = parent.LockName
                LOCKSYSTEM:CheckResult(lockName, {self:GetText()})
            end
        end
    end

    function PANEL:SetLockName(lockName)
        self.LockName = lockName
    end

    function PANEL:PerformLayout(w, h)
        local wide, tall = ScreenScale(230), ScreenScale(20)
        
        self:SetSize(wide, tall)
        self:Center()
    end

    vgui.Register("Lock.SuperHardLock", PANEL, "EditablePanel")
end

TEST_LOCK = TEST_LOCK or {}

if IsValid(TEST_LOCK) then
    TEST_LOCK:Remove()
end

local function OnActivate(lockName, data)
    if IsValid(TEST_LOCK) then return end
    
    TEST_LOCK = vgui.Create("Lock.SuperHardLock")
    TEST_LOCK:SetLockName(lockName)
end

local function OnSuccess()
    TEST_LOCK:Remove()
end

local function OnFail()
    -- TEST_LOCK:Remove()
end

LOCKSYSTEM:RegisterLock("lock_1", OnActivate, OnSuccess, OnFail)