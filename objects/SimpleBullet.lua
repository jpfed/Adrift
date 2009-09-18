love.filesystem.require("oo.lua")
love.filesystem.require("objects/Projectile.lua")

SimpleBullet = {
  super = Projectile,
  strikeSound = love.audio.newSound("sound/bulletStrike.ogg"),
  speed = 12,
  radius = 0.075,
  color = nil,
  colorHighlight = love.graphics.newColor(255,255,255,200),
  firer = nil,
  
  
  draw = function(b) 
    local x,y,scale = camera:xy(b.body:getX(),b.body:getY(),0)
    local ox,oy,scale = camera:xy(b.x,b.y,0)
    love.graphics.setBlendMode(love.blend_additive)
    love.graphics.setColor(b.color)
    love.graphics.circle(love.draw_fill,x,y,scale*b.radius)
    love.graphics.setLineWidth(scale*b.radius*2/3)
    love.graphics.line(x,y,ox,oy)
    love.graphics.setColor(b.colorHighlight)
    love.graphics.circle(love.draw_fill,x,y,scale*b.radius*2/3)
    love.graphics.circle(love.draw_fill,x,y,scale*b.radius/5)
    love.graphics.setBlendMode(love.blend_normal)
  end,
  
  create = function(sb, firer, originPoint, color)
    local theta = math.rad(firer.angle + 90)
    local tipx,tipy = originPoint.x, originPoint.y
    local vx,vy = firer.body:getVelocity()
    local mx, my = SimpleBullet.speed*math.cos(theta), SimpleBullet.speed*math.sin(theta)
    vx = vx + mx
    vy = vy + my
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
    return result
  end
  
}
