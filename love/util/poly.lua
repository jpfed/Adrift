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

  max_x = function(self)
    return self:sort_first( function(a,b) return a.x > b.x end ).x
  end,

  min_x = function(self)
    return self:sort_first( function(a,b) return a.x < b.x end ).x
  end,

  max_y = function(self)
    return self:sort_first( function(a,b) return a.y > b.y end ).y
  end,

  min_y = function(self)
    return self:sort_first( function(a,b) return a.y < b.y end ).y
  end,

  bounding_box = function(self)
    return {{x=self:min_x(),y=self:min_y()}, {x=self:max_x(),y=self:max_y()}}
  end,
}
