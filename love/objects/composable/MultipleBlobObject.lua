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
    GameObject.update(self,dt)
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
  end,

  generateRandomConvex = function(self, sides)
    local result = {}
    local angles = {}
    --local angles = {0, math.pi/2, math.pi, math.pi*3/2}
    local numPoints 
    if sides then
      numPoints = sides
    else
      numPoints = math.random(3,8)
    end

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
