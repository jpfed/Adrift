love.filesystem.require("oo.lua")
love.filesystem.require("objects/composable/Projectile.lua")
love.filesystem.require("objects/composable/Convex.lua")

HomingMissile = {
  super = Projectile,
  speed = 5,
  radius = 0.1,
  damage = 2,
  missileFadeColor = love.graphics.newColor(128,128,128,0),
  fireSound = love.audio.newSound("sound/homingMissileFire.ogg"),
  engineSound = love.audio.newSound("sound/homingMissileEngine.ogg"),
  explodeSound = love.audio.newSound("sound/homingMissileExplosion.ogg"),
  engineSoundT = 0,
  
  touchDamageable = function(self,d) 
    if not self.dead then
      d:damage(self.damage)
      self.dead = true
    end
  end,
  
  update = function(self, dt)
    SimplePhysicsObject.update(self,dt)
    local vx, vy = self.body:getVelocity()
    local orientation = math.atan2(vy,vx)
    local speed = geom.distance(vx,vy,0,0)
    local speedRatio = speed/HomingMissile.speed
    local s = self.smoke
    s:setDirection(math.deg(orientation) - 180)
    s:setRotation(orientation + math.pi / 2)
    s:setSpeed(20+speed*2,20+speed*3)
    s:setSize(0.1+speedRatio, 2+speedRatio, 1)
    self.smoke:update(dt)
    
    if self.target then
      local t = self.target
      local dx, dy = geom.normalize(t.x - self.x, t.y - self.y)
      self.engine:vector(dx, dy, dt)
    end
    
    self.engineSoundT = math.max(0, self.engineSoundT - dt)
    if self.engineSoundT == 0 then
      love.audio.play(self.engineSound)
      self.engineSoundT = 0.1
    end
    
  end,
  
  draw = function(b) 
    local x,y,scale = L:xy(b.body:getX(),b.body:getY(),0)
    love.graphics.setColorMode(love.color_modulate)
    love.graphics.draw(b.smoke,x,y)
    love.graphics.setColorMode(love.color_normal)
    love.graphics.setColor(b.color)
    love.graphics.circle(love.draw_fill,x,y,b.radius*scale,16)
    b.convex:draw()
  end,
  
  create = function(sb, firer, target, originPoint, color, missileTrailColor)
    local theta = math.rad(originPoint.angle)
    local tipx,tipy = originPoint.x, originPoint.y
    local vx,vy = firer.body:getVelocity()
    local mx, my = HomingMissile.speed*math.cos(theta), HomingMissile.speed*math.sin(theta)
    vx = vx + mx
    vy = vy + my
    local v = vx + vy
    local sbBody = love.physics.newBody(L.world, tipx+mx/60,tipy+my/60,0.01)
    local sbShape = love.physics.newCircleShape(sbBody, HomingMissile.radius)
    sbBody:setBullet(true)
    sbBody:setVelocity(vx,vy)
    
    
    local result = Projectile:create(sbBody, sbShape)
    mixin(result, HomingMissile)
    result.class = HomingMissile
    result.color = color
    result.firer = firer
    result.target = target

    result.engine = Engine:create(result, 30, 2, 2)
    
    local orientation = math.atan2(vy,vx)
    sbBody:setAngle(math.deg(orientation))
    result.smoke = love.graphics.newParticleSystem(love.graphics.newImage("graphics/smoke.png"), 300)
    local s = result.smoke
    s:setEmissionRate(5)
    s:setParticleLife(1,1.5)
    s:setDirection(math.deg(orientation) - 180)
    s:setRotation(0,360)
    s:setSpread(25)
    s:setSpeed(v,v+10)
    s:setRadialAcceleration(5,5)
    s:setGravity(0)
    s:setSize(0.1, 1, 1)
    s:setColor(missileTrailColor, result.missileFadeColor)
    s:start()

    local sc = HomingMissile.radius*2
    local points = {1*sc,0*sc,0.25*sc,0.25*sc,-0.25*sc,0.25*sc,-1*sc,0*sc,-0.25*sc,0.25*sc,0.25*sc,0.25*sc}
    result.convex = Convex:create(result, points, result.color, result.color)
    
    return result
  end,
  
  cleanup = function(self)
    love.audio.play(self.explodeSound)
    L:addObject(FireyExplosion:create(self.x,self.y,60,2.0))
    if self.super.cleanup then self.super.cleanup(self) end
  end
}
