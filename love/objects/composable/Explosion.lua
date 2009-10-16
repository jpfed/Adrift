love.filesystem.require("oo.lua")
love.filesystem.require("objects/composable/GameObject.lua")

Explosion = {
  super = GameObject,
    
  life = 0,
  
  draw = function(self)
    local x, y, scale = L:xy(self.x, self.y, 0)
    
    love.graphics.setColorMode(love.color_modulate)
    love.graphics.draw(self.smoke,x,y)
    love.graphics.setBlendMode(love.blend_additive)
    love.graphics.draw(self.fire,x,y)
    love.graphics.setColorMode(love.color_normal)
    love.graphics.setBlendMode(love.blend_normal)
  end,

  update = function(self, dt)
    self.life = self.life + dt
    if self.life * 10 > self.duration then
      self.dead = true
    else
      self.fire:update(dt)
      self.smoke:update(dt)
    end
  end,
  
  create = function(self,x,y,duration,size,brightImage,darkImage,brightStart,brightFade, darkStart, darkFade)
    local result = GameObject:create(x,y)
    mixin(result, Explosion)
    result.class = Explosion
    
    result.duration = duration
    result.size = size

    result.fire = love.graphics.newParticleSystem(brightImage, 300)
    local f = result.fire
    f:setEmissionRate(60)
    f:setLifetime(duration/240)
    f:setParticleLife(0.25,0.4)
    f:setDirection(0)
    f:setSpread(360)
    f:setSpeed(75 * size,125 * size)
    f:setRotation(0,360)
    f:setSpin(0,360,4.0)
    f:setRadialAcceleration(-100,-100)
    f:setGravity(0)
    f:setSize(2 * size, 0.2 * size, 0.1)
    f:setColor(brightStart, brightFade)
    
    result.smoke = love.graphics.newParticleSystem(darkImage, 300)
    local s = result.smoke
    s:setEmissionRate(6)
    s:setLifetime(duration/60)
    s:setParticleLife(2,5)
    s:setDirection(0)
    s:setRotation(0,360)
    s:setSpread(360)
    s:setSpeed(30*size)
    s:setGravity(0)
    s:setSize(5.0*size, 2.0*size, 2.0)
    s:setColor(darkStart, darkFade)
    
    s:start()
    f:start()
    return result
  end
}

FireyExplosion = {
  fireImage = love.graphics.newImage("graphics/spark.png"),
  fireStart = love.graphics.newColor(255, 216, 192, 255),
  fireFade = love.graphics.newColor(220, 64, 0, 200),
  
  smokeImage = love.graphics.newImage("graphics/smoke.png"),
  smokeStart = love.graphics.newColor(128,128,128,200),
  smokeFade = love.graphics.newColor(64,64,64,0),
  
  create = function(self, x, y, duration, size)
    return Explosion:create(x, y, duration, size, self.fireImage, self.smokeImage, self.fireStart, self.fireFade, self.smokeStart, self.smokeFade)
  end
}
