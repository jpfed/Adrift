love.filesystem.require("oo.lua")
love.filesystem.require("util/geom.lua")
love.filesystem.require("objects/composable/Convex.lua")
love.filesystem.require("objects/composable/Engine.lua")
love.filesystem.require("objects/composable/SimpleGun.lua")
love.filesystem.require("objects/composable/Projectile.lua")
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
  maxCollisionShock = 1,
  collisionReaction = 0,
  
  gun = nil,
  
  deathSound = love.audio.newSound("sound/hornetDeath.ogg"),
  
  collided = function(self)
    if self.collisionShock == 0 then
      self.collisionShock = math.random()*math.random()*self.maxCollisionShock
      self.collisionReaction = math.random(2)*90 - 135
      self.targTheta = math.rad(self.angle + self.collisionReaction)
    end
  end,
  
  create = function(self, x, y, difficulty)
    local bd = love.physics.newBody(L.world,x,y)
    bd:setMass(0,0,0.5,0.5)
    bd:setDamping(0.1)
    bd:setAngularDamping(0.1)
    bd:setAllowSleep(false)
    bd:setAngle(0)
    
    local s = 0.2
    local pointArray = {2*s,0*s,-1*s,1*s,-1*s,-1*s}
    local sh = love.physics.newPolygonShape(bd,unpack(pointArray))
    sh:setRestitution(0.5)
    
    local result = SimplePhysicsObject:create(bd,sh)
    result.superUpdate = result.update
    result.superCleanup = result.cleanup
    
    mixin(result, DamageableObject:attribute(difficulty,nil,Hornet.deathSound, 1000))
    
    mixin(result, Hornet)
    result.class = Hornet
    
    result.cvx = Convex:create(result, pointArray, self.color, self.color)
    
    result.engine = Engine:create(result, Hornet.thrust, 2,8)
    result.thruster = FireThruster:create(result, 180)
    result.gun = SimpleGun:create({
      parent = result,
      ammo = math.huge,
      mountX = pointArray[1],
      mountY = pointArray[2],
      mountAngle = 0,
      shotsPerSecond = math.random()+0.5,
      spawnProjectile = function(self, params)
        return SimpleBullet:create(self.parent, params, result.bulletColor, result.bulletHighlightColor)
      end
    })

    result.strafe = SidestepPower:create(result)
    result.strafe.orientation = math.random(2)*2-3
    result.collisionReaction = math.random(2)*90-135
    
    return result
  end,
  
  update = function(self, dt)
    self.superUpdate(self, dt)
    
    -- go for the main character unless 
    --   you are recovering from a collision or
    --   there is someone in your way
    local forceX, forceY, mustStrafe = 0, 0, false
    if self.collisionShock == 0 then
      
      local ship = state.game.ship
      
      if self.gun.heat == 0 then
        local minX, maxX = math.min(self.x, ship.x), math.max(self.x, ship.x)
        local minY, maxY = math.min(self.y, ship.y), math.max(self.y, ship.y)
        
        for k,v in pairs(L.objects) do
          if minX < v.x and v.x < maxX and minY < v.y and v.y < maxY then
            if not AhasAttributeB(v, Projectile) then
              if geom.dist_to_line_t(v,self,ship) < 2 then mustStrafe = true; break; end
            end
          end
        end
      end
      
      if mustStrafe then
        self.strafe:trigger()
      else
        local dx, dy = ship.x - self.x, ship.y - self.y
        local anorm = math.max(0.01,math.sqrt(dx*dx + dy*dy))
        if anorm < 36 then 
          forceX, forceY = dx / anorm, dy / anorm
        else
          forceX, forceY = math.random()*2-1, math.random()*2-1.1
        end
      end
    else
      -- back away from the wall and move along it in a consistent direction
      forceX, forceY = - math.cos(self.targTheta), - math.sin(self.targTheta)
      self.collisionShock = math.max(0,self.collisionShock - dt)
    end
    
    local overallThrust = self.engine:vector(forceX, forceY, dt)
    self.thruster:setIntensity(overallThrust*5)
    self.thruster:update(dt)
    
    self.strafe:update(dt)
    
    -- shoot at all times
    if not mustStrafe then self.gun:fire() end
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
