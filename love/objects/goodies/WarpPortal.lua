love.filesystem.require("oo.lua")
love.filesystem.require("objects/composable/SimplePhysicsObject.lua")
love.filesystem.require("graphics/RepresentableAsImage.lua")

WarpPortal = {
  super = SimplePhysicsObject,
  sound = love.audio.newSound("sound/portal.ogg"),
  
  hazeIntense = love.graphics.newColor(255,200,255,200),
  hazeFade = love.graphics.newColor(64,20,128,64),
  darkIntense = love.graphics.newColor(24,0,32,200),
  darkFade = love.graphics.newColor(0,0,0,64),
  
  draw = function(self)
    local x, y, scale = camera:xy(self.x, self.y, 0)
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
    love.graphics.draw(self.image,x,y,scale/25)
  end,
  
  update = function(self, dt)
    if state.game.ship.hasCrystal then
      self.darkmatter:setParticleLife(0.375,1.0)
      self.haze:setParticleLife(0.5,1.5)
    else
      self.darkmatter:setParticleLife(0.25,0.5)
      self.haze:setParticleLife(0.25,0.5)
    end
    self.haze:update(dt)
    self.darkmatter:update(dt)
  end,

  create = function(self,world,node)
    local ssBody = love.physics.newBody(world,node.x,node.y,0)
    local ssShape = love.physics.newCircleShape(ssBody,0.75)
    ssShape:setSensor(true)
    
    local result = SimplePhysicsObject:create(ssBody, ssShape)
    mixin(result, WarpPortal)
    result.class = WarpPortal

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
    h:setColor(result.hazeIntense, result.hazeFade)
    h:start()
    h:update(2)

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
    d:setColor(result.darkIntense, result.darkFade)
    d:start()
    d:update(2)

    result.image = love.graphics.newImage("graphics/warpPortal.png")
    
    return result
  end
}
