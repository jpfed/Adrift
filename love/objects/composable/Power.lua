love.filesystem.require("oo.lua")
love.filesystem.require("util/geom.lua")
love.filesystem.require("util/util.lua")

Power = {
  cooldown = 0,
  
  doNothing = function() end,
  
  trigger = function(self) 
    if self.cooldown_time >= self.cooldown_speed then
      self.active = true
      self.active_time = 0
      self.cooldown_time = 0
      self.fstart(self,self.parent)
    end
  end,

  isCooling = function(self)
    return self.cooldown_speed > 0 and self.cooldown_time < self.cooldown_speed
  end,

  update = function(self, dt)
    if self:isCooling() then
      self.cooldown_time = self.cooldown_time + dt
    end
    if self.active then
      self.active_time = self.active_time + dt
      if self.active_time >= self.duration then
        self.active = false
        if not self.parent.dead then self.fend(self,self.parent) end
      else
        if not self.parent.dead then self.factive(self,self.parent, dt) end
      end
    else
      self.finactive(self, self.parent, dt)
    end
  end,
  
  create = function(self,parent,color,cooldown_speed,duration,fstart,factive,finactive,fend,fdraw,icon)
    local r = {}
    mixin(r, Power)
    r.class = Power
    r.parent = parent
    r.color = color
    r.cooldown_speed = cooldown_speed
    r.cooldown_time = 0
    r.active_time = 0
    r.duration = duration
    r.fstart  = fstart  or Power.doNothing
    r.factive = factive or Power.doNothing
    r.fend    = fend    or Power.doNothing
    r.draw    = fdraw   or Power.doNothing
    r.finactive = finactive or Power.doNothing
    r.active = false
    r.icon = icon
    return r
  end,

  draw_cooldown = function(self, x, y, s)
    if not self.active and self:isCooling() then
      love.graphics.setColorMode(love.color_modulate)
      love.graphics.setBlendMode(love.blend_additive)
      love.graphics.setColor(self.color)
      love.graphics.circle(love.draw_line, x, y, s * 0.3 * (self.cooldown_time - self.cooldown_speed), 32)
      love.graphics.setBlendMode(love.blend_normal)
      love.graphics.setColorMode(love.color_normal)
    end
  end
}

BoostPower = {
  icon = love.graphics.newImage("graphics/booster0.png"),
  sound = love.audio.newSound("sound/booster.ogg"),

  default_thrust_increment = 15,
  powered_thrust_increment = 20,
  
  default_cooldown_speed = 2.5,
  powered_cooldown_speed = 1.5,
  
  
  fstart = function(self,ship)
    self.original_thrust = ship.engine.thrust
    ship.engine.thrust = ship.engine.thrust + self.thrust_increment
    ship.thruster:setBoost(true)
    love.audio.play(BoostPower.sound)
  end,

  fend = function(self, ship)
    ship.engine.thrust = self.original_thrust
    ship.thruster:setBoost(false)
  end,

  fdraw = function(self)
    local x, y, s = L:xy(self.parent.x, self.parent.y, 0)
    self:draw_cooldown(x, y, s)
  end,
  
  create = function(self,parent)
    local result = Power:create(parent, love.graphics.newColor(255,200,20,50), BoostPower.default_cooldown_speed, 0.2, BoostPower.fstart, nil, nil, BoostPower.fend, BoostPower.fdraw, BoostPower.icon)
    result.thrust_increment = BoostPower.default_thrust_increment
    return result
  end
}

