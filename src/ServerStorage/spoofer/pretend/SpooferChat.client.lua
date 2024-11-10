local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")

TextChatService.OnIncomingMessage = function(message: TextChatMessage)
	if not message.TextSource then return end
	
	local rem = ReplicatedStorage:FindFirstChild("SpooferChat") :: RemoteEvent
	rem:FireServer(message.PrefixText)
	local res = rem.OnClientEvent:Wait()
	
	local properties = Instance.new("TextChatMessageProperties")
	properties.PrefixText = res
	
	return properties
end