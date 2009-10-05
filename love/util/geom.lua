geom = {

  distToLine = function(point, tail, head)
    local a = geom.length(head, tail)
    local b = geom.length(point, head)
    local c = geom.length(point, tail)
    local s = (a+b+c)/2
    
    local heronArea = math.sqrt(s*(s-a)*(s-b)*(s-c))
    
    return heronArea*2/a
  end,

  length = function(p1, p2)
    return geom.distance(p1.x,p1.y,p2.x,p2.y)
  end,

  distance = function(x1,y1,x2,y2)
    local distx, disty = x1 - x2, y1 - y2
    return math.sqrt(distx*distx + disty*disty)
  end,
  
  normalize = function(x,y) 
    if x==0 and y==0 then return 0,0 end
    local len = geom.distance(0,0,x,y)
    return x/len, y/len
  end,
  
  dotProduct = function(x1,y1,x2,y2) 
    return x1*x2 + y1*y2
  end,
  crossProduct = function(x1,y1,x2,y2) 
    return x1*y2 - x2*y1
  end,
  
  intersectionPoint = function(p1,p2,p3,p4, includeEndpoints)
    local d = (p4.y-p3.y)*(p2.x-p1.x) - (p4.x-p3.x)*(p2.y-p1.y)
    if d == 0 then return nil end
    local n1 = (p4.x-p3.x)*(p1.y-p3.y)-(p4.y-p3.y)*(p1.x-p3.x)
    local n2 = (p2.x-p1.x)*(p1.y-p3.y)-(p2.y-p1.y)*(p1.x-p3.x)
    if n1 == 0 and n2 == 0 then return {x = (p1.x+p2.x+p3.x+p4.x)/4, y = (p1.y+p2.y+p3.y+p4.y)/4} end
    
    local u1, u2 = n1/d, n2/d

    local intersectPoint = {x = p1.x + u1*(p2.x-p1.x), y = p1.y + u1*(p2.y-p1.y)}
    if includeEndpoints then
      if (0 <= u1 and u1 <= 1 and 0 <= u2 and u2 <= 1) then return intersectPoint end
    else
      if (0.01 < u1 and u1 < 0.99 and 0.01 < u2 and u2 < 0.99) then return intersectPoint end
    end
    return nil
  end,

  -- checks if three points are in counterclockwise order or not
  ccw = function(a, b, c)
    return (c.y-a.y)*(b.x-a.x) > (b.y-a.y)*(c.x-a.x)
  end,

  range_overlap = function(t, u, v, w)
    return not (
      math.max(t, u) < math.min(v, w)
      or
      math.min(t, u) > math.max(v, w)
    )
  end,

  -- check if the bounding boxes specified overlap
  box_overlap = function(a, b, c, d)
    return (
      geom.range_overlap(a.x, b.x, c.x, d.x)
      and
      geom.range_overlap(a.y, b.y, c.y, d.y)
    )
  end,

  intersect = function(a, b, c, d)
    if not geom.box_overlap(a, b, c, d) then return false end
    return (geom.ccw(a,c,d) ~= geom.ccw(b,c,d) and geom.ccw(a,b,c) ~= geom.ccw(a,b,d))
  end
}
