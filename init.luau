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
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local pub = require(script.public)
local virtual = require(script.virtualPlayer)
local util = require(script.util)
local players = require(script.players)
local pretend = require(script.pretend)
local fnStore = require(script.fnStore)

local spooferRemote = ReplicatedStorage:FindFirstChild("SpooferReplicated")
local spooferChatRemote = ReplicatedStorage:FindFirstChild("SpooferChat")
local spooferClient = ReplicatedStorage:FindFirstChild("SpooferClient")

if not spooferRemote then
	spooferRemote = Instance.new("RemoteEvent")
	spooferRemote.Parent = ReplicatedStorage
	spooferRemote.Name = "SpooferReplicated"
end

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

			HasVerifiedBadge = new.HasVerifiedBadge,
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
				pretend.being(userId).as(plr)
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

	(spooferChatRemote :: RemoteEvent).OnServerEvent:Connect(function(player: Player, msg: string, text: string) 
		
		local displayName = string.split(msg, ":")[1];
		local plr = util.displays[displayName]
		local userId = plr.UserId
		local fakePlr = pub[userId]
		
		local msg, text = fnStore.onPlayerChat(player, fakePlr, msg, text)
		if msg or text then
			(spooferChatRemote :: RemoteEvent):FireClient(player, msg, text)
		end
	end)
end

return {
	pretend = pretend,
	remotes = require(script.remotes),
	types = require(script.types),
	players = players,
	events = fnStore
}