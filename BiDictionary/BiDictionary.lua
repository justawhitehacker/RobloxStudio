local SBiDictionary = {}
SBiDictionary.__index = SBiDictionary

function SBiDictionary.new(TKey, TValue, array)
	local self = setmetatable({}, SBiDictionary)
	self.___keyType = TKey
	self.___valueType = TValue
	self.___values = {}
	self.___keys = {}
	self.___length = 0
	
	if array then
		for key, value in pairs(array) do
			self:Add(key, value)
		end
	end
	
	return self
end

function SBiDictionary:Add(key, value)
	assert(typeof(key) == self.___keyType, "Key must be a " .. self.___keyType)
	assert(typeof(value) == self.___valueType, "Value must be a " .. self.___valueType)
	
	if self.___keys[value] ~= nil then return false end
	
	self.___length += 1
	self.___values[key] = value
	self.___keys[value] = key
	
	return true
end

function SBiDictionary:Set(key, value)
	assert(typeof(key) == self.___keyType, "Key must be a " .. self.___keyType)
	assert(typeof(value) == self.___valueType, "Value must be a " .. self.___valueType)

	if self.___keys[value] == nil then
		self.___keys[self.___values[key]] = nil
		self.___keys[value] = key
	end

	self.___values[key] = value
	
	return true
end

function SBiDictionary:Remove(key)
	assert(typeof(key) == self.___keyType, "Key must be a " .. self.___keyType)
	
	if self.___values[key] == nil then return false end
	
	self.___length -= 1
	self.___keys[self.___values[key]] = nil
	self.___values[key] = nil
	
	return true
end

function SBiDictionary:Get(key)
	return self.___values[key]
end

function SBiDictionary:GetKey(value)
	return self.___keys[value]
end

function SBiDictionary:Find(value)
	return self.___keys[value] ~= nil
end

function SBiDictionary:Keys()
	return self.___keys
end

function SBiDictionary:Values()
	return self.___values
end

function SBiDictionary:Iterator()
	return next, self.___values, nil
end

function SBiDictionary:Length()
	return self.___length
end

function SBiDictionary:Clear()
	self.___keys = {}
	self.___values = {}
	self.___length = 0
end

function SBiDictionary:ContainsKey(key)
	return self.___values[key] ~= nil
end

function SBiDictionary:IsEmpty()
	return self.___length == 0
end

function SBiDictionary:At(key)
	return self.___values[key]
end

function SBiDictionary:RemoveIf(predicate)
	assert(typeof(predicate) == "function", "Predicate must be a function")

	local removed = 0
	
	for key, value in pairs(self.___values) do
		if predicate(key, value) then
			self:Remove(key)
			removed += 1
		end
	end
	
	self.___length -= removed
	
	return removed
end

SBiDictionary.__iter = function(self)
	return self:Iterator()
end

return SBiDictionary
