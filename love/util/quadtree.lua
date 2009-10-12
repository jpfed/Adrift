love.filesystem.require("oo.lua")
love.filesystem.require("util/geom.lua")

-- I'm going to attempt a standard quadtree for rectangle storage and 
-- retrieval. I want collision retrieval to be blazing fast, and fast
-- insertion is secondary for now.
--
-- It will contain arbitrary objects as long as they have a bounding box...
-- my arbitrary convention is "p1" for upper left point and "p2" for lower right point
--
-- Initial starting point stolen from http://github.com/samuel/lua-quadtree/blob/master/quadtree.lua

QuadTree = {
  create = function(self, min_size, p1, p2)
    local result = {}
    mixin(result,QuadTree)
    result.min_size = min_size
    result.p1 = p1
    result.p2 = p2
    result.width  = p2.x - p1.x
    result.height = p2.y - p1.y
    result.objects = {}
    return result
  end,

  insert = function(self, object)
    -- wrong check here
    -- instead, check if object fits better in a subquad of this and create it/subdivide as necessary, if not already <= min_size
    if not self.children then
      table.insert(self.objects, object)
    else
      self:check(object, function(child) child:insert(object) end)
    end
  end,

  subdivide = function(self)
    if self.children then
      for i,child in pairs(self.children) do
        child:subdivide()
      end
    else
      local x1 = self.p1.x
      local y1 = self.p1.y
      local w = math.floor(self.width / 2)
      local h = math.floor(self.height / 2)
      self.children = {
        QuadTree:create(min_size, {x=p1.x, y=p1.y}, {x=p1.x+w, y=p1.y+h}), 
        QuadTree:create(min_size, {x=p1.x+w, y=p1.y}, {x=p2.x, y=p1.y+h}), 
        QuadTree:create(min_size, {x=p1.x, y=p1.y+h}, {x=p1.x+w, y=p2.y}), 
        QuadTree:create(min_size, {x=p1.x+w, y=p1.y+h}, {x=p2.x, y=p2.y}), 
      }
    end
  end,

  check = function(self, object, func)
    for i,child in pairs(self.children) do
      if geom.box_overlap_t(self.p1, self.p2, object.p1, object.p2) then
        func(child)
      end
    end
  end,

  remove = function(self, object)
    if not self.children then
        self.objects[object] = nil
    else
        self:check(object, function(child) child:remove(object) end)
    end
  end,

  collisions = function(self, object)
    if not self.children then
      return self.objects
    else
      local matches = {}
      self:check(object, function(child) matches[child] = child end)
      return matches
    end
  end,
}
