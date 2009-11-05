love.filesystem.require("oo.lua")
love.filesystem.require("objects/composable/CollectibleObject.lua")
love.filesystem.require("objects/composable/MultipleBlobObject.lua")

MineralChunk = {
  super = MultipleBlobObject,
  image = love.graphics.newImage("graphics/HpPlus.png"),
  sound = love.audio.newSound("sound/HpPlus.ogg"),
  
  color = love.graphics.newColor(120,120,120),
  color_edge = love.graphics.newColor(90,90,90),
  color_edge = love.graphics.newColor(90,90,90),
  color_texture1 = love.graphics.newColor(90,90,90,32),
  color_texture2 = love.graphics.newColor(100,100,100,200),
  
  effect = function(self, collector) 
    -- no special effect yet
    self.dead = true
  end,
  
  create = function(self,point)
    local r = MultipleBlobObject:create(point.x,point.y)

    --mixin(r, CollectibleObject:attribute(self.sound, self.effect))
    mixin(r, MineralChunk)
    r.class = MineralChunk

    local p1 = self:generateRandomConvex()
    local p2 = self:generateRandomConvex()
    
    r.scale = math.random(1,4) / 20.0
    r.blob = r:addConvexBlob(
      { damping = 0.1, adamping = 0.1 },
      { scale = r.scale, points = p1, color = self.color, color_edge = self.color_edge } )
    r.blob:addConvexShape(
      { scale = r.scale, points = p2, color = self.color, color_edge = self.color_edge } )

    return r
  end,

  update = function(self,dt)
    MultipleBlobObject.update(self,dt)
  end,

  draw = function(self)
    MultipleBlobObject.draw(self)
  end,
  
  generateRandomConvex = function(self)
    local result = {}
    local angles = {}
    local numPoints = math.random(3,8)
    for k = 1, numPoints do
      table.insert(angles, math.random()*2*math.pi)
    end
    table.sort(angles)
    for k = 1, numPoints do
      table.insert(result, {x = 1.5*math.cos(angles[k]), y = 1.5*math.sin(angles[k])})
    end
    return result
  end,
}
