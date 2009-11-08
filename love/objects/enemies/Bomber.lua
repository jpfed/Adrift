love.filesystem.require("oo.lua")
love.filesystem.require("objects/composable/SimplePhysicsObject.lua")
love.filesystem.require("objects/composable/DamageableObject.lua")
love.filesystem.require("objects/composable/Convex.lua")
love.filesystem.require("objects/composable/Thruster.lua")
love.filesystem.require("objects/composable/Projectile.lua")
love.filesystem.require("objects/goodies/EnergyPowerup.lua")
love.filesystem.require("objects/composable/AI.lua")

Bomber = {
  super = SimplePhysicsObject,
  
  actionClock = 0,
  action = nil,
  
  cvx = nil,
  lineColor = love.graphics.newColor(128,64,64),
  fillColor = love.graphics.newColor(192,0,0),
    
  
  thruster = nil,
  engine = nil,
  thrust = 4,
    
  deathSound = love.audio.newSound("sound/hornetDeath.ogg"),
    
  
  create = function(self, x, y, difficulty)
    local bd = love.physics.newBody(L.world,x,y,1)
    bd:setMass(0,0,1,1)
    bd:setDamping(0.01)
    bd:setAngularDamping(0.01)
    bd:setAllowSleep(false)
    bd:setAngle(0)
    
    local s = 0.2
    local pointArray = {2*s,0*s, 0*s,3*s, -1*s,0*s, 0*s,-3*s}
 
    local result = SimplePhysicsObject:create(bd)
    
    mixin(result,DamageableObject:attribute(difficulty,nil,self.deathSound, 1000))
    mixin(result,CollectorObject:attribute())
    
    mixin(result,Bomber)
    result.class = Bomber
    
    result.planner = Planner:create(result)
    result.planner:addStrategy(AI.flee, AI.playerAnticipator, 0.5)
    result.planner:addStrategy(AI.flee, AI.nearbyWalls, 0.5)
    result.planner:addStrategy(AI.dodge, AI.nearbyWalls, 1.0)
    --result.planner:addStrategy(AI.dodge, AI.approachingProjectiles, 0.5)
    
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
  end,
  
  draw = function(self)
    self.thruster:draw()
    self.cvx:draw()
  end,
  
  cleanup = function(self)
    self.cvx:cleanup()
    SimplePhysicsObject.cleanup(self)
    self:inventoryDropAll()
    if math.random() < 0.25 then L:addObject(EnergyPowerup:create(self)) end
  end
}
