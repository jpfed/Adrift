love.filesystem.require("oo.lua")
love.filesystem.require("objects/composable/GameObject.lua")

Explosion = {
  super = GameObject,
    
  life = 0,
  
  draw = function(self)
    local x, y, scale = camera:xy(self.x, self.y, 0)
    
    love.graphics.setColorMode(love.color_modulate)
    love.graphics.setBlendMode(love.blend_additive)
    love.graphics.draw(self.fire,x,y)
    love.graphics.setBlendMode(love.blend_normal)
    love.graphics.draw(self.smoke,x,y)
    love.graphics.setColorMode(love.color_normal)
  end,

  update = function(self, dt)
    self.life = self.life + dt
    if self.life > self.duration then
      self.dead = true
    else
      self.fire:update(dt)
      self.smoke:update(dt)
    end
  end,
  
  create = function(self,x,y,duration,brightImage,darkImage,brightStart,brightFade, darkStart, darkFade)
    local result = GameObject:create(x,y)
    mixin(result, Explosion)
    result.class = Explosion
    
    result.duration = duration
    result.fire = love.graphics.newParticleSystem(brightImage, 300)
    local f = result.fire
    f:setEmissionRate(math.floor(100/duration))
    f:setLifetime(0.125)
    f:setParticleLife(0.25,0.75)
    f:setDirection(0)
    f:setSpread(360)
    f:setSpeed(1,360)
    f:setGravity(0)
    f:setSize(4, 0.5, 1.0)
    f:setColor(brightStart, brightFade)
    
    result.smoke = love.graphics.newParticleSystem(darkImage, 300)
    local s = result.smoke
    s:setEmissionRate(math.floor(100/duration))
    s:setLifetime(0.5)
    s:setParticleLife(0.75,1.5)
    s:setDirection(0)
    s:setSpread(360)
    s:setSpeed(1,60)
    s:setGravity(0)
    s:setSize(0.5, 4, 1.0)
    s:setColor(darkStart, darkFade)
    
    s:start()
    f:start()
    return result
  end
}

FireyExplosion = {
  fireImage = love.graphics.newImage("graphics/fire.png"),
  fireStart = love.graphics.newColor(255, 128, 64, 255),
  fireFade = love.graphics.newColor(255, 0, 0, 0),
  
  smokeImage = love.graphics.newImage("graphics/smoke.png"),
  smokeStart = love.graphics.newColor(0,0,0,128),
  smokeFade = love.graphics.newColor(0,0,0,0),
  
  create = function(self, x, y, duration)
    return Explosion:create(x, y, duration, self.fireImage, self.smokeImage, self.fireStart, self.fireFade, self.smokeStart, self.smokeFade)
  end
}
