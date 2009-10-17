love.filesystem.require("oo.lua")
love.filesystem.require("objects/composable/Convex.lua")
love.filesystem.require("objects/composable/Engine.lua")
love.filesystem.require("objects/composable/SimpleGun.lua")
love.filesystem.require("objects/composable/DamageableObject.lua")
love.filesystem.require("objects/composable/SimplePhysicsObject.lua")


Hornet = {
  super = SimplePhysicsObject,
  
  cvx = nil,
  color = love.graphics.newColor(255,0,0),
  
  bulletColor = love.graphics.newColor(255,0,0),
  bulletHighlightColor = love.graphics.newColor(255,100,100,200),
  
  thruster = nil,
  engine = nil,
  thrust = 10,
    
  collisionShock = 0,
  collisionReaction = 1,
  
  gun = nil,
  
  deathSound = love.audio.newSound("sound/hornetDeath.ogg"),
  
  create = function(self, x, y, difficulty)
    local bd = love.physics.newBody(L.world,x,y)
    bd:setMass(0,0,0.5,0.5)
    bd:setDamping(0.1)
    bd:setAngularDamping(0.1)
    bd:setAllowSleep(false)
    bd:setAngle(0)
    
    local s = 0.2
    local pointArray = {2*s,0*s,-1*s,1*s,-1*s,-1*s}
    -- TODO: The Convex:create call below already does this?
    local sh = love.physics.newPolygonShape(bd,unpack(pointArray))
    sh:setRestitution(1.5)
    
    local result = SimplePhysicsObject:create(bd,sh)
    result.superUpdate = result.update
    result.superCleanup = result.cleanup
    
    mixin(result, DamageableObject:prepareAttribute(difficulty,nil,Hornet.deathSound, 1000))
    
    mixin(result, Hornet)
    result.class = Hornet
    
    result.cvx = Convex:create(result, pointArray, self.color, self.color)
    
    result.engine = Engine:create(result, Hornet.thrust, 2,8)
    result.thruster = FireThruster:create(result, 180)
    result.gun = SimpleGun:create(result, pointArray[1], pointArray[2], 0, 1, Hornet.bulletColor, Hornet.bulletHighlightColor)
    
    result.collisionReaction = math.random()*90-45
    result.coolRate = math.random()+0.5
    return result
  end,
  
  update = function(self, dt)
    self.superUpdate(self, dt)
    
    -- go for the main character unless you are recovering from a collision
    local forceX, forceY = 0, 0
    if self.collisionShock == 0 then
      local tx, ty = state.game.ship.x, state.game.ship.y
      local dx, dy = tx - self.x, ty - self.y
      local anorm = math.max(0.01,math.sqrt(dx*dx + dy*dy))
      if anorm < 36 then 
        forceX, forceY = dx / anorm, dy / anorm
      else
        forceX, forceY = math.random()*2-1, math.random()*2-1.1
      end
    else
      -- back away from the wall and move along it in a consistent direction
      local targTheta = math.rad(self.angle + self.collisionReaction)
      forceX, forceY = - math.cos(targTheta), - math.sin(targTheta)
      self.collisionShock = math.max(0,self.collisionShock - dt)
    end
    
    local overallThrust = self.engine:vector(forceX, forceY, dt)
    self.thruster:setIntensity(overallThrust*5)
    self.thruster:update(dt)
    
    -- shoot at all times
    self.gun:fire()
    self.gun:update(dt)
  end,
  
  draw = function(self)
    self.thruster:draw()
    self.cvx:draw()
  end,
  
  cleanup = function(self)
    self:superCleanup()
    if math.random() < 0.25 then L:addObject(EnergyPowerup:create(self)) end
  end
  
}
