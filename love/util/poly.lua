love.filesystem.require("oo.lua")
love.filesystem.require("util/geom.lua")
love.filesystem.require("util/string.lua")

debug = false

function table.shallow_copy(t)
  local t2 = {}
  for k,v in pairs(t) do
    t2[k] = v
  end
  return t2
end

-- extremely naïve
function table.invert(t)
  local t2 = {}
  for k,v in pairs(t) do
    t2[v] = k
  end
  return t2
end

Poly = {
  create = function(self, points)
    local result = {}
    mixin(result,Poly)
    result.points = points
    result.sortpoints = table.shallow_copy(points)
    -- note: assumes polys cannot be defined at the same point
    result.inverse = table.invert(points)
    return result
  end,

  next_point = function(self, i)
    return self.points[i % #self.points + 1]
  end,

  sort_first = function(self, f)
    table.sort(self.sortpoints, f)
    return self.sortpoints[1]
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

  -- Returns intersections as {endpoint1, endpoint2, intersectionpoint}
  intersections_with = function(self, p1, p2)
    local intersections = {}

    local box = self:bounding_box()

    if not geom.box_overlap_t(box[1], box[2], p1, p2) then return intersections end

    for i,v in ipairs(self.points) do
      local w = self:next_point(i)
      local intersect_point = geom.intersection_point_t(v,w,p1,p2,false)
      if intersect_point~=nil then
        local intersection = {v,w,intersect_point}
        table.insert(intersections, intersection)
      end 
    end
    return intersections
  end,

  closest_intersection = function(poly, p1, p2)
    local intersections = poly:intersections_with(p1, p2)
    if (#intersections > 0) then
      pp ("checking intersections", intersections)
      local ip = {}
      -- compute distances -- maybe there is a cheaper way?
      -- also, sometimes we may be past a segment of the line that intersects
      for i,v in ipairs(intersections) do
        table.insert(ip,{v[1],v[2],v[3], geom.distance_t(p1,v[3])})
      end
      local f = function(h,i) return h[4] < i[4] end
      table.sort(ip, f)
      return ip[1]
    else
      return nil
    end
  end,

  union_with = function(s, p)
    local points = {}
    
    local s_index, p_index = 0, 0
    local minsx = s:min_x_point()
    local minpx = p:min_x_point()
    
    if minpx.x < minsx.x then
      -- start from the second poly instead
      p, s = s, p
      minpx, minsx = minsx, minpx
      -- TODO: Should have something for the degenerate case, where min s x = min p x, because then the algorithm has a chance of ½ to start moving through the union incorrectly...
    end

    local start = minsx

    local cursor = start
    local s_index = s.inverse[minsx]
    local cursor_next = s:next_point(s_index)

    while (#points == 0 or cursor ~= start) do
      pp ("cursor", cursor)
      pp ("cursor_next", cursor_next)

      table.insert(points, cursor)

      local intersection = p:closest_intersection(cursor, cursor_next)
      if (intersection) then
        local end1, end2, point = intersection[1], intersection[2], intersection[3]

        pp ("end1", end1)
        pp ("end2", end2)
        pp ("point", point)

        local destination 
        -- Which endpoint do we move towards?
        if geom.ccw_t(cursor, point, end1) then
          destination = end2
        else
          destination = end1
        end
        cursor = point
        cursor_next = destination
        -- Now we're operating on the other polygon, so swap
        p, s = s, p
      else
        cursor = cursor_next
        s_index = s.inverse[cursor]
        cursor_next = s:next_point(s_index)
      end
    end

    return Poly:create(points)
    
  end,
  
  has_point_inside = function(poly, point)
    local orientation = geom.ccw_t(poly.points[1],poly.points[2],point)
    local numPoints = #poly.points
    for k,v in pairs(poly.points) do
      local o = geom.ccw_t(poly.points[k], poly.points[k % numPoints + 1], point)
      if o ~= orientation then return false end
    end
    return true
  end,
  
  
  -- subdivide the poly into subPolys, with one subdividing ray intersecting with the poly edge at interPoint
  subdivide = function(self, interPoint, num)
    if self.subPolys == nil then
      if num == nil then num = math.random(2)+math.random(2)+1 end
      self.subPolys = {}
      local width = self:max_x_point().x - self:min_x_point().x
      local height = self:max_y_point().y - self:min_y_point().y
      local length = (width+height)
    
      local x, y = 0, 0
      for k, v in pairs(self.points) do
        x, y = x + v.x, y + v.y
      end      
      x, y = x/#(self.points), y/#(self.points)
    
      local center = {x = x, y = y}
      local perimeter = {}
      local newPolys = {}
      local rays = {}
      -- the spread of rays is randomly rotated
      local dtheta = math.random()*math.pi
      if interPoint then
        dtheta = math.atan2(interPoint.y - center.y, interPoint.x - center.x)
      end
      
      for r = 1, num do
        local theta = -2*math.pi*r/num + dtheta
        -- the rays are evenly spread about the central point- no jitter
        local ray = {x = x + length*math.cos(theta), y = y + length*math.sin(theta), r = r}
        table.insert(rays, ray)
      end
      
      -- seek forward around the poly until you hit the first ray intersection
      local polyC = 1
      local rayC = 1
      local rayFound = false
      repeat
        local nextPolyC = polyC % #(self.points) + 1
        local p = geom.intersection_point_t(self.points[polyC], self.points[nextPolyC], center, rays[rayC], true)
        if p == nil then
          polyC = nextPolyC
        else
          p.ray = rayC
          table.insert(perimeter, p)
          table.insert(newPolys, rayC)
          rayC = rayC % num + 1
          rayFound = true
        end
      until rayFound
      
      local startingPoint = polyC
      local numOriginalEdgesTraversed = 0
      local numIntersectionsEncountered = 1
      repeat
        local nextPolyC = polyC % #(self.points) + 1
        local p = geom.intersection_point_t(self.points[polyC], self.points[nextPolyC], center, rays[rayC], true)
        if p == nil then
          polyC = nextPolyC
          table.insert(perimeter, self.points[polyC])
          numOriginalEdgesTraversed = numOriginalEdgesTraversed + 1
        else
          p.ray = rayC
          table.insert(perimeter, p)
          table.insert(newPolys, #perimeter)
          rayC = rayC % num + 1
          numIntersectionsEncountered = numIntersectionsEncountered + 1
        end
      until numOriginalEdgesTraversed >= #self.points and numIntersectionsEncountered >= #rays

      -- form lists of vertices for each new poly, starting at the ray intersection points
      -- (there should be a new poly for each ray intersection point)
      for k, v in pairs(newPolys) do
        local polyPoints = {perimeter[v]}
        local p = v
        repeat
          p = p % #perimeter + 1
          table.insert(polyPoints, perimeter[p])
        until perimeter[p].ray
        perimeter[p].ray = nil
        table.insert(polyPoints, center)
        table.insert(self.subPolys, Poly:create(polyPoints))
      end
    end
  end,
  
  subdivide_r = function(self, depth, interPoint, num)
    if depth > 0 and self.subPolys == nil then 
      self:subdivide(interPoint, num)
      for k,v in pairs(self.subPolys) do
        v:subdivide_r(depth-1,interPoint, num)
      end
    end
  end,
  
  subPolyAt = function(self, point)
    if #self.subPolys > 0 then
      for k, v in pairs(self.subPolys) do
        if v:has_point_inside(point) then return v:subPolyAt(point) end
      end
    else
      return self
    end
  end,
  
  subPolyLeaves = function(self, result)
    if result == nil then result = {} end
    if self.subPolys ~= nil then 
      for k, v in pairs(self.subPolys) do
        v:subPolyLeaves(result)
      end
    else
      table.insert(result, self)
    end
    return result
  end,
  
  projectPoints = function(self, cx, cy, angle)
    local cos,sin = math.cos(math.rad(angle)), math.sin(math.rad(angle))
    local ps = {}
    local x,y

    for i,point in ipairs(self.points) do
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
