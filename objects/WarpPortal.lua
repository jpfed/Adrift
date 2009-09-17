love.filesystem.require("oo.lua")
love.filesystem.require("objects/SimplePhysicsObject.lua")
love.filesystem.require("graphics/RepresentableAsImage.lua")

WarpPortal = {
  super = SimplePhysicsObject,
  image = love.graphics.newImage("graphics/warpPortal.png"),
  imageSize = 2,
  sound = love.audio.newSound("sound/portal.ogg"),
  
  create = function(self,world,node)
    local ssBody = love.physics.newBody(world,node.x,node.y,0)
    local ssShape = love.physics.newCircleShape(ssBody,0.75)
    ssShape:setSensor(true)
    
    local result = SimplePhysicsObject:create(ssBody, ssShape)
    mixin(result,RepresentableAsImage)
    mixin(result, WarpPortal)
    result.class = WarpPortal
    return result
  end
}
