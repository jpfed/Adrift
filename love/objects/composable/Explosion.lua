love.filesystem.require("oo.lua")
love.filesystem.require("objects/composable/GameObject.lua")

Explosion = {
  super = GameObject,
    
  life = 0,

  touchDamageable = function(self,s) 
    if not self.dead then
      d:damage(self.damage)
    end
  end,
  
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

  create = function(self, params)
    local result
    result = GameObject:create(params.x,params.y)
    if params.damaging then
      local sz = params.size
      local minX, maxX, minY, maxY = params.x - sz, params.x + sz, params.y - sz, params.y + sz
      for k,v in pairs(L.objects) do
        if kindOf(v,DamageableObject) then
          local x, y = v.x, v.y
          if minX < x and x < maxX and minY < y and y < maxY then
            local dx, dy = params.x - x, params.y - y
            local dist = math.sqrt(dx*dy + dy*dy)
            local damage = math.floor(math.max(0, math.abs(dist - sz)))
            v:damage(damage)
          end
        end
      end
      local v = state.game.ship
      local x, y = v.x, v.y
      if minX < x and x < maxX and minY < y and y < maxY then
        local dx, dy = params.x - x, params.y - y
        local dist = math.sqrt(dx*dy + dy*dy)
        local damage = math.floor(math.max(0, math.abs(dist - sz)))
        v:damage(damage)
      end
    end
    mixin(result, params)
    mixin(result, Explosion)
    result.class = Explosion
    
    result.fire = love.graphics.newParticleSystem(result.brightImage, 300)
    local f = result.fire
    f:setDirection(0)
    f:setSpread(360)
    f:setRotation(0,360)
    f:setSpin(0,360,4.0)
    f:setGravity(0)
    f:setSize(2 * result.size, 0.2 * result.size, 0.1)
    f:setColor(result.brightStart, result.brightFade)

    if result.slowdown then
      f:setEmissionRate(8)
      f:setSpeed(30 * result.size,35 * result.size)
      f:setLifetime(result.duration/90)
      f:setParticleLife(2,3)
      f:setRadialAcceleration(-10,-10)
    else
      f:setEmissionRate(60)
      f:setSpeed(75 * result.size,125 * result.size)
      f:setLifetime(result.duration/240)
      f:setParticleLife(0.25,0.4)
      f:setRadialAcceleration(-100,-100)
    end
    
    result.smoke = love.graphics.newParticleSystem(result.smokeImage, 300)
    local s = result.smoke
    s:setEmissionRate(6)
    s:setLifetime(result.duration/60)
    s:setParticleLife(2,5)
    s:setDirection(0)
    s:setRotation(0,360)
    s:setSpread(360)
    s:setSpeed(30*result.size)
    s:setGravity(0)
    s:setSize(5.0*result.size, 2.0*result.size, 2.0)
    s:setColor(result.smokeStart, result.smokeFade)
    
    s:start()
    f:start()
    return result
  end
}

FireyExplosion = {
  create = function(self, x, y, duration, size)
    return Explosion:create(
    {
      x = x,
      y = y,
      duration = duration,
      size = size,
      damaging = true,
      slowdown = false,

      brightImage = love.graphics.newImage("graphics/spark.png"),
      brightStart = love.graphics.newColor(255, 216, 192, 255),
      brightFade = love.graphics.newColor(220, 64, 0, 200),
      
      smokeImage = love.graphics.newImage("graphics/smoke.png"),
      smokeStart = love.graphics.newColor(128,128,128,200),
      smokeFade = love.graphics.newColor(64,64,64,0),
    })
  end
}

SparkExplosion = {
  create = function(self, x, y, duration, size, color)
    local cr, cg, cb, ca = math.floor(color:getRed()/2), math.floor(color:getGreen()/2), math.floor(color:getBlue()/2), math.floor(color:getAlpha()/2)
    local ex = Explosion:create({
      x = x,
      y = y,
      duration = 20,
      size = (size or 1),
      damaging = false,
      slowdown = false,

      brightImage = love.graphics.newImage("graphics/gline.png"),
      brightStart = love.graphics.newColor(cr + 128, cg + 128, cb + 128, ca + 128),
      brightFade = love.graphics.newColor(cr, cg, cb, ca),
      
      smokeImage = love.graphics.newImage("graphics/smoke.png"),
      smokeStart = love.graphics.newColor(128,128,128,100),
      smokeFade = love.graphics.newColor(64,64,64,0),
    })
    ex.fire:setSpeed(0, 400*ex.size)
    ex.smoke:setLifetime(0.2)
    ex.smoke:setParticleLife(1,1.2)
    ex.smoke:setSize(2.0, 1.0, 1.0)
    return ex
  end
}

ZapExplosion = {
  create = function(self, x, y, duration, size, color)
    local ex = SparkExplosion:create(x,y,duration, size, color)
    ex.fire:setSpeed(30*ex.size)
    ex.fire:setSpin(0)
    return ex
  end
}

EggExplosion = {
  create = function(self, x, y, duration, size)
    return Explosion:create(
    {
      x = x,
      y = y,
      duration = duration,
      size = size,
      damaging = false,
      slowdown = true,

      brightImage = love.graphics.newImage("graphics/smoke.png"),
      brightStart = love.graphics.newColor(255, 32, 32, 230),
      brightFade = love.graphics.newColor(220, 0, 128, 0),
      
      smokeImage = love.graphics.newImage("graphics/smoke.png"),
      smokeStart = love.graphics.newColor(128,64,128,200),
      smokeFade = love.graphics.newColor(64,32,64,0),
    })
  end
}

DustExplosion = {
  create = function(self, x, y, duration, size)
    return Explosion:create(
    {
      x = x,
      y = y,
      duration = duration,
      size = size,
      damaging = false,
      slowdown = true,

      brightImage = love.graphics.newImage("graphics/smoke.png"),
      brightStart = love.graphics.newColor(128, 128, 128, 200),
      brightFade = love.graphics.newColor(128, 128, 128, 0),
      
      smokeImage = love.graphics.newImage("graphics/smoke.png"),
      smokeStart = love.graphics.newColor(192,192,192,180),
      smokeFade = love.graphics.newColor(64,64,64,0),
    })
  end
}
