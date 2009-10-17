love.filesystem.require("oo.lua")
love.filesystem.require("objects/composable/DamageableObject.lua")
love.filesystem.require("objects/composable/MultipleBlobObject.lua")

Grasshopper = {
  super = MultipleBlobObject,
  
  color = love.graphics.newColor(10,150,30),
  color_edge = love.graphics.newColor(20,120,60),
  
  deathSound = love.audio.newSound("sound/hornetDeath.ogg"),
  
  create = function(self, x, y, difficulty)
    local r = MultipleBlobObject:create(x,y)

    r.superUpdate = r.update
    r.superCleanup = r.cleanup
    mixin(r, Grasshopper)
    r.class = Grasshopper

    local leftLeg = {{x=0,y=-3}, {x=3,y=0}, {x=2,y=0.5}, {x=0,y=-2}}
    local rightLeg = {{x=0,y=-3}, {x=0,y=-2}, {x=-2,y=0.5}, {x=-3,y=0}}
    r.blob = r:addConvexBlob(
      { damping = 0.1, adamping = 0.1 },
      { scale = 0.3, points = leftLeg, color = self.color, color_edge = self.color_edge } )
    r.blob:addConvexShape(
      { scale = 0.3, points = rightLeg, color = self.color, color_edge = self.color_edge } )

    mixin(r, DamageableObject:prepareAttribute(difficulty,10,Grasshopper.deathSound,500))
    
    return r
  end,
  
  update = function(self, dt)
    self:superUpdate(dt)
    if self.touchedWall then
      -- This isn't getting called, so probably everything in here is wrong; 
      -- also there should be a cooldown after touched wall is true...
      self.blob.body:setVelocity(math.random(4) - 2, math.random(10) - 30)
      self.touchedWall = false
    end
  end,

  cleanup = function(self)
    self:superCleanup()
    if math.random() < 0.25 then L:addObject(EnergyPowerup:create(self)) end
  end
}
