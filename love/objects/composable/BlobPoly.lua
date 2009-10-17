love.filesystem.require("oo.lua")
BlobPoly = {
  color = love.graphics.newColor(200,200,200),
  color_edge = love.graphics.newColor(100,100,100),

  create = function(self, params)
    local r = {}
    mixin(r,BlobPoly)
    r.class = BlobPoly
    r.points = params.points or {}
    r.color = params.color or self.color 
    r.color_edge = params.color_edge or self.color_edge 
    return r
  end,

  listPoints = function(self)
    local ps = {}
    for i,point in ipairs(self.points) do
      table.insert(ps, point.x)
      table.insert(ps, point.y)
    end
    return ps
  end,

  projectPoints = function(self, cx, cy, angle)
    local r,i = math.cos(math.rad(angle)), math.sin(math.rad(angle))
    local ps = {}
    local x,y

    for i,point in ipairs(self.points) do
      x, y = L:xy(
        cx + (point.x*r - point.y*i),
        cy + (point.x*i + point.y*r),
        0)
      table.insert(ps, x)
      table.insert(ps, y)
    end

    return ps
  end,
}
