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

local spoofer = script.Parent
local types = require(spoofer.types)
local util = require(spoofer.util)
local getColor = require(spoofer.GetColor)

return {
    onRequested = function()
        return false
    end :: (player: Player, requestingId: number) -> boolean,

    onSpoof = function()
        return
    end :: (player: Player, id: number) -> nil,

    onPlayerChat = function(_, fakePlr, msg, text: string)
        if not msg then
            return msg
        end

        local displayName = string.split(msg, ":")[1];
		local plr = util.displays[displayName]
		local userId = plr.UserId
		local badgeTag = fakePlr.HasVerifiedBadge and " ".. utf8.char(0xE000).. " " or ""

        local str = nil
		if userId and fakePlr then
			local col = getColor(Players:GetNameFromUserIdAsync(fakePlr.UserId));
			str = `<font color = \"rgb({math.floor(col.R*255)}, {math.floor(col.G*255)}, {math.floor(col.B*255)})\">{util.getUserInfoWithRetry(fakePlr.UserId, plr)[1].DisplayName}{badgeTag}:</font>`
		end

		return str
    end :: (player: Player, fakePlayer: types.SPlayer?, prefix: string, text: string) -> (string?, string?),
}