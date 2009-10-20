love.filesystem.require("oo.lua")

Heap = {

  compareNumbers = function(a,b) return a < b end,

  create = function(self, comparator)
    local heap = {elements = {}, comparator = comparator}
    if comparator == nil then heap.comparator = Heap.compareNumbers end
    mixin(heap, Heap)
    return heap
  end,
  
  leftIndexOf = function(self, index)
    return 2*index
  end,
  
  rightIndexOf = function(self, index)
    return 2*index + 1 
  end,
  
  parentIndexOf = function(self, index)
    return math.floor(index/2)
  end,
  
  insert = function(self, element)
    local e = self.elements
    table.insert(e, element)
    local index = #(self.elements)
    
    local swapPerformed = true
    while swapPerformed do
      local parentIndex = self:parentIndexOf(index)
      local parent = e[parentIndex]
      if parent == nil or self.comparator(parent, element) then
        swapPerformed = false
      else
        e[index], e[parentIndex] = e[parentIndex], e[index]
        index = parentIndex
      end
    end
  end,
 
  checkTop = function(self)
    return self.elements[1]
  end,
  
  removeTop = function(self)
    local result = self.elements[1]
    
    local item = table.remove(self.elements)
    self.elements[1] = item
    
    local index, swapIndex = 1, 1
    while swapIndex ~= nil do
      swapIndex = nil
      
      local rightChildIndex = self:rightIndexOf(index)
      local leftChildIndex = self:leftIndexOf(index)
      
      local rightChild = self.elements[rightChildIndex]
      local leftChild = self.elements[leftChildIndex]
      
      if leftChild ~= nil and rightChild ~= nil then
        if self.comparator(leftChild, rightChild) then
          if self.comparator(leftChild, item) then swapIndex = leftChildIndex end
        else
          if self.comparator(rightChild, item) then swapIndex = rightChildIndex end
        end
      elseif leftChild == nil and rightChild ~= nil then
        if self.comparator(rightChild, item) then swapIndex = rightChildIndex end
      elseif leftChild ~= nil and rightChild == nil then
        if self.comparator(leftChild, item) then swapIndex = leftChildIndex end
      end
      
      if swapIndex ~= nil then
        self.elements[index], self.elements[swapIndex] = self.elements[swapIndex], self.elements[index]
        index = swapIndex
      end
    end
    return result
  end,
 
  print = function(self, index, indent)
    if index == nil then index = 1; print() end
    if indent == nil then indent = 0 end
    if self.elements[index] ~= nil then
      print(string.rep("  ", indent) .. tostring(self.elements[index].priority))
      self:print(self:leftIndexOf(index), indent + 1)
      self:print(self:rightIndexOf(index), indent + 1)
    end
  end
 
}


PriorityQueue = {

  comparePriorities = function(item1, item2) return item1.priority < item2.priority end,

  create = function(self, comparator)
    local result = Heap:create(comparator)
    if comparator == nil then result.comparator = PriorityQueue.comparePriorities end
    mixin(result, PriorityQueue)
    return result
  end,

}