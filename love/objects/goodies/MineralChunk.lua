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
    if isA(collector,Ship) then
      state.game.score = state.game.score + 10
      logger:add("Mineral inventory: " .. collector.inventory[MineralChunk])
    end
    self.dead = true
  end,
  
  create = function(self,point)
    local r = MultipleBlobObject:create(point.x,point.y)

    mixin(r, CollectibleObject:attribute(self.sound, self.effect))
    mixin(r, Resource:attribute())
    mixin(r, MineralChunk)
    r.class = MineralChunk

    local p1 = r:generateRandomConvex()
    local p2 = r:generateRandomConvex()
    
    r.scale = math.random(10,18) / 100.0
    r.size = r.scale * 10
    r.blob = r:addConvexBlob(
      { damping = 0.1, adamping = 0.1 },
      { scale = r.scale, points = p1, color = self.color, color_edge = self.color_edge } )
    r.blob:addConvexShape(
      { scale = r.scale * 0.9, points = p2, color = self.color, color_edge = self.color_edge } )

    return r
  end,

}
