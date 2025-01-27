local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")

TextChatService.OnIncomingMessage = function(message: TextChatMessage)
	if not message.TextSource then return end
	
	local rem = ReplicatedStorage:FindFirstChild("SpooferChat") :: RemoteEvent
	rem:FireServer(message.PrefixText, message.Text)
	local prefix, text = rem.OnClientEvent:Wait()
	
	local properties = Instance.new("TextChatMessageProperties")
	properties.PrefixText = prefix or properties.PrefixText
	properties.Text = text or properties.Text
	
	return properties
end