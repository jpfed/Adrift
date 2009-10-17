love.filesystem.require("oo.lua")
love.filesystem.require("objects/composable/DamageableObject.lua")
love.filesystem.require("objects/composable/MultipleBlobObject.lua")


Leech = {
  super = MultipleBlobObject,
  
  color = love.graphics.newColor(30,200,60),
  color_edge = love.graphics.newColor(20,100,50),
  
  deathSound = love.audio.newSound("sound/hornetDeath.ogg"),
  
  create = function(self, x, y, difficulty)
    local r = MultipleBlobObject:create(x,y)

    r.superCleanup = r.cleanup
    mixin(r, Leech)
    r.class = Leech

    local leechPoints = {{x=6,y=0}, {x=5,y=1}, {x=1,y=0.8}, {x=0,y=0}, {x=1,y=-0.8}, {x=5,y=-1}}
    r.part1 = r:addConvexBlob(
      { damping = 0.1, adamping = 0.1 },
      { scale = 0.1, points = leechPoints, color = self.color, color_edge = self.color_edge } )
    r.part2 = r:addConvexBlob(
      { damping = 0.1, adamping = 0.1 },
      { scale = 0.1, points = leechPoints, color = self.color, color_edge = self.color_edge, offset={x=5,y=0} } )
    r.part3 = r:addConvexBlob(
      { damping = 0.1, adamping = 0.1 },
      { scale = 0.1, points = leechPoints, color = self.color, color_edge = self.color_edge, offset={x=10,y=0} } )

    -- Now to joint them together!
    love.physics.newRevoluteJoint( r.part1.body, r.part2.body, 0.55, 0 ) 
    love.physics.newRevoluteJoint( r.part2.body, r.part3.body, 1.1, 0 ) 


    mixin(r, DamageableObject:prepareAttribute(difficulty,nil,Leech.deathSound,1000))
    
    return r
  end,
  
  cleanup = function(self)
    self:superCleanup()
    if math.random() < 0.25 then L:addObject(EnergyPowerup:create(self)) end
  end
}
