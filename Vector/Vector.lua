local module = {}
module.__index = module

--local function __swap(heap, pos, a, b)
--	heap[a], heap[b] = heap[b], heap[a]
--	pos[heap[a]] = a
--	pos[heap[b]] = b
--end

--local function __parent(index)
--	return math.floor((index - 1) / 2)
--end

--local function __leftNode(index)
--	return 2 * index + 1
--end

--local function __rightNode(index)
--	return 2 * index + 2
--end

--local function __less(a, b)
--	return a > b
--end

--local function __lessSame(a, b)
--	return a >= b
--end

--local function __hasLeftNode(index, size)
--	return __leftNode(index) < size
--end

--local function __hasRightNode(index, size)
--	return __rightNode(index) < size
--end

--local function __bubble_up(heap, pos, index)	
--	while index > 1 and __less(heap[__parent(index)], heap[index]) do
--		__swap(heap, pos, heap[index], heap[__parent(index)])
--		index = __parent(index)
--	end
--end

--local function __bubble_down(heap, pos, index)
--	local size = #heap
	
--	while __hasLeftNode(index, heap) do
--		local smallerChild = __leftNode(index)
		
--		if __hasRightNode(index, size) and __less(heap[smallerChild], heap[__rightNode(index)]) then
--			smallerChild = __rightNode(index)
--		end
		
--		if __lessSame(heap[smallerChild], heap[index]) then
--			break
--		end
		
--		__swap(heap, pos, heap[index], heap[smallerChild])
--		index = smallerChild
--	end
--end

function module.new(array)
	local self = setmetatable({}, module)
	self.___items = {}
	self.___index = {}
	self.___max = nil
	self.___min = nil
	self.___length = 0
	
	if array and #array > 0 then
		for i in pairs(array) do
			self:PushBack(array[i])
		end
	end
	
	return self
end

function module:PushBack(data)
	if self.___index[data] then return false end
	
	self.___length += 1
	self.___index[data] = self.___length
	self.___items[self.___length] = data
	
	if self.___max == nil or data > self.___max then
		self.___max = data
	end
	
	if self.___min == nil or self.___min > data then
		self.___min = data
	end
	
	return true
end

function module:Remove(index)
	if not self.___items[index] then return false end
	
	local removedElement = self.___items[index]
	
	for i = index, self.___length - 1 do
		local advance = self.___items[i + 1]
		
		self.___items[i] = advance
		self.___index[advance] = i
	end
	
	self.___items[self.___length] = nil
	self.___index[removedElement] = nil
	self.___length -= 1
	
	if removedElement == self.___max or removedElement == self.___min then
		self.___max = nil
		self.___min = nil
		
		for i in pairs(self.___items) do
			if self.___max == nil or self.___items[i] > self.___max then
				self.___max = self.___items[i]
			end
			
			if self.___min == nil or self.___min > self.___items[i] then
				self.___min = self.___items[i]
			end
		end
	end
	
	return true
end

function module:Pop()
	if self.___length == 0 then return nil end
	
	local list = self.___items[1]
	self:Remove(1)
	
	return list
end

function module:PopBack()
	if self.___length == 0 then return nil end
	
	local list = self.___items[self.___length]
	self:Remove(self.___length)
	
	return list
end

function module:Length()
	return self.___length
end

function module:Erase()
	self.___items = {}
	self.___index = {}
	self.___length = 0
	self.___max = nil
	self.___min = nil
end

function module:Contains(data)
	return self.___index[data] ~= nil
end

function module:At(index)
	return self.___items[index]
end

function module:Find(data)
	return self.___index[data]
end

function module:ToArray()
	local arr = {}
	
	for _, v in pairs(self.___items) do
		table.insert(arr, v)
	end
	
	return arr
end

function module:ToSet()
	local set = {}
	
	for _, v in pairs(self.___items) do
		set[v] = true
	end
	
	return set
end

function module:MaxValue()
	return self.___max
end

function module:MinValue()
	return self.___min
end

function module:Begin()
	return self.___items[1]
end

function module:Last()
	return self.___items[self.___length]
end

function module:IsEmpty()
	return self.___length == 0
end

function module:Reverse()
	local left = 1
	local right = self.___length
	
	while left < right do
		self.___items[left], self.___items[right] = self.___items[right], self.___items[left]
		
		self.___index[self.___items[left]] = left
		self.___index[self.___items[right]] = right
		
		left += 1
		right -= 1
	end
end

function module:EraseWhen(predicate)
	if typeof(predicate) ~= "function" then return end
	
	coroutine.wrap(function()
		while not predicate() do
			task.wait()
		end
		
		self:Erase()
	end)()
end

function module:Swap(index_a, index_b)
	if not self.___items[index_a] or not self.___items[index_b] then return false end
	
	local a = self.___items[index_a]
	local b = self.___items[index_b]
	
	self.___items[index_a], self.___items[index_b] = b, a
	
	self.___index[a] = index_b
	self.___index[b] = index_a
	
	return true
end

local function __introsortion(arr, left, right)
	for i = left + 1, right do
		local key = arr[i]
		local j = i - 1

		while j >= left and arr[j] > key do
			arr[j + 1] = arr[j]
			j -= 1
		end

		arr[j + 1] = key
	end
end

local function __med_of_three(arr, a, b, c)
	if (arr[a] < arr[b] and arr[b] < arr[c]) or (arr[c] <= arr[b] and arr[b] <= arr[a]) then 
		return b
	end

	if (arr[b] < arr[a] and arr[a] < arr[c]) or (arr[c] <= arr[a] and arr[a] <= arr[b]) then
		return a
	end

	return c
end

local function __partition(self, arr, low, high)	
	local pivot = arr[high]
	local i = low - 1

	for j = low, high - 1 do
		if arr[j] <= pivot then 
			i += 1
			self:Swap(i, j)
		end
	end
	self:Swap(i + 1, high)
	return i + 1
end

local function __introsort(self, arr, left, right, dl)
	local size = right - left + 1
	if size < 16 then
		__introsortion(arr, left, right)
		return
	end
	
	if dl == 0 then
		table.sort(arr, left, right)
	end
	
	local pivotMt = __med_of_three(arr, left, left + math.floor(size / 2), right)
	self:Swap(pivotMt, right)
	
	local part = __partition(self, arr, left, right)
	
	__introsort(self, arr, left, part - 1, dl - 1)
	__introsort(self, arr, part + 1, right, dl - 1)
end

function module:Sort(rebuildIndex, begin, last)
	rebuildIndex = rebuildIndex or false
	begin = begin or 1
	last = last or self:Length()
	
	if self.___length > 1 then
		__introsort(self, self.___items, begin, last, math.floor(2 * math.log(self.___length, 2)))
	end
	
	if rebuildIndex then
		for i = 1, self.___length do
			self.___index[self.___items[i]] = i
		end
	end
end

return module
