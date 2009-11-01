love.filesystem.require("oo.lua")
love.filesystem.require("objects/composable/SimplePhysicsObject.lua")
love.filesystem.require("objects/composable/DamageableObject.lua")
love.filesystem.require("objects/composable/Convex.lua")
love.filesystem.require("objects/composable/Thruster.lua")
love.filesystem.require("objects/composable/Projectile.lua")
love.filesystem.require("objects/goodies/EnergyPowerup.lua")
love.filesystem.require("objects/composable/AI.lua")

Eel = {
  super = SimplePhysicsObject,
  
  actionClock = 0,
  action = nil,
  
  cvx = nil,
    lineColor = love.graphics.newColor(255,64,64),
    fillColor = love.graphics.newColor(192,0,0),
    
  
  thruster = nil,
  engine = nil,
    thrust = 7.5,
    
  shockCounter = 0,
  shockColor = love.graphics.newColor(255,255,255),
  cooldownColor = love.graphics.newColor(255,160,160),
  shockSound = love.audio.newSound("sound/shock.ogg"),
  
  deathSound = love.audio.newSound("sound/hornetDeath.ogg"),
    
  
  create = function(self, x, y, difficulty)
    local bd = love.physics.newBody(L.world,x,y,1)
    bd:setMass(0,0,1,1)
    bd:setDamping(0.01)
    bd:setAngularDamping(0.01)
    bd:setAllowSleep(false)
    bd:setAngle(0)
    
    local s = 0.15
    local pointArray = {2*s,0*s, 1*s,1*s, -1*s,1*s, -2*s,0*s, -1*s,-1*s, 1*s,-1*s}
 
    local result = SimplePhysicsObject:create(bd)
    
    mixin(result,DamageableObject:attribute(difficulty,nil,Eel.deathSound, 1000))
    
    mixin(result,Eel)
    result.class = Eel
    
    result.planner = Planner:create(result)
    result.planner:addStrategy(AI.approach, AI.playerAnticipator, 1)
    result.planner:addStrategy(AI.flee, AI.nearbyWalls, 0.25)
    result.planner:addStrategy(AI.dodge, AI.nearbyWalls, 0.75)
    result.planner:addStrategy(AI.flee, AI.allProjectiles, 2)
    
    result.cvx = Convex:create(result, pointArray, self.lineColor, self.fillColor)
    result.engine = Engine:create(result, result.thrust, 2, 8)
    result.thruster = FireThruster:create(result, 180)
    
    return result
  end,
  
  update = function(self, dt)
    SimplePhysicsObject.update(self, dt)
    
    local ax, ay = self.planner:getEngineAction()
    local overallThrust = self.engine:vector(ax, ay, dt)
    self.thruster:setIntensity(overallThrust*5)
    self.thruster:update(dt)
    
    self.shockCounter = math.max(0,self.shockCounter-dt)
  end,
  
  draw = function(self)
    if self.shockCounter > 0.5 then 
      self.cvx.lineColor = Eel.shockColor
    elseif self.shockCounter > 0 then
      self.cvx.lineColor = Eel.cooldownColor
    else
      self.cvx.lineColor = Eel.lineColor
    end
    self.thruster:draw()
    local w = love.graphics.getLineWidth()
    love.graphics.setLineWidth(w*3)
    self.cvx:draw()
    love.graphics.setLineWidth(w)
  end,
  
  shock = function(self, other)
    if self.shockCounter == 0 then
      love.audio.play(Eel.shockSound)
      self.shockCounter = 0.75
      other:damage(2)
    end
  end,
  
  cleanup = function(self)
    self.cvx:cleanup()
    SimplePhysicsObject.cleanup(self)
    if math.random() < 0.25 then L:addObject(EnergyPowerup:create(self)) end
  end
}
