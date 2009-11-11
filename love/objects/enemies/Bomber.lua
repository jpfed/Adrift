love.filesystem.require("oo.lua")
love.filesystem.require("objects/composable/MultipleBlobObject.lua")
love.filesystem.require("objects/composable/DamageableObject.lua")
love.filesystem.require("objects/composable/Thruster.lua")
love.filesystem.require("objects/composable/SimpleGun.lua")
love.filesystem.require("objects/composable/Projectile.lua")
love.filesystem.require("objects/ProximityMine.lua")
love.filesystem.require("objects/goodies/ArmorPowerup.lua")
love.filesystem.require("objects/composable/AI.lua")

Bomber = {
  super = MultipleBlobObject,
  
  cvx = nil,
  color = love.graphics.newColor(192,0,0),
  color_edge = love.graphics.newColor(128,64,64),
  color_mine = love.graphics.newColor(192,64,64),
    
  thrust = 3,
    
  deathSound = love.audio.newSound("sound/hornetDeath.ogg"),
    
  create = function(self, x, y, difficulty)
    local r = MultipleBlobObject:create(x,y)
    
    mixin(r,DamageableObject:attribute(difficulty,nil,self.deathSound, 1000))
    mixin(r,CollectorObject:attribute())
    mixin(r,Bomber)
    r.class = Bomber
    
    local scale = 0.2
    local pMain = {{x=3,y=0}, {x=1,y=3}, {x=0,y=0}, {x=1,y=-3}}
    local pBombChute1 = {{x=1,y=1}, {x=-1,y=2}, {x=1,y=0}}
    local pBombChute2 = {{x=1,y=-1}, {x=1,y=0}, {x=-1,y=-2}}

    r.blob = r:addConvexBlob(
      { damping = 0.1, adamping = 0.1 },
      { scale = scale, points = pMain, color = self.color, color_edge = self.color_edge } )
    r.blob:addConvexShape(
      { scale = scale, points = pBombChute1, color = self.color, color_edge = self.color } )
    r.blob:addConvexShape(
      { scale = scale, points = pBombChute2, color = self.color, color_edge = self.color } )

 
    r.planner = Planner:create(r)
    r.planner:addStrategy(AI.approach, AI.collectibles, 0.25)
    r.planner:addStrategy(AI.flee, AI.nearbyWalls(3,16), 1.0)
    r.planner:addStrategy(AI.flee, AI.allProjectiles, 1)
    
    r.engine = Engine:create(r, r.thrust, 2, 8)
    r.thruster = FireThruster:create(r, 180)
    
    r.gun = SimpleGun:create({
      parent = r,
      ammo = math.huge,
      mountX = -0.8,
      mountY = 0,
      mountAngle = 180,
      shotsPerSecond = 0.2,
      spawnProjectile = function(self, params)
        love.audio.play(ProximityMine.placeSound)
        return ProximityMine:create(self.parent, params, Bomber.color_mine)
      end
    })

    return r
  end,
  
  update = function(self, dt)
    MultipleBlobObject.update(self,dt)
    
    local ax, ay = self.planner:getEngineAction()
    local overallThrust = self.engine:vector(ax, ay, dt)
    self.thruster:setIntensity(overallThrust*5)
    self.thruster:update(dt)

    -- For right now, always lay mines
    self.gun:fire()
    self.gun:update(dt)
  end,
  
  draw = function(self)
    self.thruster:draw()
    MultipleBlobObject.draw(self)
  end,
  
  cleanup = function(self)
    MultipleBlobObject.cleanup(self)
    self:inventoryDropAll()
    if math.random() < 0.25 then L:addObject(ArmorPowerup:create(self)) end
  end
}
