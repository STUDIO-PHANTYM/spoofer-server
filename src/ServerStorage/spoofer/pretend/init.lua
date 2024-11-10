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

local spoofer = script.Parent
local t = require(spoofer.types)
local pub = require(spoofer.public)
local util = require(spoofer.util)

return function(spooferRemote: RemoteEvent)
	local pretend = {}
	
	-- The user that will be spoofed. Takes a username or a UserId as an input
	-- 
	-- @since v1.0
	function pretend.being(userId: number | string): t.SpoofConstructor
		if type(userId) == "string" then
			userId = Players:GetUserIdFromNameAsync(userId)
		end
		
		-- The user that will be spoofing.
		-- 
		-- @since v1.0
		local function asFunc(player: Player)
			local user = util.makeUser(player, userId :: number, true)
			pub[player.UserId] = user
			
			return user
		end
		
		return {
			as = asFunc,
		}
	end
	
	function pretend.toBeSelf(player: Player): t.SPlayer
		local beforeUser: t.SPlayer = pub[player.UserId]
		if beforeUser and beforeUser.CharacterEvent then
			beforeUser.CharacterEvent:Disconnect()
		end

		local newUser = util.makeUser(player, player.UserId, false)
		pub[player.UserId] = newUser

		return newUser
	end

	return pretend
end