SidestepPower = {
  
  fstart = function(self, ship)
    self.vx, self.vy = ship.body:getVelocity()
    if self.orientation == 1 then
      ship.thruster.directionOffset = 270
    else
      ship.thruster.directionOffset = 90
    end
  end,
  
  factive = function(self, ship, dt)
    -- Toned down thrust a bunch to make strafing more controllable and 
    -- hopefully less powerful
    local thrust = ship.engine.thrust / 1.5
    local angle = math.rad(ship.angle)
    local thrustX, thrustY = geom.normalize(-math.sin(angle), math.cos(angle))
    thrustX, thrustY = thrust * self.orientation * thrustX, thrust * self.orientation * thrustY
    local velRetain = math.exp(-12*dt)
    local velChange = 1-velRetain
    ship.body:setVelocity(self.vx * velRetain + thrustX * velChange, self.vy * velRetain + thrustY * velChange)
    -- Make the strafing take on a circle-strafe arc
    local existingSpin = ship.body:getSpin()
    if existingSpin * self.orientation > -80 then   
      ship.body:setSpin(existingSpin + self.orientation * -25)
    end
    ship.thruster:setIntensity(100)
  end,
  
  fend = function(self, ship)
    ship.thruster.directionOffset = 180
  end,
  
  create = function(self, parent)
    return Power:create(parent, love.graphics.newColor(100,100,255,50), 0, 0.2, SidestepPower.fstart, SidestepPower.factive, nil, SidestepPower.fend)
  end

}

TeleportPower = {
  icon = love.graphics.newImage("graphics/teleport2.png"),
  sound = love.audio.newSound("sound/teleport.ogg"),

  shipUpdate = function(self, dt)
    SimplePhysicsObject.update(self,dt)
    self.powers.teleport:update(dt)
  end,

  fdraw = function(self)
    if self.teleport_system then
      local x, y, s = L:xy(self.teleport_system.x, self.teleport_system.y, 0)
      self.teleport_system:draw(x,y)
      local x, y, s = L:xy(self.teleport_system.ex, self.teleport_system.ey, 0)
      self.teleport_system:draw(x,y)
      if not self.active then
        local x, y, s = L:xy(self.parent.x, self.parent.y, 0)
        self:draw_cooldown(x, y, s)
      end
    end
  end,
  
  fstart = function(self, ship)
  
    love.audio.play(TeleportPower.sound)
  
    self.updateBackup = ship.update
    ship.update = TeleportPower.shipUpdate
    ship.shape:setSensor(true)
    ship.shape:setData(nil)
  
    local originX, originY = ship.body:getPosition()
    local angle = math.rad(ship.angle)
    local svx, svy = math.cos(angle), math.sin(angle)
    
    self.teleport_system = PortalTeleportSystem:create(originX,originY,ship.angle)

    local vx, vy = geom.normalize(-svx, -svy)   
    
    local found, distanceExceeded, distanceLimit = false, false, 8
    local currentX, currentY = originX, originY
    local lastX, lastY
    while (not found) and (not distanceExceeded) do
      
      lastX, lastY = currentX, currentY
      currentX, currentY = currentX + vx, currentY + vy
      
      local minX, maxX = math.floor(currentX-0.5), math.ceil(currentX+0.5)
      local minY, maxY = math.floor(currentY-0.5), math.ceil(currentY+0.5)
      
      for x=minX,maxX do
        for y=minY,maxY do
          found = found or L:solidAt(x,y)
        end
      end
      
      distanceExceeded = geom.distance(currentX, currentY, originX, originY) >= distanceLimit 
    end
    self.origin = {x = originX, y = originY}
    self.target = {x = lastX, y = lastY}
  end,
  
  factive = function(self, ship, dt)
    local proportion = self.active_time / self.duration
    local interp = util.interpolate2d(self.origin, self.target, proportion)
    ship.body:setPosition(interp.x, interp.y)
    self.teleport_system.ex = interp.x
    self.teleport_system.ey = interp.y
    if self.teleport_system then self.teleport_system:update(dt) end
  end,

  finactive = function(self, ship, dt)
    if self.teleport_system then self.teleport_system:update(dt) end
  end,
  
  fend = function(self, ship)
    self.teleport_system.ex = self.target.x
    self.teleport_system.ey = self.target.y
    ship.update = self.updateBackup
    self.system = nil
    ship.shape:setSensor(false)
    ship.shape:setData(ship)
    ship.body:setPosition(self.target.x, self.target.y)
  end,
  
  create = function(self, ship)
    return Power:create(ship, love.graphics.newColor(100,100,255,50), 5, 0.2, TeleportPower.fstart, TeleportPower.factive, TeleportPower.finactive, TeleportPower.fend, TeleportPower.fdraw, TeleportPower.icon)
  end
}
