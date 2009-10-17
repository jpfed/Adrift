love.filesystem.require("oo.lua")
love.filesystem.require("objects/composable/GameObject.lua")
love.filesystem.require("objects/composable/Blob.lua")

MultipleBlobObject = {
  super = GameObject,
  
  create = function(self, x, y)
    -- we don't have x and y yet until blobs are added
    local result = GameObject:create(x,y)
    mixin(result,MultipleBlobObject)
    result.class = MultipleBlobObject
    result.blobs = {}
    return result 
  end,

  addConvexBlob = function(self,bodyParams,shapeParams)
    local b = Blob:create(self,bodyParams)
    b:addConvexShape(shapeParams)
    b.body:setMassFromShapes()
    table.insert(self.blobs, b)
    if not self.body then self.body = b.body end
    return b
  end,
  
  draw = function(self)
    for k,v in pairs(self.blobs) do
      v:draw()
    end
  end,

  update = function(self,dt)
    GameObject:update(dt)
    for k,v in pairs(self.blobs) do
      v:update(dt)
    end
    self.x = self.blobs[1].x
    self.y = self.blobs[1].y
    self.angle = self.blobs[1].angle
  end,
  
  cleanup = function(self)
    GameObject.cleanup(self)
    for k,blob in pairs(self.blobs) do
      blob:cleanup()
    end
  end
}
