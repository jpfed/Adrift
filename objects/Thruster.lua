love.filesystem.require("oo.lua")

Thruster = {
  
  create = function(self, parent, direction, particleImage, brightColor, fadeColor)
    local result = {}
    mixin(result, Thruster)
    result.parent = parent
    result.system = love.graphics.newParticleSystem(particleImage, 150)
    local t = result.system
    t:setEmissionRate(30)
    t:setLifetime(-1)
    t:setParticleLife(0.5)
    t:setDirection(90 + direction)
    t:setSpread(40)
    t:setSpeed(80)
    t:setGravity(0)
    t:setSize(2, 0.1, 1.0)
    t:setColor(brightColor, fadeColor)
    t:start()
    return result
  end,
  
  setIntensity = function(self, intensity)
    local magnitude = math.abs(intensity)
    if intensity == 0 then self.sign = 0 
    else self.sign = intensity/magnitude end
    self.system:setEmissionRate(magnitude)
    self.system:setSpeed(magnitude/2, magnitude*2)
  end,
  
  update = function(self, dt)
    local dir = self.parent.angle - 90
    if self.sign == -1 then dir = dir + 180 end
    self.system:setDirection(dir)
    self.system:update(dt)
  end,
  
  draw = function(self)
    local x, y, scale = camera:xy(self.parent.x, self.parent.y, 0)
    love.graphics.draw(self.system,x,y)
  end
}

FireThruster = {

  fireImage = love.graphics.newImage("graphics/fire.png"),
  fireColor = love.graphics.newColor(255, 128, 64, 255),
  fadeColor = love.graphics.newColor(255, 0, 0, 0),

  create = function(self, parent, direction)
    return Thruster:create(parent, direction, self.fireImage, self.fireColor, self.fadeColor)
  end

}
