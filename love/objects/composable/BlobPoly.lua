love.filesystem.require("oo.lua")
BlobPoly = {
  color = love.graphics.newColor(200,200,200),
  color_edge = love.graphics.newColor(100,100,100),

  create = function(self, params)
    local r = {}
    mixin(r,BlobPoly)
    r.class = BlobPoly
    r.points = {}
    r.scale = params.scale or 1
    if r.scale == 0 then r.scale = 1 end
    local x,y
    for i,p in ipairs(params.points) do
      x, y = p.x * r.scale, p.y * r.scale
      if params.offset then
        x = x + (params.offset.x * r.scale)
        y = y + (params.offset.y * r.scale)
      end
      table.insert(r.points, {x=x,y=y})
    end
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
    local cos,sin = math.cos(math.rad(angle)), math.sin(math.rad(angle))
    local ps = {}
    local x,y

    for i,point in ipairs(self.points) do
        --cx + (point.x*r - point.y*i),
        --cy + (point.x*i + point.y*r),
        --cx + (point.x),
        --cy + (point.y),
      x, y = L:xy(
        cx + (point.x*cos - point.y*sin),
        cy + (point.x*sin + point.y*cos),
        0)
      table.insert(ps, x)
      table.insert(ps, y)
    end

    return ps
  end,
}
