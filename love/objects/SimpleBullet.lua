love.filesystem.require("oo.lua")
love.filesystem.require("objects/composable/SimplePhysicsObject.lua")
love.filesystem.require("objects/composable/Projectile.lua")

SimpleBullet = {
  super = SimplePhysicsObject,
  strikeSound = love.audio.newSound("sound/bulletStrike.ogg"),
  sparkSound = love.audio.newSound("sound/bulletSpark.ogg"),
  speed = 10,
  radius = 0.075,
  damage = 1,
  
  touchDamageable = function(self,d) 
    if not self.dead then
      d:damage(self.damage)
      if self.strikeSound then love.audio.play(self.strikeSound) end
      self.dead = true
    end
  end,

  touchOther = function(self,d)
    if not self.dead then
      if self.sparkSound then love.audio.play(self.sparkSound) end
      self.dead = true
    end
  end,
  
  update = function(self, dt)
    SimplePhysicsObject.update(self,dt)
    local vx, vy = self.body:getVelocity()
    local orientation = math.atan2(vy,vx)
    local speed = geom.distance(vx,vy,0,0)
    local speedRatio = speed/SimpleBullet.speed
    local s = self.sparks
    s:setDirection(math.deg(orientation) - 180)
    s:setRotation(orientation + math.pi / 2)
    s:setSpeed(20+speed*2,20+speed*3)
    s:setSize(1.0+speedRatio, 0.5+speedRatio, 0.5)
    s:setEmissionRate(200/math.max(1,speed))
    self.sparks:update(dt)
    self.muzzleflash:update(dt)
  end,
  
  draw = function(b) 
    local x,y,scale = L:xy(b.body:getX(),b.body:getY(),0)
    local ox,oy,scale = L:xy(b.firer.x,b.firer.y,0)
    love.graphics.setColorMode(love.color_modulate)
    love.graphics.draw(b.sparks,x,y)
    love.graphics.draw(b.muzzleflash,ox,oy)
    love.graphics.setColorMode(love.color_normal)
    --love.graphics.setColor(b.color)
    --love.graphics.circle(love.draw_fill,x,y,b.radius*scale/2,16)
  end,
  
  create = function(sb, firer, originPoint, color, highlightColor)
    local theta = math.rad(originPoint.angle)
    local tipx,tipy = originPoint.x, originPoint.y
    local vx,vy = firer.body:getVelocity()
    local mx, my = SimpleBullet.speed*math.cos(theta), SimpleBullet.speed*math.sin(theta)
    vx = vx + mx
    vy = vy + my
    local v = vx + vy
    local sbBody = love.physics.newBody(L.world, tipx+mx/120,tipy+my/120,0.01)
    local sbShape = love.physics.newCircleShape(sbBody, SimpleBullet.radius)
    sbBody:setBullet(true)
    sbBody:setVelocity(vx,vy)
    --sbShape:setSensor(true)
    
    local result = SimplePhysicsObject:create(sbBody, sbShape)
    mixin(result, Projectile:attribute())
    mixin(result, SimpleBullet)
    result.class = SimpleBullet
    result.color = color
    result.firer = firer

    local orientation = math.atan2(vy,vx)
    result.sparks = love.graphics.newParticleSystem(love.graphics.newImage("graphics/gline.png"), 300)
    local s = result.sparks
    s:setEmissionRate(20)
    s:setParticleLife(0.4,0.5)
    s:setDirection(math.deg(orientation) - 180)
    s:setRotation(orientation + math.pi / 2)
    s:setSpread(15)
    s:setSpeed(v,v+10)
    s:setRadialAcceleration(5,5)
    s:setGravity(0)
    s:setSize(1.5, 0.5, 0.5)
    s:setColor(highlightColor, color)
    s:start()
    s:update(2)

    result.muzzleflash = love.graphics.newParticleSystem(love.graphics.newImage("graphics/gline.png"), 300)
    local s = result.muzzleflash
    s:setEmissionRate(40)
    s:setParticleLife(0.25,0.3)
    s:setLifetime(0.1)
    s:setDirection(math.deg(orientation))
    s:setRotation(orientation + math.pi / 2)
    s:setSpread(10)
    s:setSpeed(400)
    s:setRadialAcceleration(-20,-20)
    s:setSize(1.5, 0.2, 1.0)
    s:setColor(highlightColor, color)
    s:start()

    return result
  end,

  cleanup = function(self)
    L:addObject(SparkExplosion:create(self.x,self.y,25,0.6,self.color))
    if self.super.cleanup then self.super.cleanup(self) end
  end
}
