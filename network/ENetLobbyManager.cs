using Godot;

public partial class ENetLobbyManager : LobbyManager
{
	private const int Port = 7000;
	private const string DefaultIP = "127.0.0.1";
	private const int MaxConnections = 3;
	private ENetMultiplayerPeer _peer = null;

	public override Error CreateGame()
	{
		if (_peer != null) return Error.Skip;
		_peer = new ENetMultiplayerPeer();
		Error error = _peer.CreateServer(Port, MaxConnections);
		if (error != Error.Ok) { _peer = null; return error; }
		NetworkManager.Instance.Multiplayer.MultiplayerPeer = _peer;
		NetworkManager.Instance.PlayerList.RegisterLocalPlayer();
		return Error.Ok;
	}

	public override Error JoinGame(string address = "")
	{
		if (_peer != null) return Error.AlreadyInUse;
		if (string.IsNullOrEmpty(address)) address = "127.0.0.1";
		_peer = new ENetMultiplayerPeer();
		Error error = _peer.CreateClient(address, Port);
		if (error != Error.Ok) { _peer = null; return error; }
		NetworkManager.Instance.Multiplayer.MultiplayerPeer = _peer;
		return Error.Ok;
	}

	public override void KickPeer(int peerId) => _peer?.GetPeer(peerId).PeerDisconnect();
	
	public override void DisconnectServer()
	{
		if (_peer == null) return;
		try { _peer.Host?.Destroy(); }
		catch { }
		_peer = null;
	}
}
