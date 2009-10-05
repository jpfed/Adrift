love.filesystem.require("oo.lua")
love.filesystem.require("util/geom.lua")

Poly = {
  create = function(self, points)
    local result = {}
    mixin(result,Poly)
    result.points = points
    return result
  end,

  sort_first = function(self, f)
    table.sort(self.points, f)
    return self.points[1]
  end,

  min_x_point = function(self) return self:sort_first( function(a,b) return a.x < b.x end ) end,
  min_x       = function(self) return self:min_x_point().x end,
  max_x_point = function(self) return self:sort_first( function(a,b) return a.x > b.x end ) end,
  max_x       = function(self) return self:max_x_point().x end,
  min_y_point = function(self) return self:sort_first( function(a,b) return a.y < b.y end ) end,
  min_y       = function(self) return self:min_y_point().y end,
  max_y_point = function(self) return self:sort_first( function(a,b) return a.y > b.y end ) end,
  max_y       = function(self) return self:max_y_point().y end,

  bounding_box = function(self)
    return {
        {x=self:min_x(),y=self:min_y()},
        {x=self:max_x(),y=self:max_y()}
      }
  end,

  intersections_with = function(self, p1, p2)
    local box = self:bounding_box()
    if not geom.box_overlap(box[1], box[2], p1, p2) then return false end

    local intersections = {}
    for i,v1 in pairs(self.points) do
      local v2
      if i == 1 then 
        v2 = self.points[#self.points]
      else
        v2 = self.points[i-1]
      end
      if geom.intersect(v1, v2, p1, p2) then
        -- TODO: eventually this should get the actual intersection point, not the segment
        table.insert(intersections, {v1, v2})
      end 
    end
    return intersections
  end,
}
