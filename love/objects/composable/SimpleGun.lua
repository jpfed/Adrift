love.filesystem.require("oo.lua")
love.filesystem.require("objects/SimpleBullet.lua")

SimpleGun = {

  mountX = 0,
  mountY = 0,
  mountAngle = 0,
  
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
    self.tryFiring = true
  end,
  
  update = function(self, dt)
    if self.heat == 0 and self.tryFiring then
      local theta = math.rad(self.parent.angle)
      local rotatedX, rotatedY = self.mountX * math.cos(theta) - self.mountY * math.sin(theta), self.mountX * math.sin(theta) + self.mountY * math.cos(theta)
      
      local p = self:spawnProjectile({
        x = rotatedX + self.parent.x, 
        y = rotatedY + self.parent.y,
        angle = self.parent.angle + self.mountAngle
      })
      L:addObject(p)

      self.heat = self.heat + 1
    end
    
    self.tryFiring = false
    self.heat = math.max(0, self.heat - self.shotsPerSecond * dt)
  end,

}
