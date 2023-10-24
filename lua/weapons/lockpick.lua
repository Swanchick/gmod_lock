AddCSLuaFile()

SWEP.Author = "Swanchick"
SWEP.PrintName = "Lockpick"

SWEP.Slot = 0
SWEP.SlotPos = 5

SWEP.Spawnable = true
SWEP.ViewModel = Model("models/weapons/c_crowbar.mdl")
SWEP.WorldModel = Model("models/weapons/w_crowbar.mdl")
SWEP.UseHands = true

SWEP.Primary.ClipSize = 3
SWEP.Primary.DefaultClip = 3
SWEP.Primary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.DrawAmmo = true

SWEP.LockRange = 70
SWEP.LockIcon = Material("gmod_lock/Locked.png")

function SWEP:PrimaryAttack()
    local clip = self:Clip1()
    if clip == 0 then return end

    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    local dolagcomp = SERVER and owner:IsPlayer()
    if dolagcomp then
        owner:LagCompensation(true)
    end

    local startpos = owner:GetShootPos()
	local tr = util.TraceLine({
		start = startpos,
		endpos = startpos + owner:GetAimVector() * self.LockRange,
		filter = owner
	})

    local ent = tr.Entity
    if SERVER and IsValid(ent) then
        local className = ent:GetClass()

        if className == "prop_door_rotating" then
            local doorLocked = ent:GetInternalVariable("m_bLocked")
            
            if doorLocked then
                local doorName = ent:GetName()

                local worked = LOCKSYSTEM:CallLock(owner, doorName, ent)
                if worked then
                    self:SetClip1(clip - 1)
                end
            end
        end
    end

    if dolagcomp then
        owner:LagCompensation(false)
    end
end

function SWEP:DoDrawCrosshair()
    local owner = self:GetOwner()

    local startpos = owner:GetShootPos()
	local tr = util.TraceLine({
		start = startpos,
		endpos = startpos + owner:GetAimVector() * self.LockRange,
		filter = owner
	})
    
    local ent = tr.Entity
    if not IsValid(ent) then return end
    if ent:GetClass() ~= "prop_door_rotating" then return end 

    local size = ScreenScale(5)
    local scrW, scrH = ScrW(), ScrH()


    surface.SetMaterial(self.LockIcon)
    surface.SetDrawColor(Color(255, 255, 255))
    surface.DrawTexturedRect(scrW / 2 - size / 2, scrH / 2 - size / 2, size, size)

    return true
end

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
end
