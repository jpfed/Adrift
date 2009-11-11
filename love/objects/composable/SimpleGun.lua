love.filesystem.require("oo.lua")
love.filesystem.require("objects/SimpleBullet.lua")

SimpleGun = {

  mountX = 0,
  mountY = 0,
  mountAngle = 0,
  
  chargeable = false,
  charging = false,
  charge = 0,
  tryFiring = false,
  heat = 0,
  shotsPerSecond = 1,
  
  create = function(self, params) 
    local result = {}
    mixin(result, SimpleGun)
    mixin(result, params)
    result.class = SimpleGun
    
    return result
  end,
  
  fire = function(self)
    if self.chargeable then
      self.charging = true
    else
      self.tryFiring = true
    end
  end,
  
  release = function(self)
    if self.chargeable and self.charging then
      self.tryFiring = true
      self.charging = false
    end
  end,

  update = function(self, dt)
    if self.chargeable then
      self.charge = self.charge + dt
    end

    if self.heat == 0 and self.tryFiring then
      self:shoot()
    end
    
    self.tryFiring = false
    self.heat = math.max(0, self.heat - self.shotsPerSecond * dt)
  end,

  shoot = function(self)
    if self.ammo > 0 then
      local theta = math.rad(self.parent.angle)

      local rotatedC = function(o,isX)
        local emphasis
        if o == 0 then emphasis = 1 else emphasis = 2 end
        local angle = math.rad(o*emphasis) + theta
        if isX then 
          return self.mountX * math.cos(angle) - self.mountY * math.sin(angle)
        else
          return self.mountX * math.sin(angle) + self.mountY * math.cos(angle)
        end
      end
      local rotatedX = function(o) return rotatedC(o,true) end
      local rotatedY = function(o) return rotatedC(o,false) end
      
      local angles = {0}
      if self.chargeable then
        if self.charge > 1 then
          table.insert(angles, 10)
          table.insert(angles, -10)
        end
        if self.charge > 2 then
          table.insert(angles, 20)
          table.insert(angles, -20)
        end
        self.charge = 0
      end

      for i,a in ipairs(angles) do
        local p = self:spawnProjectile({
          x = rotatedX(a) + self.parent.x, 
          y = rotatedY(a) + self.parent.y,
          angle = self.parent.angle + self.mountAngle + a
        })
        L:addObject(p)
      end

      self.heat = self.heat + 1
      self.ammo = self.ammo - 1
    end
  end

}
