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
    if not self.canPickUp or not self:canPickUp(thing) then return false end
    local inv = self.inventory
    local cls = thing.class
    if inv[cls] == nil then
      inv[cls] = 1
    else
      inv[cls] = inv[cls] + 1
    end
    return true
  end,

  inventoryDrop = function(self, thing)
    if self.inventory[thing] > 0 then 
      self.inventory[thing] = self.inventory[thing] - 1
      L:addObject(thing:create(self))
    end
  end,

  inventoryDropAll = function(self)
    for itemClass,itemCount in pairs(self.inventory) do
      for k = 1, itemCount do
          self:inventoryDrop(itemClass)
      end
    end
    self.inventory = {}
  end

}
