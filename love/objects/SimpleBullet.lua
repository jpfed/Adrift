love.filesystem.require("oo.lua")
love.filesystem.require("objects/composable/Projectile.lua")

SimpleBullet = {
  super = Projectile,
  strikeSound = love.audio.newSound("sound/bulletStrike.ogg"),
  speed = 10,
  radius = 0.075,
  color = nil,
  firer = nil,
  
  update = function(self, dt)
    SimplePhysicsObject.update(self,dt)
    local vx, vy = self.body:getVelocity()
    local orientation = math.atan2(vy,vx)
    local speed = geom.distance(vx,vy,0,0)
    local speedRatio = speed/SimpleBullet.speed
    local s = self.sparks
    s:setDirection(math.deg(orientation) - 180)
    s:setRotation(orientation + math.pi / 2)
    s:setSpeed(speed*2,speed*3)
    s:setSize(1.5*speedRatio, 0.5*speedRatio, 0.5)
    s:setSpread(20/math.max(1/18,speedRatio))
    s:setEmissionRate(200/math.max(1,speed))
    self.sparks:update(dt)
  end,
  
  draw = function(b) 
    local x,y,scale = camera:xy(b.body:getX(),b.body:getY(),0)
    love.graphics.setColorMode(love.color_modulate)
    love.graphics.draw(b.sparks,x,y)
    love.graphics.setColorMode(love.color_normal)
    love.graphics.setColor(b.color)
    love.graphics.circle(love.draw_fill,x,y,b.radius*scale/2,16)
  end,
  
  create = function(sb, firer, originPoint, color, highlightColor)
    local theta = math.rad(originPoint.angle)
    local tipx,tipy = originPoint.x, originPoint.y
    local vx,vy = firer.body:getVelocity()
    local mx, my = SimpleBullet.speed*math.cos(theta), SimpleBullet.speed*math.sin(theta)
    vx = vx + mx
    vy = vy + my
    local v = vx + vy
    local sbBody = love.physics.newBody(state.game.world, tipx+mx/60,tipy+my/60,0.01)
    local sbShape = love.physics.newCircleShape(sbBody, SimpleBullet.radius)
    sbBody:setBullet(true)
    sbBody:setVelocity(vx,vy)
    sbShape:setSensor(true)
    
    local result = Projectile:create(sbBody, sbShape)
    mixin(result, SimpleBullet)
    result.class = SimpleBullet
    result.color = color
    result.firer = firer

    result.sparks = love.graphics.newParticleSystem(love.graphics.newImage("graphics/gline.png"), 300)
    local s = result.sparks
    s:setEmissionRate(20)
    s:setParticleLife(0.8,0.9)
    local orientation = math.atan2(vy,vx)
    s:setDirection(math.deg(orientation) - 180)
    s:setRotation(orientation + math.pi / 2)
    s:setSpread(25)
    s:setSpeed(v,v+10)
    s:setRadialAcceleration(20,20)
    s:setGravity(0)
    s:setSize(1.5, 0.5, 0.5)
    s:setColor(highlightColor, color)
    s:start()
    s:update(2)

    return result
  end
  
}
