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

  update = function(self, dt)
    if self.cooldown_speed > 0 and self.cooldown_time < self.cooldown_speed then
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
    end
  end,
  
  create = function(self,parent,cooldown_speed,duration,fstart,factive,fend)
    local r = {}
    mixin(r, Power)
    r.class = Power
    r.parent = parent
    r.cooldown_speed = cooldown_speed
    r.cooldown_time = 0
    r.active_time = 0
    r.duration = duration
    r.fstart  = fstart  or Power.doNothing
    r.factive = factive or Power.doNothing
    r.fend    = fend    or Power.doNothing
    r.active = false
    return r
  end
}

BoostPower = {

  fstart = function(self,ship)
    self.originalThrust = ship.engine.thrust
    ship.engine.thrust = ship.engine.thrust + 20
    ship.thruster:setBoost(true)
  end,

  fend = function(self, ship)
    ship.engine.thrust = self.originalThrust
    ship.thruster:setBoost(false)
  end,
  
  create = function(self,parent)
    return Power:create(parent, 2, 0.2, BoostPower.fstart, nil, BoostPower.fend)
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
    return Power:create(parent, 0, 0.2, SidestepPower.fstart, SidestepPower.factive, SidestepPower.fend)
  end

}

TeleportPower = {

  shipUpdate = function(self, dt)
    self:superUpdate(dt)
    self.powers.teleport:update(dt)
  end,

  shipDraw = function(self)
    local x, y, s = camera:xy(self.teleport_system.x, self.teleport_system.y, 0)
    self.teleport_system:draw(x,y)
    local x, y, s = camera:xy(self.x, self.y, 0)
    self.teleport_system:draw(x,y)
    love.graphics.circle(love.draw_line, x, y, math.random()*s, 32)
    self:drawHUD()
  end,
  
  fstart = function(self, ship)
  
    self.drawBackup = ship.draw
    self.updateBackup = ship.update
    ship.draw = TeleportPower.shipDraw
    ship.update = TeleportPower.shipUpdate
    ship.shape:setSensor(true)
    ship.shape:setData(nil)
  
    local originX, originY = ship.body:getPosition()
    local angle = math.rad(ship.angle)
    local svx, svy = math.cos(angle), math.sin(angle)
    
    ship.teleport_system = PortalTeleportSystem:create(originX,originY,ship.angle)

    local vx, vy = geom.normalize(-svx, -svy)   
    
    local found, distanceExceeded, distanceLimit = false, false, 8
    local tiles = L.tiles
    local currentX, currentY = originX, originY
    local lastX, lastY
    while (not found) and (not distanceExceeded) do
      
      lastX, lastY = currentX, currentY
      currentX, currentY = currentX + vx, currentY + vy
      
      local minX, maxX = math.floor(currentX-0.5), math.ceil(currentX+0.5)
      local minY, maxY = math.floor(currentY-0.5), math.ceil(currentY+0.5)
      
      for x=minX,maxX do
        for y=minY,maxY do
          found = found or (tiles[x][y] ~= 0)
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
  end,
  
  fend = function(self, ship)
    ship.teleport_system.ex = self.target.x
    ship.teleport_system.ey = self.target.y
    ship.draw = self.drawBackup
    ship.update = self.updateBackup
    self.system = nil
    ship.shape:setSensor(false)
    ship.shape:setData(ship)
    ship.body:setPosition(self.target.x, self.target.y)
  end,
  
  create = function(self, ship)
    return Power:create(ship, 5, 0.2, TeleportPower.fstart, TeleportPower.factive, TeleportPower.fend)
  end
}
