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
    -- I'm not sure if it's cheaper to check if any of the points in t2 is in 
    -- t1 first and vice versa, or not...
    --
    -- So, considering just checking each possible combination of line segments
    --
    -- One thing I *am* sure of: I am terrible at math code!
    --
    -- TODO: Should check bounding boxes of triangles first

    return false
  end,

  has_point_inside = function(t, x, y)
    -- This is a cheesy algorithm, but it makes sense if you draw it out: if 
    -- you sum up the areas of the triangle replacing one point with the 
    -- input point, the sum should be <= the triangle's area if the point is 
    -- inside the triangle.
    local actual_area = Triangle.area(t)
    local a1 = Triangle.area(Triangle:create(x,y,t[1],t[2],t[3],t[4]))
    local a2 = Triangle.area(Triangle:create(x,y,t[3],t[4],t[5],t[6]))
    local a3 = Triangle.area(Triangle:create(x,y,t[5],t[6],t[1],t[2]))
    local sum = (a1 + a2 + a3)
    -- I don't understand lua floats... I was trying to debug this but it was 
    -- easier to add a fudge factor to the result
    -- print( string.format ( "a: %s sum: %s a1: %s a2: %s a3: %s", actual_area, sum, a1, a2, a3 ) )
    return sum <= actual_area + 0.0000001
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
