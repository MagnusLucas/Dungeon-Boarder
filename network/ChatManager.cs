using Godot;
using System.Collections.Generic;

public partial class ChatManager : Node
{
	[Signal] public delegate void ChatMessageReceivedEventHandler(long senderId, string playerName, string message);

	private const int MaxChatHistory = 40;
	private readonly List<(long SenderId, string PlayerName, string Message)> _chatHistory = new();

	public void SendMessage(string text)
	{
		text = text?.Trim();
		if (string.IsNullOrEmpty(text)) return;

		Rpc(MethodName.ReceiveMessage, text);
	}

	public void SendChatHistoryTo(long peerId)
	{
		if (!Multiplayer.IsServer()) return;

		foreach (var msg in _chatHistory)
			RpcId(peerId, MethodName.ReceiveChatHistory, msg.SenderId, msg.PlayerName, msg.Message);
	}

	[Rpc(MultiplayerApi.RpcMode.AnyPeer, CallLocal = true, TransferMode = MultiplayerPeer.TransferModeEnum.Reliable)]
	private void ReceiveMessage(string text)
	{
		long senderId = Multiplayer.GetRemoteSenderId();
		if (senderId == 0)
			senderId = Multiplayer.GetUniqueId();

		string playerName = GetPlayerName(senderId);

		if (Multiplayer.IsServer())
		{
			_chatHistory.Add((senderId, playerName, text));
			if (_chatHistory.Count > MaxChatHistory)
				_chatHistory.RemoveAt(0);
		}

		EmitSignal(SignalName.ChatMessageReceived, senderId, playerName, text);
	}

	[Rpc(MultiplayerApi.RpcMode.Authority, TransferMode = MultiplayerPeer.TransferModeEnum.Reliable)]
	private void ReceiveChatHistory(long senderId, string playerName, string text)
	{
		EmitSignal(SignalName.ChatMessageReceived, senderId, playerName, text);
	}

	private string GetPlayerName(long peerId)
	{
		var players = NetworkManager.Instance.PlayerList.GetAll();
		if (players.TryGetValue(peerId, out var info) && info.TryGetValue("Name", out var name))
			return name;
		return $"Player {peerId}";
	}
}
