love.filesystem.require("oo.lua")
love.filesystem.require("objects/composable/GameObject.lua")

PortalSystem = {
  super = GameObject,
    
  life = 0,
  
  create = function(self,duration,size, prerun, hazeIntense, hazeFade, darkIntense, darkFade)
    local result = GameObject:create(0,0)
    mixin(result, PortalSystem)
    result.class = PortalSystem

    result.duration = duration
    result.size = size
    -- todo: use these

    result.haze = love.graphics.newParticleSystem(love.graphics.newImage("graphics/smoke.png"), 300)
    local h = result.haze
    h:setEmissionRate(40)
    h:setParticleLife(0.5,1.5)
    h:setDirection(0)
    h:setRotation(0,360)
    h:setSpin(0,360,1.0)
    h:setSpread(360)
    h:setSpeed(50,80)
    h:setRadialAcceleration(20,20)
    h:setTangentialAcceleration(80,200)
    h:setGravity(0)
    h:setSize(3.0,12.0,0.8)
    h:setColor(hazeIntense, hazeFade)
    h:start()
    if duration > 0 then
      h:setLifetime(duration+prerun)
    end
    h:update(prerun)

    result.darkmatter = love.graphics.newParticleSystem(love.graphics.newImage("graphics/smoke.png"), 300)
    local d = result.darkmatter
    d:setEmissionRate(40)
    d:setParticleLife(0.375,1.0)
    d:setDirection(0)
    d:setRotation(0,360)
    d:setSpin(0,360,1.0)
    d:setSpread(360)
    d:setSpeed(100,120)
    d:setRadialAcceleration(-20,-40)
    d:setTangentialAcceleration(40,60)
    d:setGravity(0)
    d:setSize(4.0,8.0,1.0)
    d:setColor(darkIntense, darkFade)
    d:start()
    if duration > 0 then
      d:setLifetime(duration+prerun)
    end
    d:update(prerun)

    return result
  end,

  draw = function(self, x, y)
    love.graphics.setColorMode(love.color_modulate)
    love.graphics.setBlendMode(love.blend_additive)
    love.graphics.draw(self.haze,x,y)
    love.graphics.setBlendMode(love.blend_normal)
    love.graphics.draw(self.darkmatter,x,y)
    love.graphics.setColorMode(love.color_normal)
    love.graphics.setColor(255,255,255,64)
  end,

  update = function(self, dt)
    self.haze:update(dt)
    self.darkmatter:update(dt)
  end

}

PortalHoleSystem = {
  create = function(self)
    local hazeIntense = love.graphics.newColor(255,200,255,200)
    local hazeFade = love.graphics.newColor(64,20,128,64)
    local darkIntense = love.graphics.newColor(24,0,32,200)
    local darkFade = love.graphics.newColor(0,0,0,64)
    local r = PortalSystem:create(0, 10, 2, hazeIntense, hazeFade, darkIntense, darkFade)

    r.draw = function(self, x, y)
      love.graphics.setColorMode(love.color_modulate)
      if state.game.ship.hasCrystal then
        love.graphics.setBlendMode(love.blend_normal)
        love.graphics.draw(self.darkmatter,x,y)
        love.graphics.setBlendMode(love.blend_additive)
        love.graphics.draw(self.haze,x,y)
        love.graphics.setBlendMode(love.blend_normal)
      else
        love.graphics.setBlendMode(love.blend_additive)
        love.graphics.draw(self.haze,x,y)
        love.graphics.setBlendMode(love.blend_normal)
        love.graphics.draw(self.darkmatter,x,y)
      end
      love.graphics.setColorMode(love.color_normal)
    end

    return r
  end
}


PortalTeleportSystem = {
  create = function(self, x, y, angle)
    local hazeIntense = love.graphics.newColor(64,128,255,80)
    local hazeFade = love.graphics.newColor(20,64,128,8)
    local darkIntense = love.graphics.newColor(24,0,32,80)
    local darkFade = love.graphics.newColor(0,0,0,16)
    local r = PortalSystem:create(0.5, 1, 0.1, hazeIntense, hazeFade, darkIntense, darkFade)
    r.x = x
    r.y = y
    r.haze:setSpread(120)
    r.darkmatter:setSpread(120)
    r.haze:setDirection(angle + 180)
    r.darkmatter:setDirection(angle + 180)
    
    return r
  end
}
