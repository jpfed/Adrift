require("util/geom.lua")

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
    -- bounding box test
    if math.max(t1[1],t1[3],t1[5]) < math.min(t2[1],t2[3],t2[5]) then return false end
    if math.min(t1[1],t1[3],t1[5]) > math.max(t2[1],t2[3],t2[5]) then return false end
    if math.max(t1[2],t1[4],t1[6]) < math.min(t2[2],t2[4],t2[6]) then return false end
    if math.min(t1[2],t1[4],t1[6]) > math.max(t2[2],t2[4],t2[6]) then return false end
      
    for e1 = 1,3 do

      local w1 = e1 % 3 + 1
      local edge1tail = {x = t1[e1*2-1], y = t1[e1*2]}
      local edge1head = {x = t1[w1*2-1], y = t1[w1*2]}
      
      for e2 = 1,3 do
        local w2 = e2 % 3 + 1
        local edge2tail = {x = t2[e2*2-1], y = t2[e2*2]}
        local edge2head = {x = t2[w2*2-1], y = t2[w2*2]}

        if geom.intersect_t(edge1tail,edge1head, edge2tail,edge2head) then return true end
      end
    end
    
    return Triangle.has_inside(t2,t1) or Triangle.has_inside(t1,t2)
  end,

  -- look along the edges of a triangle in turn
  -- a point in the interior is always to your left (or always to your right)
  has_point_inside = function(t, x, y)
    local o1, o2, o3
    o1 = geom.ccw(t[1],t[2],t[3],t[4],x,y)
    o2 = geom.ccw(t[3],t[4],t[5],t[6],x,y)
    o3 = geom.ccw(t[5],t[6],t[1],t[2],x,y)
    return (o1 == o2) and (o2 == o3)
  end,
    

  has_inside = function(t1, t2)
    -- A triangle t2 can only be inside triangle t1 if each of its points is inside t1
    --print( string.format ( "has_inside called on %s and %s", t1.tostring, t2.tostring ) )
    local is_inside = (
      Triangle.has_point_inside(t1, t2[1], t2[2])
      and
      Triangle.has_point_inside(t1, t2[3], t2[4])
      and
      Triangle.has_point_inside(t1, t2[5], t2[6])
    )
    return is_inside
  end
}
