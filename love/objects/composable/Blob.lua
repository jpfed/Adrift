love.filesystem.require("oo.lua")
love.filesystem.require("objects/composable/GameObject.lua")
love.filesystem.require("objects/composable/BlobPoly.lua")

Blob = {
  super = GameObject,

  create = function(self, parent, bodyParams)
    local b = GameObject:create(parent.x,parent.y)
    mixin(b,Blob)
    b.class = Blob
    b.parent = parent
    b.body = b:_createBody(bodyParams)
    b.shapes = {}
    b.polys = {}
    return b 
  end,

  _createBody = function(self, p)
    local x, y = self.parent.x, self.parent.y
    local body = love.physics.newBody(L.world,x,y)
    if p.damping then   body:setDamping(p.damping) end
    if p.adamping then  body:setAngularDamping(p.adamping) end
    body:setAllowSleep(false)
    body:setAngle(0)
    return body
  end,

  _createShape = function(b, p)
    local shape = love.physics.newPolygonShape(b.body,unpack(p))
    shape:setData(b.parent)
    table.insert(b.shapes, shape)
    return shape
  end,

  addConvexShape = function(self, polyParams)
    local poly = BlobPoly:create(polyParams)
    local shape = self:_createShape(poly:listPoints())
    table.insert(self.polys,poly)
    self.body:setMassFromShapes()
    return shape
  end,

  draw = function(self)
    for i,poly in ipairs(self.polys) do
      local points = poly:projectPoints(self.x, self.y, self.angle)
      love.graphics.setColor(poly.color)
      love.graphics.polygon(love.draw_fill, unpack(points))
      love.graphics.setColor(poly.color_edge)
      love.graphics.polygon(love.draw_line, unpack(points))
    end
  end,

  update = function(self,dt)
    GameObject.update(self,dt)
    self.body:setSleep(false)
    self.x = self.body:getX()
    self.y = self.body:getY()
    self.angle = self.body:getAngle()
  end,
  
  cleanup = function(self)
    GameObject.cleanup(self)
    if self.shapes then
      for i,shape in ipairs(self.shapes) do
        shape:setSensor(true)
        shape:setData(nil)
        shape:destroy()
        shape = nil
      end
    end
    self.body:destroy()
    self.body = nil
  end
}
