love.filesystem.require("oo.lua")
love.filesystem.require("objects/composable/CollectibleObject.lua")
love.filesystem.require("objects/composable/MultipleBlobObject.lua")

EnergyChunk = {
  super = MultipleBlobObject,
  image = love.graphics.newImage("graphics/HpPlus.png"),
  sound = love.audio.newSound("sound/HpPlus.ogg"),
  
  color = love.graphics.newColor(20,120,255),
  color_edge = love.graphics.newColor(0,90,200),
  
  effect = function(self, collector) 
    if isA(collector,Ship) then
      state.game.score = state.game.score + 20
      logger:add("Energy inventory: " .. collector.inventory[EnergyChunk])
    end
    self.dead = true
  end,
  
  create = function(self,point)
    local r = MultipleBlobObject:create(point.x,point.y)

    mixin(r, CollectibleObject:attribute(self.sound, self.effect))
    mixin(r, Resource:attribute())
    mixin(r, EnergyChunk)
    r.class = EnergyChunk

    local p1 = r:generateRandomConvex()
    local p2 = r:generateRandomConvex()

    r.scale = math.random(6,10) / 100.0
    r.size = r.scale * 10

    local poly = function(i) 
      local x = math.cos(math.pi / 1.5 * i)
      local y = math.sin(math.pi / 1.5 * i)
      return { 
        scale = r.scale,
        offset = {x = x, y = y},
        points = r:generateRandomConvex(6),
        color = self.color,
        color_edge = self.color_edge,
      }
    end
    
    r.blob = r:addConvexBlob(
      { damping = 0.1, adamping = 0.1 },
      poly(0))
    for i = 1,2 do
      r.blob:addConvexShape(poly(i))
    end

    return r
  end,
  
}
