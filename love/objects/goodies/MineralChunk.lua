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
  end,
  
  create = function(self,point)
    local r = MultipleBlobObject:create(point.x,point.y)

    mixin(r, CollectibleObject:attribute(self.sound, self.effect))
    mixin(r, MineralChunk)
    r.class = MineralChunk

    local rand  = function() return math.random(15) / 10.0 end
    -- I'm sure there's a more idiomatic way to do this kind of perturbation, 
    -- but I'm lazy right now! WANTY RESULTS!
    local p = {
      n  = function(p) return {x=p.x,y=p.y-rand()} end,
      s  = function(p) return {x=p.x,y=p.y+rand()} end,
      e  = function(p) return {x=p.x+rand(),y=p.y} end,
      w  = function(p) return {x=p.x-rand(),y=p.y} end,
      ne = function(p) local r = rand(); return {x=p.x+r,y=p.y-r} end,
      nw = function(p) local r = rand(); return {x=p.x-r,y=p.y-r} end,
      sw = function(p) local r = rand(); return {x=p.x-r,y=p.y+r} end,
      se = function(p) local r = rand(); return {x=p.x+r,y=p.y+r} end
    }
    local p1 = {
      p.ne({x=1,y=-1}),
      p.nw({x=-1,y=-1}),
      p.sw({x=-1,y=1}),
      p.se({x=1,y=1})
    }
    local p2 = {
      p.n({x=0,y=-1.5}),
      p.w({x=-1.5,y=0}),
      p.s({x=0,y=1.5}),
      p.e({x=1.5,y=0})
    }
    r.scale = math.random(1,4) / 20.0
    r.blob = r:addConvexBlob(
      { damping = 0.1, adamping = 0.1 },
      { scale = r.scale, points = p1, color = self.color, color_edge = self.color_edge } )
    r.blob:addConvexShape(
      { scale = r.scale, points = p2, color = self.color, color_edge = self.color_edge } )



    r.texture = love.graphics.newParticleSystem(love.graphics.newImage("graphics/smoke.png"), 100)
    local h = r.texture
    h:setEmissionRate(3)
    h:setParticleLife(r.scale * 40,r.scale * 80)
    h:setDirection(0)
    h:setRotation(0,360)
    h:setSpread(360)
    h:setSpeed(0.1,0.2)
    h:setRadialAcceleration(0,0.5)
    h:setGravity(0)
    h:setSize(r.scale * 2,r.scale * 2)
    h:setColor(self.color_texture1, self.color_texture2)
    h:start()
    h:update(120)

    return r
  end,

  update = function(self,dt)
    MultipleBlobObject.update(self,dt)
    self.texture:update(dt)
  end,

  draw = function(self)
    MultipleBlobObject.draw(self)
    local x,y,scale = L:xy(self.x,self.y,0)
    love.graphics.setColorMode(love.color_modulate)
    love.graphics.draw(self.texture,x,y)
    love.graphics.setColorMode(love.color_normal)
  end
}
