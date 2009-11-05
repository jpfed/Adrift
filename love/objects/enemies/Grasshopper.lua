love.filesystem.require("oo.lua")
love.filesystem.require("objects/composable/DamageableObject.lua")
love.filesystem.require("objects/composable/MultipleBlobObject.lua")

Grasshopper = {
  super = MultipleBlobObject,
  
  cooldown = 1,
  jumpPending = false,
  canJump = true,
  jumpPower = 5,
  touchedWall = nil,
  excited = false,

  color = love.graphics.newColor(10,150,30),
  color_edge = love.graphics.newColor(20,120,60),
  
  deathSound = love.audio.newSound("sound/hornetDeath.ogg"),
  damageSound = love.audio.newSound("sound/bulletStrike.ogg"),
  
  create = function(self, x, y, difficulty)
    local r = MultipleBlobObject:create(x,y)

    mixin(r, DamageableObject:attribute(difficulty,nil,Grasshopper.deathSound,500))
    mixin(r, CollectorObject:attribute())
    mixin(r, Grasshopper)
    r.class = Grasshopper

    local leftLeg = {{x=0,y=-2}, {x=3,y=0}, {x=2,y=0.5}, {x=0,y=-1}}
    local rightLeg = {{x=0,y=-2}, {x=0,y=-1}, {x=-2,y=0.5}, {x=-3,y=0}}
    local scale = 0.15
    r.blob = r:addConvexBlob(
      { damping = 0.1, adamping = 0.1 },
      { scale = scale, points = leftLeg, color = self.color, color_edge = self.color_edge } )
    r.blob:addConvexShape(
      { scale = scale, points = rightLeg, color = self.color, color_edge = self.color_edge } )

    return r
  end,
  
  update = function(self, dt)
    MultipleBlobObject.update(self,dt)
    if self.cooldown > 0 then
      self.cooldown = self.cooldown - dt
      self.canJump = true
    end
    if self.touchedWall ~= nil or self.jumpPending then
      if self.cooldown <= 0 then
        if self.canJump then
          self.cooldown = 0
          
          self.jumpPending = false
          self:jump(self.touchedWall)
          self.touchedWall = nil
        else
          self.cooldown = 1
        end
      end
    end
  end,

  jump = function(self, pos)
    local dx, dy = geom.normalize(self.x - pos[1], self.y - pos[2])
    dx, dy = geom.normalize(dx+(math.random()-0.5)/2, dy + (math.random()-0.5)/2)
    dx, dy = self.jumpPower * dx, self.jumpPower * dy
    
    
    self.blob.body:setVelocity(dx, dy)
    if self.excited then
      self.cooldown = 0.1
    else
      self.cooldown = 1
    end
    self.canJump = false
  end,

  jump_off = function(self,object, pos)
    if not AisInstanceOfB(object, Grasshopper) then
      object:damage(0.1)
    else
      -- grasshopper mating ritual!
    end
    self.excited = true
    self:jump(pos)
  end,

  cleanup = function(self)
    MultipleBlobObject.cleanup(self)
    if math.random() < 0.25 then L:addObject(EnergyPowerup:create(self)) end
  end
}
