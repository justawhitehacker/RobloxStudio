local SDictionary = {}
SDictionary.__index = SDictionary

--[[
Example:

	local Dictionary = SDictionary.new("string", "string")
	Dictionary:Add("Key", "Value")
	
	print(Dictionary:Get("Key")) -- Prints "Value"
	
	You can follow this method for a complex and advanced example:
	
	local Players = game:GetService("Players")
	local MAX_PLAYERS = 20
	local UP_INTERVAL = 25
	
	local timestamp = SDictionary.new("number", "table")
	
	Players.PlayerAdded:Connect(function(Player)
		local id = Player.UserId
		
		timestamp:Add(id, {
			["JoinedTime"] = tick(),
			["LifeTime"] = tick()
			["LeftTime"] = 0,
			["Name"] = Player.Name
		})
		
		task.spawn(function()
			while Player do
				timestamp:At(id).LifeTime = tick()
				task.wait(1)
			end
		end)
	end)
	
	Players.PlayerRemoving:Connect(function(Player)
		timestamp:At(id).LeftTime = tick()
	end)
	
	task.spawn(function()
		while true do
			timestamp:RemoveIf(function(key, value)
				return timestamp:Length() > MAX_PLAYERS and value.LeftTime > 0
			end)
			
			task.wait(UP_INTERVAL)
		end
	end)
--]]

export type SDictionaryInsertion = boolean | (() -> ())

export type TKey = any
export type TValue = any
export type SArray = {[TKey] : TValue}

export type SDictionary = 
{
	Add: (self: SDictionary, Key: TKey, Value: TValue) -> SDictionaryInsertion,
	Set: (self: SDictionary, Key: TKey, Value: TValue) -> SDictionaryInsertion,
	Remove: (self: SDictionary, Key: TKey) -> SDictionaryInsertion,
	
	Get: (self: SDictionary, Key: TKey) -> TValue,
	GetKey: (self: SDictionary, Value: TValue) -> TKey,
	
	Find: (self: SDictionary, Value: TValue) -> boolean,
	
	Clear: (self: SDictionary) -> (),
	
	ContainsKey: (self: SDictionary, Key: TKey) -> boolean,
	ContainsValue: (self: SDictionary, Value: TValue, DuplicateCounts: number?) -> boolean,
	
	Keys: (self: SDictionary) -> { TKey },
	Values: (self: SDictionary) -> { TValue },
	
	Iterator: (self: SDictionary) -> { [TKey]: TValue },
	
	Length: (self: SDictionary) -> number,
	
	IsEmpty: (self: SDictionary) -> boolean,
	
	At: (self: SDictionary, Key: TKey) -> TValue,
	
	RemoveIf: (self: SDictionary) -> (Key: TKey, Value: TValue) -> number,
	
	Swap: (self: SDictionary, Key1: TKey, Key2: TKey) -> SDictionaryInsertion,
	
	Copy: (self: SDictionary) -> SDictionary,
	
	Paste: (self: SDictionary, Dictionary: SDictionary) -> (),
	
	__iter: (self: SDictionary) -> { [TKey]: TValue }
}

export type SDictionaryInit =
{
	new: (TKey: TKey, TValue: TValue, Array: SArray?) -> SDictionary,		
}

function SDictionary.new(TKey : TKey, TValue : TValue, array : SArray) : SDictionary
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
	
	return self :: SDictionary
end

function SDictionary:Add(key : TKey, value : TValue)
	assert(typeof(key) == self.___keyType, "Key must be a " .. self.___keyType)
	assert(typeof(value) == self.___valueType, "Value must be a " .. self.___valueType)
	
	if self.___items[key] ~= nil then return false end
	
	self.___items[key] = value
	self.___length += 1
	
	return true :: SDictionaryInsertion
end

function SDictionary:Set(key, value)
	assert(typeof(key) == self.___keyType, "Key must be a " .. self.___keyType)
	assert(typeof(value) == self.___valueType, "Value must be a " .. self.___valueType)
	
	if self.___items[key] == nil then
		self.___length += 1
	end
	
	self.___items[key] = value
	
	return true :: SDictionaryInsertion
end

function SDictionary:Remove(key)
	assert(typeof(key) == self.___keyType, "Key must be a " .. self.___keyType)
	
	if self.___items[key] == nil then return false end
	
	self.___items[key] = nil
	self.___length -= 1
	
	return true :: SDictionaryInsertion
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
	local markedKeys = {}
	
	for key, value in pairs(self.___items) do
		if predicate(key, value) then
			table.insert(markedKeys, key)
			removed += 1
		end
	end
	
	for i = 1, #markedKeys do
		local key = markedKeys[i]
		self.___items[key] = nil
	end
	
	self.___length -= removed
	
	table.clear(markedKeys)
	markedKeys = nil
	
	return removed
end

function SDictionary:Swap(key1, key2)
	assert(typeof(key1) == self.___keyType, "Key1 must be a " .. self.___keyType)
	assert(typeof(key2) == self.___keyType, "Key2 must be a " .. self.___keyType)
	
	self.___items[key1], self.___items[key2] = self.___items[key2], self.___items[key1]
	
	return true :: SDictionaryInsertion
end

function SDictionary:Copy(): SDictionary
	local copy = SDictionary.new(self.___keyType, self.___valueType, self.___items)
	
	return copy :: SDictionary
end

function SDictionary:Paste(sdictionary: SDictionary)
	assert(typeof(sdictionary) == "table", "sdictionary must be a SDictionary")
	
	sdictionary = SDictionary.new(self.___keyType, self.___valueType, self.___items)
end

SDictionary.__iter = function(self)
	return self:Iterator()
end

return SDictionary :: SDictionaryInit
