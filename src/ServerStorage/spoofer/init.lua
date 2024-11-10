------------------------------------------------------------
-- spoofer v1.0
-- Copyright © 2023-2024 Studio Phantym (@saaawdust)
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
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local pub = require(script.public)
local GetColor = require(script.GetColor)
local util = require(script.util)
local players = require(script.players)
local pretend = require(script.pretend)
local fnStore = require(script.fnStore)

local displays = {}

local spooferRemote = ReplicatedStorage:FindFirstChild("SpooferReplicated")
local spooferChatRemote = ReplicatedStorage:FindFirstChild("SpooferChat")
local spooferClient = ReplicatedStorage:FindFirstChild("SpooferClient")

if not spooferRemote then
	spooferRemote = Instance.new("RemoteEvent")
	spooferRemote.Parent = ReplicatedStorage
	spooferRemote.Name = "SpooferReplicated"
end

local pretendInstance = pretend(spooferRemote)

if not spooferClient then
	spooferClient = Instance.new("RemoteEvent")
	spooferClient.Parent = ReplicatedStorage
	spooferClient.Name = "SpooferClient"

	local function sanitize(player: Player)
		local new = util.getOrMakeUser(player)
		return {
			Name = new.Name,
			DisplayName = new.DisplayName,
			UserId = new.UserId,
			PlayerGui = new.PlayerGui,
			Backpack = new.Backpack,

			isFake = new.isFake
		}
	end

	local commands = {
		getSpoofId = function(plr: Player, ...)
			return pub[plr.UserId] and pub[plr.UserId].UserId or plr.UserId
		end,

		getLocalPlayer = function(plr: Player, ...)
			return sanitize(plr)
		end,

		isIndexed = function(plr: Player)
			return pub[plr.UserId] ~= nil
		end,

		isSpoofing = function(plr: Player)
			local posPlr = pub[plr.UserId]
			if not posPlr then
				return
			end

			return posPlr.isFake
		end,

		RequestSpoof = function(plr: Player, userId)
			local onRequested = fnStore.onRequested
			if not onRequested or typeof(onRequested) ~= "function" then
				return false
			end

			local result = onRequested(plr, userId)

			if result then
				pretendInstance.being(userId).as(plr)
			end

			return result ~= false
		end
	}

	spooferClient.OnServerEvent:Connect(function(plr: Player, command: string, ...)
		spooferClient:FireClient(plr, commands[command](plr, ...))
	end)
end

if not spooferChatRemote then
	spooferChatRemote = Instance.new("RemoteEvent")
	spooferChatRemote.Parent = ReplicatedStorage
	spooferChatRemote.Name = "SpooferChat"

	Players.PlayerAdded:Connect(function(player: Player) 
		displays[player.DisplayName] = player

		player.CharacterAdded:Connect(function(character: Model) 
			local new = script.pretend.SpooferChat:Clone()
			new.Parent = player.PlayerGui	
		end)
	end);

	(spooferChatRemote :: RemoteEvent).OnServerEvent:Connect(function(player: Player, msg: string) 
		local displayName = string.split(msg, ":")[1];
		local plr = displays[displayName]
		local userId = plr.UserId
		local fakePlr = pub[userId]

		if userId and fakePlr then
			local col = GetColor(Players:GetNameFromUserIdAsync(fakePlr.UserId));
			(spooferChatRemote :: RemoteEvent):FireClient(player, `<font color = \"rgb({math.floor(col.R*255)}, {math.floor(col.G*255)}, {math.floor(col.B*255)})\">{util.getUserInfoWithRetry(fakePlr.UserId, plr)[1].DisplayName}:</font>`)
		end

		return msg
	end)
end

return {
	pretend = pretendInstance,
	remotes = require(script.remotes),
	types = require(script.types),
	players = players,
	events = fnStore
}