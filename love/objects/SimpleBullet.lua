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
    self.sparks:update(dt)
  end,
  
  draw = function(b) 
    local x,y,scale = camera:xy(b.body:getX(),b.body:getY(),0)
    love.graphics.setColorMode(love.color_modulate)
    love.graphics.draw(b.sparks,x,y)
    love.graphics.setColorMode(love.color_normal)
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
    s:setDirection(originPoint.angle - 180)
    s:setRotation(theta + math.pi / 2)
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
