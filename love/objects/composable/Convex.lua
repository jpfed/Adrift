love.filesystem.require("oo.lua")

Convex = {
  
  lineColor = nil,
  fillColor = nil,
  
  create = function(self, parent, pointArray, lineColor, fillColor)
    assert(parent.body ~= nil)
    local result = {}
    mixin(result,Convex)
    result.parent = parent
    result.pointArray = pointArray
    result._rotatedPoints = {}
    result._projectedPoints = {}
    result:_rotatePoints(0)
    result.shape = love.physics.newPolygonShape(parent.body,unpack(pointArray))
    result.shape:setData(parent)
    result.lineColor = lineColor
    result.fillColor = fillColor
    return result
  end,

  _rotatePoints = function(self, angle)
    local r,i = math.cos(math.rad(angle)), math.sin(math.rad(angle))
    local x,y
    local pointArray = self.pointArray
    local numPoints = table.getn(pointArray)/2
    for point = 1,numPoints do 
      x = pointArray[point*2-1]
      y = pointArray[point*2]
      
      x,y = x*r - y*i, x*i + y*r
      self._rotatedPoints[point*2 -1] = x
      self._rotatedPoints[point*2] = y
    end
  end,
  
  _projectPoints = function(self)
    local cx, cy = self.parent.x, self.parent.y
    local rotatedPoints = self._rotatedPoints
    local numPoints, x, y = table.getn(rotatedPoints)/2
    for point = 1,numPoints do
      x, y = cx + rotatedPoints[point*2-1], cy + rotatedPoints[point*2]
      self._projectedPoints[point*2 -1], self._projectedPoints[point*2] = L:xy(x,y,0)
    end
  end,
  
  draw = function(self)
    self:_rotatePoints(self.parent.angle)
    self:_projectPoints()
    
    love.graphics.setColor(self.fillColor)
    love.graphics.polygon(love.draw_fill, unpack(self._projectedPoints))
    love.graphics.setColor(self.lineColor)
    love.graphics.polygon(love.draw_line, unpack(self._projectedPoints))
  end,
  
  cleanup = function(self)
    self.pointArray = nil
    self._rotatedPoints = nil
    self._projectedPoints = nil
  end
  
}
