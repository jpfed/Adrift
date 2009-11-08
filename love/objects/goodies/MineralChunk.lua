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
    if AisInstanceOfB(collector,Ship) then
      state.game.score = state.game.score + 10
      logger:add("Mineral inventory: " .. collector.inventory[MineralChunk])
    end
    self.dead = true
  end,
  
  create = function(self,point)
    local r = MultipleBlobObject:create(point.x,point.y)

    mixin(r, CollectibleObject:attribute(self.sound, self.effect))
    mixin(r, MineralChunk)
    r.class = MineralChunk

    local p1 = self:generateRandomConvex()
    local p2 = self:generateRandomConvex()
    
    r.scale = math.random(10,18) / 100.0
    r.blob = r:addConvexBlob(
      { damping = 0.1, adamping = 0.1 },
      { scale = r.scale, points = p1, color = self.color, color_edge = self.color_edge } )
    r.blob:addConvexShape(
      { scale = r.scale * 0.9, points = p2, color = self.color, color_edge = self.color_edge } )

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
    --local angles = {0, math.pi/2, math.pi, math.pi*3/2}
    local numPoints = math.random(3,8)
    for k = 1, numPoints do
      local r = (2 * math.pi / numPoints) * k
      local tweak = (math.random() - 0.5) * 3 / (numPoints)
      table.insert(angles, r + tweak)
    end
    table.sort(angles)
    for k = 1, numPoints do
      table.insert(result, {x = 1.5*math.cos(angles[k]), y = 1.5*math.sin(angles[k])})
    end
    return result
  end,
}
