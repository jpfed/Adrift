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
    local distx, disty = p1.x - p2.x, p1.y - p2.y
    return math.sqrt(distx*distx + disty*disty)
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
  end
}