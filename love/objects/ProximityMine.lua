love.filesystem.require("oo.lua")
love.filesystem.require("objects/composable/SimplePhysicsObject.lua")
love.filesystem.require("objects/goodies/ProximityMinePowerup.lua")

ProximityMine = {
  super = SimplePhysicsObject,
  radius = 0.3,
  damage = 3,
  smokeColor = love.graphics.newColor(200,200,200,180),
  smokeFadeColor = love.graphics.newColor(128,128,128,0),
  placeSound = love.audio.newSound("sound/proximityMinePlacement.ogg"),
  explodeSound = love.audio.newSound("sound/proximityMineExplosion.ogg"),
  
  explode = function(self,d) 
    if not self.dead then
      --todo: eventually the prox mine shouldn't do direct damage to its trigger-er, it should only damage via its giant explosion
      if isA(d, DamageableObject) then
        d:damage(self.damage)
      end
      love.audio.play(self.explodeSound)
      L:addObject(FireyExplosion:create(self.x,self.y,80,3.0))
      self.dead = true
    end
  end,
  
  touchDamageable = function(self, d)
    self:explode(d)
  end,
  
  touchOther = function(self, d)
    self:explode(d)
  end,
  
  update = function(self, dt)
    SimplePhysicsObject.update(self,dt)
    self.smoke:update(dt)
  end,
  
  draw = function(b) 
    local x,y,scale = L:xy(b.body:getX(),b.body:getY(),0)
    love.graphics.setColorMode(love.color_modulate)
    love.graphics.draw(b.smoke,x,y)
    love.graphics.setColorMode(love.color_normal)
    love.graphics.setColor(b.color)
    love.graphics.circle(love.draw_fill,x,y,b.radius*scale,32)
  end,
  
  create = function(sb, firer, originPoint, color)
    local tipx,tipy = originPoint.x, originPoint.y
    local vx,vy = firer.body:getVelocity()
    vx = vx / 20
    vy = vy / 20
    local v = vx + vy
    local sbBody = love.physics.newBody(L.world, tipx,tipy,0.0)
    local sbShape = love.physics.newCircleShape(sbBody, ProximityMine.radius)
    sbBody:setVelocity(vx,vy)
    
    local result = SimplePhysicsObject:create(sbBody, sbShape)
    mixin(result, Projectile:attribute())
    mixin(result, ProximityMine)
    result.class = ProximityMine
    result.color = color
    result.firer = firer

    result.smoke = love.graphics.newParticleSystem(love.graphics.newImage("graphics/smoke.png"), 300)
    local s = result.smoke
    s:setEmissionRate(2)
    s:setParticleLife(2,3)
    s:setRotation(0,360)
    s:setSpread(360)
    s:setSpeed(10,20)
    s:setRadialAcceleration(5,5)
    s:setGravity(10)
    s:setSize(1, 2, 1)
    s:setColor(result.smokeColor, result.smokeFadeColor)
    s:start()

    return result
  end,

  
}
