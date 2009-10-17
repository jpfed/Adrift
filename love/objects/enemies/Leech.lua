love.filesystem.require("oo.lua")
love.filesystem.require("objects/composable/Convex.lua")
love.filesystem.require("objects/composable/Engine.lua")
love.filesystem.require("objects/composable/DamageableObject.lua")
love.filesystem.require("objects/composable/MultipleBlobObject.lua")


Leech = {
  super = MultipleBlobObject,
  
  color = love.graphics.newColor(30,200,60),
  color_edge = love.graphics.newColor(20,100,50),
  
  thrust = 10,
  collisionShock = 0,
  collisionReaction = 1,
  
  deathSound = love.audio.newSound("sound/hornetDeath.ogg"),
  
  create = function(self, x, y, difficulty)
    local r = MultipleBlobObject:create()

    r.superUpdate = r.update
    r.superCleanup = r.cleanup
    mixin(r, Leech)
    r.class = Leech

    local s = 0.1
    local pointArray = {3*s,0*s, 2*s,1*s, -2*s,1*s, -3*s,0*s, -2*s,-1*s, 2*s,-1*s}
    r.part1 = r:addConvexBlob(
      { damping = 0.1, adamping = 0.1 },
      {
        points = pointArray,
        color = self.color,
        color_edge = self.color_edge
      } )

    mixin(r, DamageableObject:prepareAttribute(difficulty,nil,Leech.deathSound,1000))
    
    r.engine = Engine:create(r, Leech.thrust, 2, 8)
    r.thruster = FireThruster:create(r, 180)
    
    r.collisionReaction = math.random()*90-45
    r.coolRate = math.random()+0.5
    return r
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
  end,
  
  draw = function(self)
    self.thruster:draw()
    --self.part3:draw()
    --self.part2:draw()
    self.part1:draw()
  end,
  
  cleanup = function(self)
    self:superCleanup()
    if math.random() < 0.25 then L:addObject(EnergyPowerup:create(self)) end
  end
}
