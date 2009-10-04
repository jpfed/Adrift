love.filesystem.require("util/geom.lua")

Triangle = {
  -- using this in case we want to do caching
  create = function(self,p1,p2,p3,p4,p5,p6)
    return {p1,p2,p3,p4,p5,p6}
  end,

  lengths = function(t)
    local l1 = geom.distance(t[1], t[2], t[3], t[4])
    local l2 = geom.distance(t[3], t[4], t[5], t[6])
    local l3 = geom.distance(t[5], t[6], t[1], t[2])
    return {l1,l2,l3}
  end,

  area = function(t)
    local l = Triangle.lengths(t) 
    local semi = ( l[1] + l[2] + l[3] ) / 2
    local stuff = semi * (semi-l[1]) * (semi-l[2]) * (semi-l[3])
    return math.sqrt(stuff)
  end,

  has_overlap = function(t1, t2)
    return false
  end,

  has_inside = function(t1, t2)
    return false
  end
}
