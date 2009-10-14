love.filesystem.require("oo.lua")
love.filesystem.require("objects/composable/SimplePhysicsObject.lua")
love.filesystem.require("objects/composable/PortalSystem.lua")
love.filesystem.require("graphics/RepresentableAsImage.lua")

WarpPortal = {
  super = SimplePhysicsObject,
  sound = love.audio.newSound("sound/portal.ogg"),
  
  draw = function(self)
    local x, y, scale = camera:xy(self.x, self.y, 0)
    self.system:draw(x,y)
    love.graphics.draw(self.image,x,y,scale/25)
  end,
  
  update = function(self, dt)
    if state.game.ship.hasCrystal then
      self.system.darkmatter:setParticleLife(0.375,1.0)
      self.system.haze:setParticleLife(0.5,1.5)
    else
      self.system.darkmatter:setParticleLife(0.25,0.5)
      self.system.haze:setParticleLife(0.25,0.5)
    end
    self.system:update(dt)
  end,

  create = function(self,world,node)
    local ssBody = love.physics.newBody(world,node.x,node.y,0)
    local ssShape = love.physics.newCircleShape(ssBody,0.75)
    ssShape:setSensor(true)
    
    local result = SimplePhysicsObject:create(ssBody, ssShape)
    mixin(result, WarpPortal)
    result.class = WarpPortal

    result.image = love.graphics.newImage("graphics/warpPortal.png")
    result.system = PortalHoleSystem:create(self)
    
    return result
  end
}
