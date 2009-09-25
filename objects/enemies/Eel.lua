love.filesystem.require("oo.lua")
love.filesystem.require("objects/composable/SimplePhysicsObject.lua")
love.filesystem.require("objects/composable/DamageableObject.lua")
love.filesystem.require("objects/composable/Convex.lua")
love.filesystem.require("objects/composable/Thruster.lua")
love.filesystem.require("objects/composable/Projectile.lua")

Eel = {
  super = SimplePhysicsObject,
  
  actionClock = 0,
  action = nil,
  
  cvx = nil,
    lineColor = love.graphics.newColor(255,64,64),
    fillColor = love.graphics.newColor(192,0,0),
    
  
  thruster = nil,
  engine = nil,
    thrust = 12,
    
  shockCounter = 0,
  shockColor = love.graphics.newColor(255,255,255),
  cooldownColor = love.graphics.newColor(255,160,160),
  shockSound = love.audio.newSound("sound/shock.ogg"),
  
  deathSound = love.audio.newSound("sound/hornetDeath.ogg"),
    
  
  create = function(self, world, x, y, difficulty)
    local bd = love.physics.newBody(world,x,y,1)
    bd:setMass(0,0,1,1)
    bd:setDamping(0.01)
    bd:setAngularDamping(0.01)
    bd:setAllowSleep(false)
    bd:setAngle(0)
    
    local s = 0.1
    local pointArray = {2*s,0*s, 1*s,1*s, -1*s,1*s, -2*s,0*s, -1*s,-1*s, 1*s,-1*s}
    
    local sh = love.physics.newPolygonShape(bd,unpack(pointArray))
    
    local result = SimplePhysicsObject:create(bd, sh)
    result.superUpdate = result.update
    
    mixin(result,DamageableObject:prepareAttribute(3+difficulty,nil,Eel.deathSound, 1000))
    
    mixin(result,Eel)
    result.class = Eel
    
    result.cvx = Convex:create(result, pointArray, self.lineColor, self.fillColor)
    result.engine = Engine:create(result, result.thrust, 2, 8)
    result.thruster = FireThruster:create(result, -90)
    
    return result
  end,
  
  update = function(self, dt)
    self.superUpdate(self, dt)
    if self.actionClock == 0 or self.action == nil then
      -- go for the main character
      local attraction = 1
      
      local tx, ty = state.game.ship.x, state.game.ship.y
      local dx, dy = tx - self.x, ty - self.y
      local anorm = math.max(0.01,dx*dx + dy*dy)
      local attractX, attractY = attraction * dx / anorm, attraction * dy / anorm
      
      -- avoid walls
      local wallRepulsion = 1
      
      local searchRadius = 1
      local minX, maxX = math.max(1,math.floor(self.x-searchRadius)), math.min(levelGenerator.maxCol,math.ceil(self.x+searchRadius))
      local minY, maxY = math.max(1,math.floor(self.y-searchRadius)), math.min(levelGenerator.maxRow,math.ceil(self.y+searchRadius))
      
      local repelX, repelY, rnorm = 0,0,1
      local point = {x = 0, y = 0}
      local tiles = state.game.level.tiles
      for x=minX,maxX do
        for y = minY, maxY do
          if tiles[x][y] ~= nil and tiles[x][y] ~= 0 then
            point.x, point.y = x, y
            if geom.distToLine(point, self, state.game.ship) < 2 then
              local rdx, rdy = self.x - x, self.y - y
             
              rnorm = math.max(0.01,rdx*rdx + rdy*rdy)
              local rForceX, rForceY = rdx / rnorm, rdy / rnorm
              repelX, repelY = repelX + rForceX, repelY + rForceY 
            end
          end
        end
      end
      rnorm = math.max(0.01,repelX*repelX + repelY*repelY)
      repelX, repelY = wallRepulsion* repelX/rnorm, wallRepulsion*repelY/rnorm
      
      -- avoid bullets
      local bulletRepulsion = 1
      local selfVx, selfVy = self.body:getVelocity()
      local bulletX, bulletY, bnorm = 0, 0, 1
      for k,v in pairs(state.game.objects) do
        if AisInstanceOfB(v,Projectile) then
          local bx, by = self.x - v.x, self.y - v.y
          local bvx, bvy = v.body:getVelocity()
          
          if bx*(bvx - selfVx) + by*(bvy - selfVy)> 0 then
            bnorm = bx*bx + by*by
            bulletX, bulletY = bulletX + bx/bnorm, bulletY + by/bnorm
          end
        end
      end
      
      bnorm = math.max(0.01,bulletX*bulletX+bulletY*bulletY)
      bulletX, bulletY = bulletRepulsion * bulletX/bnorm, bulletRepulsion * bulletY/bnorm
      
      local forceX, forceY = attractX + repelX + bulletX, attractY + repelY + bulletY
      local norm = math.max(0.01,math.sqrt(forceX*forceX + forceY*forceY))
      forceX, forceY = forceX/norm, forceY/norm
      self.action = {x = forceX, y = forceY}
      self.actionClock = math.random()*math.min(0.25,geom.distance(self.x,self.y,tx,ty)/40)
    else
      self.actionClock = math.max(0,self.actionClock - dt)
    end
    
    local overallThrust = self.engine:vector(self.action.x, self.action.y, dt)
    
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
    self.cvx:draw()
  end,
  
  shock = function(self, other)
    if self.shockCounter == 0 then
      love.audio.play(Eel.shockSound)
      self.shockCounter = 1
      other:damage(1)
    end
  end,
}