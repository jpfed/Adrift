love.filesystem.require("oo.lua")
love.filesystem.require("util/geom.lua")

-- I'm going to attempt a standard quadtree for rectangle storage and 
-- retrieval. I want overlap retrieval to be blazing fast, and fast
-- insertion is secondary for now.
--
-- It will contain arbitrary objects as long as they have a bounding box...
-- my arbitrary convention is "p1" for upper left point and "p2" for lower right point
--
-- Initial starting point stolen from http://github.com/samuel/lua-quadtree/blob/master/quadtree.lua
-- but ongoing TDD has invalidated most of that

QuadTree = {
  -- Can init with p1 and p2 as points, or p1 as a box {p1, p2}
  create = function(self, min_size, arg1, arg2)
    local r = {}
    mixin(r,QuadTree)
    r.min_size = min_size
    if arg2 then
      r.p1 = arg1
      r.p2 = arg2
    else
      r.p1 = arg1.p1
      r.p2 = arg1.p2
    end
    r.width  = r.p2.x - r.p1.x
    r.height = r.p2.y - r.p1.y
    r.mx = r.p1.x + r.width
    r.my = r.p1.y + r.height
    r.objects = {}
    return r
  end,

  has_children = function(self)
    return (children ~= nil)
  end,

  overlaps = function(self, object)
    return geom.box_overlap_t(self.p1, self.p2, object.p1, object.p2)
  end,

  should_subdivide_for = function(self, object)
    return (
      (object.p1.x <= self.mx and object.p2.x <= self.mx) or
      (object.p1.x >= self.mx and object.p2.x >= self.mx) or
      (object.p1.y <= self.my and object.p2.y <= self.my) or
      (object.p1.y >= self.my and object.p2.y >= self.my)
    ) and (self.width > self.min_size)
  end,

  subdivide = function(self)
    if self.children then
      for i,child in pairs(self.children) do
        child:subdivide()
      end
    else
      local x1 = self.p1.x
      local y1 = self.p1.y
      local x2 = self.p2.x
      local y2 = self.p2.y
      local w = math.floor(self.width / 2)
      local h = math.floor(self.height / 2)
      self.children = {
        QuadTree:create(min_size, geom.B(x1, y1, x1+w, y1+h)), 
        QuadTree:create(min_size, geom.B(x1+w, y1, x2, y1+h)), 
        QuadTree:create(min_size, geom.B(x1, y1+h, x1+w, y2)), 
        QuadTree:create(min_size, geom.B(x1+w, y1+h, x2, y2))
      }
    end
  end,

  -- TODO: Should probably scrap everything from here down

  insert = function(self, object)
    if self:overlaps(object) then
      if not self.children and self:should_subdivide_for(object) then
        self:subdivide()
      end
      self:check(object, function(quad, x) table.insert(quad.objects, object) end)
    end
  end,

  check = function(self, object, func)
    -- First check that we overlap at all 
    if self:overlaps(object) then
      -- If so, send any objects at this level
      for i,x in pairs(self.objects) do func(self, x) end

      if self.children then
        -- Check children for overlaps recursively
        for i,child in pairs(self.children) do
          child:check(object, func)
        end
      end
    end
  end,

  remove = function(self, object)
    if not self.children then
      self.objects[object] = nil
    else
      self:check(object, function(quad, x) if object == x then quad:remove(x) end end)
    end
  end,

  collisions = function(self, object)
    local matches = {}
    self:check(object, function(quad, x) table.insert(matches, x) end)
    return matches
  end,
}
