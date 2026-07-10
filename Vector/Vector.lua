local module = {}
module.__index = module

function module.new(T, array)
	if typeof(T) == "table" then
		array = T
		T = nil
	end
	
	local self = setmetatable({}, module)
	self.___items = {}
	self.___index = {}
	self.___type = T
	self.___max = nil
	self.___min = nil
	self.___length = 0
	
	if array and #array > 0 then
		for i in ipairs(array) do
			self:PushBack(array[i])
		end
	end
	
	return self
end

function module:PushBack(data)
	if data == nil then return false end
	if self.___type ~= nil and typeof(data) ~= self.___type then return false end
	if self.___index[data] then return false end
	
	self.___length += 1
	self.___index[data] = self.___length
	self.___items[self.___length] = data
	
	if self.___type == "number" then
		if self.___max == nil or data > self.___max then
			self.___max = data
		end

		if self.___min == nil or self.___min > data then
			self.___min = data
		end
	end
	
	return true
end

function module:Remove(index)
	assert(typeof(index) == "number", "Index must be a number")
	
	index = math.floor(index)
	
	if self.___items[index] == nil then return false end
	
	local removedElement = self.___items[index]
	
	for i = index, self.___length - 1 do
		local advance = self.___items[i + 1]
		
		self.___items[i] = advance
		self.___index[advance] = i
	end
	
	self.___items[self.___length] = nil
	self.___index[removedElement] = nil
	self.___length -= 1
	
	if (removedElement == self.___max or removedElement == self.___min) and self.___type == "number" then
		self.___max = nil
		self.___min = nil
		
		for i in ipairs(self.___items) do
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

function module:UnorderedRemove(index)
	assert(typeof(index) == "number", "Index must be a number")
	
	index = math.floor(index)
	
	if index < 1 or index > self.___length then return false end
	
	if self.___items[index] == nil then return false end
	
	local removedElement = self.___items[index]
	local lastElement = self.___items[self.___length]
	
	self.___items[index] = lastElement
	self.___items[self.___length] = nil
	
	self.___index[lastElement] = index
	self.___index[removedElement] = nil
	
	self.___length -= 1
	
	if (removedElement == self.___max or removedElement == self.___min) and self.___type == "number" then
		self.___max = nil
		self.___min = nil
		
		for i in ipairs(self.___items) do
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

function module:RemoveRange(index_left, index_right)
	assert(typeof(index_left) == "number" and typeof(index_right) == "number", "Index left is not a number")
	
	index_left = math.floor(index_left)
	index_right = math.floor(index_right)
	
	if index_left > index_right then return false end
	if index_left < 1 or index_right > self.___length then return false end
	if index_left == index_right then return self:Remove(index_left) end
	
	if self.___items[index_left] == nil or self.___items[index_right] == nil then return false end
	
	local oldLength = self.___length
	local length = index_right - index_left + 1
	local reconstructMinMax = false
	
	for i = index_left, index_right do
		local advance = self.___items[i]
		self.___index[advance] = nil
		
		if self.___max == advance or self.___min == advance then
			reconstructMinMax = true
		end
	end
	
	for i = index_right + 1, oldLength do
		self.___items[i - length] = self.___items[i]
		self.___index[self.___items[i]] = i - length
		self.___length -= 1
	end
	
	for i = oldLength - length + 1, oldLength do
		self.___items[i] = nil
	end
	
	self.___length = oldLength - length
	
	if reconstructMinMax and self.___type == "number" then
		self.___max = nil
		self.___min = nil
		
		for i in ipairs(self.___items) do
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

function module:Insert(index, data)
	assert(typeof(index) == "number", "Index is not a number")
	
	index = math.floor(index)
	
	if data == nil then return false end
	if self.___type ~= nil and typeof(data) ~= self.___type then return false end
	if self.___index[data] then return false end
	if index < 1 or index > self.___length + 1 then return false end
	
	for i = self.___length, index, -1 do
		local advance = self.___items[i]

		self.___items[i + 1] = advance
		self.___index[advance] = i + 1
	end
	
	self.___items[index] = data
	self.___index[self.___items[index]] = index
	self.___length += 1
	
	if self.___type == "number" then
		if self.___max == nil or data > self.___max then
			self.___max = data
		end

		if self.___min == nil or self.___min > data then
			self.___min = data
		end
	end
	
	return true
end

function module:BinarySearch(data, index_left, index_right)
	assert(typeof(index_left) == "number" and typeof(index_right) == "number", "One of the indexes (maybe both) is/are not a number")
	if self.___type ~= nil and typeof(data) ~= self.___type then return nil end
	if self.___length == 0 then return nil end
	
	if index_left < 1 or index_right > self.___length then return nil end
	
	index_left = math.floor(index_left or 1)
	index_right = math.floor(index_right or self.___length)
	
	if index_left > index_right then return nil end
	
	while index_left <= index_right do
		local mid = math.floor(index_left + (index_right - index_left) / 2)
		local midItem = self.___items[mid]

		if midItem == data then
			return mid
		elseif midItem < data then
			index_left = mid + 1
		else
			index_right = mid - 1
		end
	end
	
	return nil
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

