love.filesystem.require("util/string.lua")

geom = {


  T = function (x,y) return {x=x,y=y} end,
  B  = function (x1,y1,x2,y2) return {p1={x=x1,y=y1},p2={x=x2,y=y2}} end,


  dist_to_line = function(px,py,tx,ty,hx,hy)
    return geom.dist_to_line_t({x=px,y=py},{x=tx,y=ty},{x=hx,y=hy})
  end,

  dist_to_line_t = function(point, tail, head)
    local a = geom.distance_t(head, tail)
    local b = geom.distance_t(point, head)
    local c = geom.distance_t(point, tail)
    local s = (a+b+c)/2
    
    local heronArea = math.sqrt(s*(s-a)*(s-b)*(s-c))
    
    return heronArea*2/a
  end,

  
  
  distance = function(x1,y1,x2,y2)
    local distx, disty = x1 - x2, y1 - y2
    return math.sqrt(distx*distx + disty*disty)
  end,
  
  distance_t = function(p1, p2)
    return geom.distance(p1.x,p1.y,p2.x,p2.y)
  end,


    
  normalize = function(x,y) 
    if x==0 and y==0 then return 0,0 end
    local len = geom.distance(0,0,x,y)
    return x/len, y/len
  end,

  normalize_t = function(v)
    local x, y = geom.normalize(v.x,v.y)
    return x, y
  end,


  
  dot_product = function(x1,y1,x2,y2) 
    return x1*x2 + y1*y2
  end,

  dot_product_t = function(v1,v2)
    return geom.dot_product(v1.x,v1.y,v2.x,v2.y)
  end,

  
  
  cross_product = function(x1,y1,x2,y2) 
    return x1*y2 - x2*y1
  end,
  
  cross_product_t = function(v1,v2)
    return geom.cross_product(v1.x,v1.y,v2.x,v2.y)
  end,
  
  
  
  intersection_point = function(head1x,head1y,tail1x,tail1y,head2x,head2y,tail2x,tail2y,includeEndpoints)
    local head1 = {x = head1x, y = head1y}
    local tail1 = {x = tail1x, x = tail1y}
    local head2 = {x = head2x, y = head2y}
    local tail2 = {x = tail2x, y = tail2y}
    
    local p = geom.intersection_point_t(head1,tail1,head2,tail2,includeEndpoints)
    if p == nil then return nil end
    return p.x, p.y
  end,
  
  intersection_point_t = function(p1,p2,p3,p4, includeEndpoints)
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
  ccw = function(ax,ay,bx,by,cx,cy)
    return (cy-ay)*(bx-ax) >= (by-ay)*(cx-ax)
  end,
  
  ccw_t = function(a, b, c)
    return (c.y-a.y)*(b.x-a.x) >= (b.y-a.y)*(c.x-a.x)
  end,

  
  
  range_overlap = function(t, u, v, w)
    return not (
      math.max(t, u) < math.min(v, w)
      or
      math.min(t, u) > math.max(v, w)
    )
  end,

  -- check if the bounding boxes specified overlap at all
  box_overlap_t = function(a, b, c, d)
    return (
      geom.range_overlap(a.x, b.x, c.x, d.x)
      and
      geom.range_overlap(a.y, b.y, c.y, d.y)
    )
  end,

  box_overlap_b = function(a, b)
    return box_overlap_t(a.x, a.y, b.x, b.y)
  end,

  
  
  intersect_t = function(a, b, c, d)
    if not geom.box_overlap_t(a, b, c, d) then return false end
    return (geom.ccw_t(a,c,d) ~= geom.ccw_t(b,c,d) and geom.ccw_t(a,b,c) ~= geom.ccw_t(a,b,d))
  end
}
