love.filesystem.require("util/geom.lua")

Triangle = {
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
    return 3
  end,

  has_overlap = function(t1, t2)
    return false
  end,

  has_inside = function(t1, t2)
    return false
  end
}
