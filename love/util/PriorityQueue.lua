love.filesystem.require("oo.lua")


-- TODO: add an index so we can find a given item in the heap supa-fast?

Heap = {

  compareNumbers = function(a,b) return a < b end,

  create = function(self, comparator)
    local heap = {elements = {}, indices = {}, comparator = comparator}
    if comparator == nil then heap.comparator = Heap.compareNumbers end
    mixin(heap, Heap)
    return heap
  end,
  
  indexOf = function(self, element)
    return self.indices[element]
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
  
  
  
  checkTop = function(self)
    return self.elements[1]
  end,
  
  
  
  insert = function(self, element)
    local e = self.elements
    table.insert(e, element)
    local index = #(self.elements)
    self.indices[element] = index
    return self:bubbleUp(element, index)
  end,
 
  bubbleUp = function(self, element, index)
    local e = self.elements 
    local parentIndex = self:parentIndexOf(index)
    local parent = e[parentIndex]
    if parent == nil or self.comparator(parent, element) then
      return nil
    else
      e[index], e[parentIndex] = e[parentIndex], e[index]
      self.indices[element] = parentIndex
      return self:bubbleUp(element, parentIndex)
    end
  end,
 

  
  removeTop = function(self)
    local result = self.elements[1]
    
    local item = table.remove(self.elements)
    self.elements[1] = item

    self:bubbleDown(item, 1)
    return result
  end,
 
  bubbleDown = function(self, item, index)
    local e, i = self.elements, self.indices
    local swapIndex = nil
    local rightChildIndex = self:rightIndexOf(index)
    local leftChildIndex = self:leftIndexOf(index)
    
    local rightChild = self.elements[rightChildIndex]
    local leftChild = self.elements[leftChildIndex]
    
    if leftChild ~= nil and rightChild ~= nil then
      if self.comparator(leftChild, rightChild) then
        if self.comparator(leftChild, item) then swapIndex = leftChildIndex; i[leftChild] = index end
      else
        if self.comparator(rightChild, item) then swapIndex = rightChildIndex; i[rightChild] = index end
      end
    elseif leftChild == nil and rightChild ~= nil then
      if self.comparator(rightChild, item) then swapIndex = rightChildIndex; i[rightChild] = index end
    elseif leftChild ~= nil and rightChild == nil then
      if self.comparator(leftChild, item) then swapIndex = leftChildIndex; i[leftChild] = index end
    end
    
    if swapIndex == nil then
      return nil
    else
      e[index], e[swapIndex] = e[swapIndex], e[index]
      i[item] = swapIndex
      return self:bubbleDown(item, swapIndex)
    end
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

  priorityRaised = function(self, element)
    local i = self:indexOf(element)
    if i ~= nil then
      self:bubbleUp(element, i)
    end
  end,
  
  priorityLowered = function(self, element)
    local i = self:indexOf(element)
    if i ~= nil then
      self:bubbleDown(element, i)
    end
  end,
  
}