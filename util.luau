------------------------------------------------------------
-- spoofer v1.2
-- Copyright © 2023-2025 Studio Phantym (@saaawdust)
--
-- This software is provided ‘as-is’, without any express or implied warranty.
-- In no event will the authors be held liable for any damages arising from the use of this software.
--
-- Permission is granted to anyone to use this software for any purpose,
-- including commercial applications, and to alter it and redistribute it freely,
-- subject to the following restrictions:
--
-- 1. The origin of this software must not be misrepresented;
--    you must not claim that you wrote the original software.
--    If you use this software in a product, an acknowledgment
--    in the product documentation would be appreciated but is not required.
--
-- 2. Altered source versions must be plainly marked as such,
--    and must not be misrepresented as being the original software.
--
-- 3. This notice may not be removed or altered from any source distribution.
--
------------------------------------------------------------

local Players = game:GetService("Players")
local UserService = game:GetService("UserService")
local Chat = game:GetService("Chat")
local TextChatService = game:GetService("TextChatService")

local spoofer = script.Parent
local t = require(spoofer.types)
local pub = require(spoofer.public)

local util = {}
util.displays = {}

function util.getUserInfoWithRetry(userId: number, playerFallback: Player)
	local success, result
	local tries = 0

	repeat
		success, result = pcall(function()
			return UserService:GetUserInfosByUserIdsAsync({userId})
		end)

		if not success then
			task.wait() 
		end

		tries += 1
	until success or tries == 50

	if success then
		return result
	end

	if tries == 50 then
		warn("[rbx-err]: Failed to load avatar!")
	end

	return { { Id = playerFallback.UserId, DisplayName = playerFallback.DisplayName, Username = playerFallback.Name } }
end

local function applyChanges(character: Model, userInfo: { DisplayName: string, Username: string, Id: number })
	local newDescription = Players:GetHumanoidDescriptionFromUserId(userInfo.Id)
	local humanoid = character:WaitForChild("Humanoid") :: Humanoid

	humanoid:ApplyDescription(newDescription)
	humanoid.DisplayName = userInfo.DisplayName

	return
end

local function characterAddedWrapper(Plr: Player, userInfo: { DisplayName: string, Username: string, Id: number }, fn: ((...any?) -> any?)?)
	if fn then -- "connect"
		local c
		c = Plr.CharacterAdded:Connect(function(character: Model) 
			applyChanges(character, userInfo)
			fn(character)
		end)

		return c
	else
		local char = Plr.CharacterAdded:Wait()
		applyChanges(char, userInfo)

		return char
	end
end

function util.makeUser(original: Player, newUserId: number, isFake: boolean?): t.SPlayer
	isFake = isFake or false
	
	local userInfo = util.getUserInfoWithRetry(newUserId, original)[1] :: { DisplayName: string, Username: string, Id: number, HasVerifiedBadge: boolean }
	local characterAdded = {}

	function characterAdded:Connect(fn)
		return characterAddedWrapper(original, userInfo, fn)
	end

	function characterAdded:Wait()
		return characterAddedWrapper(original, userInfo)
	end
	
	local function getCharacter()
		return original.Character
	end
	
	local function get(self, input)
		return original[input]
	end
	
	local function set(self, input, value)
		original[input] = value
		return
	end
	
	local function call(self, name, ...)
		return original[name](original, ...)
	end
	
	local function getInstance(self)
		return original
	end
	
	local cv
	coroutine.wrap(function(...) 
		applyChanges(original.Character or original.CharacterAdded:Wait(), userInfo)
		cv = characterAddedWrapper(original, userInfo)
	end)()

	return {
		CharacterEvent = cv,
		
		Name = userInfo.Username,
		DisplayName = userInfo.DisplayName,
		UserId = newUserId,
		Backpack = original.Backpack,
		PlayerGui = original.PlayerGui,
		
		GetCharacter = getCharacter,
		GetProperty = get :: any,
		SetProperty = set :: any,
		CallMethod = call :: any,
		GetInstance = getInstance :: any,
		
		HasVerifiedBadge = userInfo.HasVerifiedBadge,

		isFake = isFake,
		
		CharacterAdded = characterAdded,
		CharacterRemoving = original.CharacterRemoving
	}
end

function util.getOrMakeUser(player: Player): t.SPlayer
	local posPlr = pub[player.UserId] :: t.SPlayer
	if not posPlr then
		posPlr = util.makeUser(player, player.UserId)
		
		local alreadyExists = pub[player.UserId]
		if alreadyExists and alreadyExists.CharacterEvent then
			alreadyExists.CharacterEvent:Disconnect()
		end
		
		pub[player.UserId] = posPlr
	end

	return posPlr
end

Players.PlayerAdded:Connect(function(player: Player) 
	util.displays[player.DisplayName] = player

	player.CharacterAdded:Connect(function() 
		local new = script.Parent.pretend.SpooferChat:Clone()
		new.Parent = player.PlayerGui	
	end)
end);

return util