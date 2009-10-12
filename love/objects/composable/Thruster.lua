love.filesystem.require("oo.lua")

Thruster = {
  
  create = function(self, parent, direction, particleImage, brightColor, fadeColor)
    local result = {}
    mixin(result, Thruster)
    result.parent = parent
    result.system = love.graphics.newParticleSystem(particleImage, 150)
    result.directionOffset = direction
    local t = result.system
    t:setEmissionRate(30)
    t:setLifetime(-1)
    t:setParticleLife(0.5,0.7)
    t:setDirection(direction)
    t:setRotation(0,360)
    t:setSpread(30)
    t:setSpeed(80)
    t:setGravity(20)
    t:setSize(1.6, 0.2, 1.0)
    t:setColor(brightColor, fadeColor)
    t:start()
    return result
  end,
  
  setIntensity = function(self, intensity)
    local magnitude = math.abs(intensity)
    if intensity == 0 then self.sign = 0 
    else self.sign = intensity/magnitude end
    --self.system:setEmissionRate(magnitude)
    self.system:setSpeed(magnitude, magnitude*2)
  end,
  
  update = function(self, dt)
    local dir = self.parent.angle 
    if self.sign == -1 then dir = dir + 180 end
    self.system:setDirection(dir + self.directionOffset)
    self.system:update(dt)
  end,
  
  draw = function(self)
    local x, y, scale = camera:xy(self.parent.x, self.parent.y, 0)
    love.graphics.setColorMode(love.color_modulate)
    love.graphics.draw(self.system,x,y)
    love.graphics.setColorMode(love.color_normal)
  end,
  
  cleanup = function(self)
    self.system:stop()
    self.system = nil
  end
}

FireThruster = {

  fireImage = love.graphics.newImage("graphics/fire.png"),
  fireColor = love.graphics.newColor(255, 255, 64, 255),
  fadeColor = love.graphics.newColor(255, 200, 0, 0),

  create = function(self, parent, direction)
    return Thruster:create(parent, direction, self.fireImage, self.fireColor, self.fadeColor)
  end

}
