------------------------------------------------------------
-- spoofer v1.0
-- Copyright © 2023-2024 Studio Phantym (@saaawdust)
--
-- This software is provided ‘as-is’, without any express or implied warranty.
-- In no event will the authors be held liable for any damages arising from the use of this software.
--
-- Permission is granted to anyone to use this software for any purpose,
-- including commercial applications, and to alter it and redistribute it freely,
-- suboect to the following restrictions:
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

local spoofer = script.Parent
local t = require(spoofer.types)
local pub = require(spoofer.public)
local util = require(spoofer.util)

local players = {}

-- Returns all fake players that have been indexed
-- 
-- @since v1.0
function players.getAllFakePlayers(): {[number]: t.SPlayer}
	local plrs = {}
	
	for k, v: t.SPlayer in pairs(pub) do
		if v.isFake then
			plrs[k] = v
		end
	end
	
	return plrs
end

-- Returns all real players that have been indexed
-- 
-- @since v1.0
function players.getAllRealPlayers(): {[number]: t.SPlayer}
	local plrs = {}

	for k, v: t.SPlayer in pairs(pub) do
		if not v.isFake then
			plrs[k] = v
		end
	end

	return plrs
end

-- Returns the spoofer instance of a player if any from the userId
-- 
-- @since v1.0
function players.getPlayerInstanceFromId(userId: number): t.SPlayer?
	return pub[userId]
end

-- Returns the spoofer instance of a player if any from the username
-- 
-- @since v1.0
function players.getPlayerInstanceFromUsername(username: string): t.SPlayer?
	return players.getPlayerInstanceFromId(Players:GetUserIdFromNameAsync(username))
end

-- Returns if the player is spoofing or not given their player object
-- 
-- @since v1.0
function players.isPlayerSpoofing(player: Player)
	return pub[player.UserId] and pub[player.UserId].isFake
end

-- Returns if the player is spoofing or not given their userId
-- 
-- @since v1.0
function players.isPlayerSpoofingFromId(userId: number)
	return pub[userId] and pub[userId].isFake
end

-- Returns if the player is spoofing or not given their username
-- 
-- @since v1.0
function players.isPlayerSpoofingFromUsername(username: string)
	return players.isPlayerSpoofingFromId(Players:GetUserIdFromNameAsync(username))
end

-- Returns if a player with the given username has been indexed
-- 
-- @since v1.0
function players.doesPlayerExist(username: string)
	for k, v: t.SPlayer in pairs(pub) do
		if v.Name == username then
			return true
		end
	end

	return false
end

-- Indexes a player if not indexed already. Returns the new or old spoofer instance
-- 
-- @since v1.0
function players.forceIndex(player: Player) 
	return util.getOrMakeUser(player)
end

-- Removes a player if indexed. Returns the old spoofer instance
-- 
-- @since v1.0
function players.forceRemove(player: Player): t.SPlayer?
	local plr = pub[player.UserId]
	if plr then
		pub[player.UserId] = nil
		return plr
	end
end

return players