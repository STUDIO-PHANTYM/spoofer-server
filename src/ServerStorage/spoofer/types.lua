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

export type SpoofConstructor = {
	as: (player: Player) -> SPlayer
}

export type SpoofRemoteEvent = {
	OnServerEvent: {}
}

type Disconnection = {
	Disconnect: (self: Disconnection) -> nil
}

type Connection<T, K, O> = {
	Connect: (self: Connection<T, K, O>, func: (T, K?) -> O) -> Disconnection,
	Wait: (self: Connection<T, K, O>) -> nil,
} 

type PlayerProps = 	"AccountAge" |
					"AutoJumpEnabled" | 
					"CameraMaxZoomDistance" |
					"CameraMinZoomDistance" |
					"CameraMode" | 
					"CanLoadCharacterAppearance" |
					"Character" |
					"CharacterAppearanceId" |
					"DevCameraOcclusionMode" |
					"DevComputerCameraMode" |
					"DevComputerMovementMode" |
					"DevEnableMouseLock" |
					"DevTouchCameraMode" |
					"DevTouchMovementMode" |
					"DisplayName" |
					"FollowUserId" |
					"GameplayPaused" |
					"HasVerifiedBadge" |
					"HealthDisplayDistance" |
					"LocaleId" |
					"MembershipType" |
					"NameDisplayDistance" |
					"Neutral" |
					"ReplicationFocus" |
					"RespawnLocation" |
					"Team" |
					"TeamColor" |
					"UserId" |
					"CharacterAdded" |
					"CharacterAppearanceLoaded" |
					"CharacterRemoving" |
					"Chatted" |
					"Idled" |
					"OnTeleport"

type PlayerMethods = "ClearCharacterAppearance" |
"DistanceFromCharacter" |
"GetJoinData" |
"GetMouse" |
"GetNetworkPing" |
"HasAppearanceLoaded" |
"IsVerified" |
"Kick" |
"Move" |
"SetAccountAge" |
"SetSuperSafeChat" |
"GetFriendsOnline" |
"GetRankInGroup" |
"GetRoleInGroup" |
"IsFriendsWith" |
"IsInGroup" |
"LoadCharacter" |
"LoadCharacterWithHumanoidDescription"

export type SPlayer = {
	Name: string,
	DisplayName: string,
	UserId: number,
	PlayerGui: PlayerGui,
	Backpack: Backpack,

	GetCharacter: () -> Model?,
	GetProperty:<T>(self: SPlayer, name: PlayerProps) -> T?,
	SetProperty:<T>(self: SPlayer,name: PlayerProps, value: T) -> nil,
	CallMethod:<T>(self: SPlayer, name: string, ...any) -> T,
	GetInstance:(self: SPlayer) -> Player,

	CharacterAdded: Connection<Model, nil, nil>,
	CharacterRemoving: Connection<Model, nil, Model>,

	isFake: boolean,
}

return nil