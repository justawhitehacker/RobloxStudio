local SDictionary = {}
SDictionary.__index = SDictionary

function SDictionary.new(TKey, TValue, array)
	local self = setmetatable({}, SDictionary)
	self.___keyType = TKey
	self.___valueType = TValue
	self.___items = {}
	self.___length = 0
	
	if array then
		for key, value in pairs(array) do
			self:Add(key, value)
		end
	end
	
	return self
end

function SDictionary:Add(key, value)
	assert(typeof(key) == self.___keyType, "Key must be a " .. self.___keyType)
	assert(typeof(value) == self.___valueType, "Value must be a " .. self.___valueType)
	
	if self.___items[key] ~= nil then return false end
	
	self.___items[key] = value
	self.___length += 1
	
	return true
end

function SDictionary:Set(key, value)
	assert(typeof(key) == self.___keyType, "Key must be a " .. self.___keyType)
	assert(typeof(value) == self.___valueType, "Value must be a " .. self.___valueType)
	
	if self.___items[key] == nil then
		self.___length += 1
	end
	
	self.___items[key] = value
	
	return true
end

function SDictionary:Remove(key)
	assert(typeof(key) == self.___keyType, "Key must be a " .. self.___keyType)
	
	if self.___items[key] == nil then return false end
	
	self.___items[key] = nil
	self.___length -= 1
	
	return true
end

function SDictionary:Get(key)
	return self.___items[key]
end

function SDictionary:GetKey(value)
	for key, v in pairs(self.___items) do
		if v == value then
			return key
		end
	end
end

function SDictionary:Find(value)
	for key, v in pairs(self.___items) do
		if v == value then
			return true
		end
	end
	
	return false
end

function SDictionary:Clear()
	self.___items = {}
	self.___length = 0
end

function SDictionary:ContainsKey(key)
	return self.___items[key] ~= nil
end

function SDictionary:ContainsValue(value, countDuplicate)
	local count = 0
	
	for _, v in pairs(self.___items) do
		if v == value then
			if countDuplicate then
				count += 1
			else
				return true
			end
		end
	end
	
	if count > 0 then
		return count
	end
	
	return false
end

function SDictionary:Keys()
	local keys = {}
	for key, _ in pairs(self.___items) do
		table.insert(keys, key)
	end
	
	return keys
end

function SDictionary:Values()
	local values = {}
	for _, value in pairs(self.___items) do
		table.insert(values, value)
	end
	
	return values
end

function SDictionary:Iterator()
	return next, self.___items, nil
end

function SDictionary:Length()
	return self.___length
end

function SDictionary:IsEmpty()
	return self.___length == 0
end

function SDictionary:At(key)
	return self.___items[key]
end

function SDictionary:RemoveIf(predicate)
	assert(typeof(predicate) == "function", "Predicate must be a function")
	
	local removed = 0
	for key, value in pairs(self.___items) do
		if predicate(key, value) then
			self:Remove(key)
			removed += 1
		end
	end
	
	return removed
end

SDictionary.__iter = function(self)
	return self:Iterator()
end

return SDictionary
