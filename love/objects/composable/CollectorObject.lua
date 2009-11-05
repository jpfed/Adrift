love.filesystem.require("oo.lua")

CollectorObject = {
  attribute = function(self)
    local result = {attributes = {}}
    result.attributes[CollectorObject] = true
    result.inventory = {}
    mixin(result,CollectorObject)
    return result
  end,
    
  inventoryAdd = function(self, thing)
    self.inventory[thing] = thing
    L:removeObject(thing)
  end,

  inventoryDrop = function(self, thing)
    self.inventory[thing] = nil
    -- Not sure how to move the stored object to the right coords
    -- Or, for that matter, how to stop the dropper from immediately picking 
    -- it back up
    thing.spawnAt(self)
    L:addObject(thing)
  end,

  inventoryDropAll = function(self)
    for k,v in ipairs(self.inventory) do
      self:inventoryDrop(v)
    end
  end

}
