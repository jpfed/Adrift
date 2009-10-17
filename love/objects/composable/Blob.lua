love.filesystem.require("oo.lua")
love.filesystem.require("objects/composable/GameObject.lua")
love.filesystem.require("objects/composable/BlobPoly.lua")

Blob = {
  super = GameObject,

  create = function(self, parent, bodyParams)
    local b = GameObject:create(0,0)
    mixin(b,Blob)
    b.class = Blob
    b.parent = parent
    b.body = b:_createBody(bodyParams)
    b.shapes = {}
    b.polys = {}
    return b 
  end,

  _createBody = function(b, p)
    local x, y = p.x or 0, p.y or 0
    local body = love.physics.newBody(L.world,x,y)
    --if p.mass then      body:setMass(p.mass[1],p.mass[2],p.mass[3],p.mass[4]) end
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

  addConvexShape = function(b, polyParams)
    local poly = BlobPoly:create(polyParams)
    local shape = b:_createShape(poly:listPoints())
    table.insert(b.polys,poly)
    return shape
  end,

  draw = function(self)
    for i,poly in ipairs(self.polys) do
      local points = poly:projectPoints(self.body:getX(), self.body:getY(), self.body:getAngle())
      love.graphics.setColor(poly.color)
      love.graphics.circle(love.draw_fill, self.body:getX(), self.body:getY(), 10, 32)
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
    for k,shape in self.shapes do
      shape:setData(nil)
      shape:destroy()
      shape = nil
    end
    self.body:destroy()
    self.body = nil
  end
}
