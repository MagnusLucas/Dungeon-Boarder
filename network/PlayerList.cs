using Godot;
using Godot.Collections;

public partial class PlayerList : Node
{
	private Dictionary<long, Dictionary<string, string>> _players = new();

	private Dictionary<string, string> _localPlayerInfo = new()
	{
		{ "Name", "PlayerName" }
	};

	public Dictionary<long, Dictionary<string, string>> GetAll() => _players;

	public void RegisterLocalPlayer()
	{
		long peerId = NetworkManager.Instance.Multiplayer.GetUniqueId();
		_players[peerId] = _localPlayerInfo;
		NetworkManager.Instance.EmitSignal(
			NetworkManager.SignalName.PlayerConnected, (int)peerId, _localPlayerInfo);
	}

	public void SendLocalInfoTo(long peerId)
	{
		RpcId(peerId, MethodName.ReceivePlayerInfo, _localPlayerInfo);
	}

	public void Remove(long peerId)
	{
		_players.Remove(peerId);
	}

	public void Clear()
	{
		_players.Clear();
	}

	public void SetLocalPlayerInfo(string key, string value)
	{
		_localPlayerInfo[key] = value;
	}

	[Rpc(MultiplayerApi.RpcMode.AnyPeer, TransferMode = MultiplayerPeer.TransferModeEnum.Reliable)]
	private void ReceivePlayerInfo(Dictionary<string, string> incomingInfo)
	{
		int senderId = NetworkManager.Instance.Multiplayer.GetRemoteSenderId();
		_players[senderId] = incomingInfo;
		NetworkManager.Instance.EmitSignal(
			NetworkManager.SignalName.PlayerConnected, senderId, incomingInfo);
	}

	[Rpc(MultiplayerApi.RpcMode.AnyPeer, CallLocal = false, TransferMode = MultiplayerPeer.TransferModeEnum.Reliable)]
	public void SendTestMessage(string message)
	{
		GD.Print($"Message '{message}' received on peer {NetworkManager.Instance.Multiplayer.GetUniqueId()}, " +
				 $"from peer {NetworkManager.Instance.Multiplayer.GetRemoteSenderId()}");
	}
}
