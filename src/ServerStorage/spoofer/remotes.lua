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

local remotes = {}

local OnServerEvent = {}
OnServerEvent.__index = {}

-- Creates a wrapper around a RemoteEvent to allow spoofing
-- 
-- @since v1.0
function remotes.use(RemoteEvent: RemoteEvent | UnreliableRemoteEvent)
	local onEvent = {}

	-- Connects the given function to the event
	-- 
	-- @since v1.0
	function onEvent:Connect(input: (client: t.SPlayer, ...any) -> ())
		return (RemoteEvent :: RemoteEvent).OnServerEvent:Connect(function(player: Player, ...) 
			local posPlr = util.getOrMakeUser(player)
			input(posPlr, ...)
		end)
	end

	-- Connects the given function to the event
	-- 
	-- @since v1.0
	function onEvent:ConnectParallel(input: (client: t.SPlayer, ...any) -> ())
		return (RemoteEvent :: RemoteEvent).OnServerEvent:ConnectParallel(function(player: Player, ...) 
			local posPlr = util.getOrMakeUser(player)
			input(posPlr, ...)
		end)
	end
	
	-- Connects the given function to the event for a single invocation
	-- 
	-- @since v1.0
	function onEvent:Once(input: (client: t.SPlayer, ...any) -> ())
		return (RemoteEvent :: RemoteEvent).OnServerEvent:Once(function(player: Player, ...) 
			local posPlr = util.getOrMakeUser(player)
			input(posPlr, ...)
		end)
	end

	-- Yields the thread until a signal fires, then returns the values received
	-- 
	-- @since v1.0
	function onEvent:Wait()
		local packed = table.pack((RemoteEvent :: RemoteEvent).OnServerEvent:Wait())
		local player = packed[1] :: Player
		local posPlr = util.getOrMakeUser(player)
		
		table.remove(packed, 1)
		
		return posPlr, table.unpack(packed)
	end
	
	local newMetatable = setmetatable(onEvent, OnServerEvent)
	
	return {
		OnServerEvent = newMetatable,
		
		-- Fires an event to a single client
		-- 
		-- @since v1.0
		FireClient = function(self, player: t.SPlayer, ...: any)
			local isReal = (player :: any).Parent == Players;
			(RemoteEvent :: RemoteEvent):FireClient(isReal and (player :: any) or player:GetInstance(), ...)
		end,
		
		-- Fires an event to all clients
		-- 
		-- @since v1.0
		FireAllClients = function(self, ...: any)
			(RemoteEvent :: RemoteEvent):FireAllClients(...)
		end,
	}
end

return remotes