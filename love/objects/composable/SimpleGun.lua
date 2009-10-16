love.filesystem.require("oo.lua")
love.filesystem.require("objects/SimpleBullet.lua")

SimpleGun = {

  parent = nil,
  mountX = 0,
  mountY = 0,
  mountAngle = 0,
  
  tryFiring = false,
  heat = 0,
  shotsPerSecond = 1,
  
  create = function(self, parent, mountX, mountY, mountAngle, shotsPerSecond, bulletColor, bulletHighlightColor) 
    local result = {}
    mixin(result, SimpleGun)
    result.class = SimpleGun
    
    result.parent = parent
    result.mountX = mountX
    result.mountY = mountY
    result.mountAngle = mountAngle
    result.shotsPerSecond = shotsPerSecond
  
    result.bulletColor = bulletColor
    result.bulletHighlightColor = bulletHighlightColor
  
    return result
  end,
  
  fire = function(self)
    self.tryFiring = true
  end,
  
  update = function(self, dt)
    if self.heat == 0 and self.tryFiring then
      local theta = math.rad(self.parent.angle)
      local rotatedX, rotatedY = self.mountX * math.cos(theta) - self.mountY * math.sin(theta), self.mountX * math.sin(theta) + self.mountY * math.cos(theta)
      
      local muzzleX, muzzleY = rotatedX + self.parent.x, rotatedY + self.parent.y
      local muzzleAngle = self.parent.angle + self.mountAngle
      
      
      local bullet = SimpleBullet:create(self.parent,{x = muzzleX, y = muzzleY, angle = muzzleAngle}, self.bulletColor, self.bulletHighlightColor)
      state.game.level:addObject(bullet)
      self.heat = self.heat + 1
        
    end
    
    self.tryFiring = false
    self.heat = math.max(0, self.heat - self.shotsPerSecond * dt)
  end,

}