function module:Clear()
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
	if index < 1 or index > self.___length then return nil end
	return self.___items[index]
end

function module:Find(data)
	return self.___index[data]
end

function module:ToArray()
	local arr = {}
	
	for _, v in ipairs(self.___items) do
		table.insert(arr, v)
	end
	
	return arr
end

function module:ToSet()
	local set = {}
	
	for _, v in ipairs(self.___items) do
		set[v] = true
	end
	
	return set
end

function module:Slice(index_left, index_right)
	assert(typeof(index_left) == "number" and typeof(index_right) == "number", "Index left is not a number")

	index_left = math.floor(index_left)
	index_right = math.floor(index_right)

	if index_left > index_right then return nil end
	if index_left < 1 or index_right > self.___length then return nil end
	if index_left == index_right then return { self.___items[index_left] } end

	if self.___items[index_left] == nil or self.___items[index_right] == nil then return nil end
	
	local arr = {}
	for i = index_left, index_right do
		local advance = self.___items[i]
		table.insert(arr, advance)
	end
	
	return arr
end

function module:Copy()
	local vec = module.new(self.___type, self.___items)
	
	return vec
end

function module:MaxValue()
	if self.___type ~= nil and self.___type ~= "number" then return nil end
	return self.___max
end

function module:MinValue()
	if self.___type ~= nil and self.___type ~= "number" then return nil end
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

function module:ClearIf(predicate)
	if typeof(predicate) ~= "function" then return end
	
	coroutine.wrap(function()
		while not predicate() do
			task.wait()
		end
		
		self:Clear()
	end)()
end

function module:RemoveIf(predicate)
	assert(typeof(predicate) == "function", "predicate must be a function")
	
	local copy = 1
	local removed = 0
	local changedMinMax = false
	
	for i = 1, self.___length do
		local advance = self.___items[i]
		
		if predicate(advance, i) then
			self.___index[advance] = nil
			removed += 1
			
			if self.___max == advance or self.___min == advance then
				changedMinMax = true
			end
			
		else
			self.___items[copy] = advance
			self.___index[advance] = copy
			copy += 1
		end
	end
	
	for i = copy, self.___length do
		self.___items[i] = nil
	end
	
	self.___length = copy - 1
	
	if changedMinMax and self.___type == "number" then
		self.___max = nil
		self.___min = nil
		
		for i = 1, self.___length do
			if self.___max == nil or self.___items[i] > self.___max then
				self.___max = self.___items[i]
			end
			
			if self.___min == nil or self.___items[i] < self.___min then
				self.___min = self.___items[i]
			end
		end
	end
	
	return removed
end

function module:Swap(index_a, index_b)
	if self.___items[index_a] == nil or self.___items[index_b] == nil then return false end
	
	local a = self.___items[index_a]
	local b = self.___items[index_b]
	
	self.___items[index_a], self.___items[index_b] = b, a
	
	self.___index[a] = index_b
	self.___index[b] = index_a
	
	return true
end

local function __heapify(self, from, size, index)
	local idx = index
	
	local relativeRoot = index - from
	local left = from + (2 * relativeRoot + 1)
	local right = from + (2 * relativeRoot + 2)
	
	local heapEnd = from + size - 1
	
	if left < heapEnd and self.___items[left] > self.___items[idx] then
		idx = left
	end
	
	if right < heapEnd and self.___items[right] > self.___items[idx] then
		idx = right
	end
	
	if index ~= idx then
		self:Swap(index, idx)
		__heapify(self, from, size, idx)
	end
end

local function __heapsort(self, from, to)
	if from >= to then return end
	
	local range = to - from + 1
	
	for i = math.floor(range / 2) - 1, 0, -1 do
		__heapify(self, from, range, from + i)
	end
	
	for i = range - 1, 1, -1 do
		self:Swap(from, from + 1)
		
		__heapify(self, from, i, from)
	end
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
		__heapsort(arr, left, right)
		return
	end
	
	local pivotMt = __med_of_three(arr, left, left + math.floor(size / 2), right)
	self:Swap(pivotMt, right)
	
	local part = __partition(self, arr, left, right)
	
	__introsort(self, arr, left, part - 1, dl - 1)
	__introsort(self, arr, part + 1, right, dl - 1)
end

function module:Sort(begin, last, rebuildIndex)
	if self.___type ~= "number" then return end
	if begin < 1 or last > self.___length then return end
	
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
