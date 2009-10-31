love.filesystem.require("oo.lua")
love.filesystem.require("objects/composable/SimplePhysicsObject.lua")
love.filesystem.require("objects/composable/DamageableObject.lua")
love.filesystem.require("objects/enemies/Hornet.lua")

HornetEgg = {

  super = SimplePhysicsObject,
  
  numHornets = 6,
  
  lineColor = love.graphics.newColor(255,0,0),
  fillColor = love.graphics.newColor(128,96,64),
  
  hatchSound = love.audio.newSound("sound/hornetHatch.ogg"),
  
  draw = function(self)
    local x, y, s = L:xy(self.x, self.y, 0)
    love.graphics.setColor(self.fillColor)
    love.graphics.circle(love.draw_fill, x, y, s, 12)
    love.graphics.setColor(self.lineColor)
    love.graphics.circle(love.draw_line, x, y, s, 12)
  end,
  
  update = function(self, dt)
    self:superUpdate(dt)
    if self.armor < self.maxArmor then
      for hCounter = 1,self.numHornets do
        local dx, dy = 4*math.random()-2, 4*math.random() - 2
        local ang = math.deg(math.atan2(dy,dx))
        if not L:solidAt(self.x + dx,self.y + dy) then
          local h = Hornet:create(self.x + dx, self.y + dy, self.difficulty)
          h.body:setAngle(ang)
          L:addObject(h)
        end
      end
      self:damage(self.armor)
    end
  end,
  
  create = function(self, x, y, difficulty)
    
    local bd = love.physics.newBody(L.world,x,y)
    bd:setMass(0,0,0,0)
    bd:setDamping(0.1)
    bd:setAngularDamping(0.1)
    bd:setAllowSleep(false)

    local sh = love.physics.newCircleShape(bd,1)
    sh:setRestitution(0)
    
    local result = SimplePhysicsObject:create(bd,sh)
    result.superUpdate = result.update
    
    mixin(result, DamageableObject:attribute(500,nil,HornetEgg.hatchSound, 0))
    
    mixin(result, HornetEgg)
    result.class = HornetEgg
    
    result.difficulty = difficulty
    
    return result
  end
}