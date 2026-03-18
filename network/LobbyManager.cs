// LobbyManager.cs — connection creation and teardown

using Godot;

public partial class LobbyManager : Node
{
	private const int Port = 7000;
	private const string DefaultIP = "127.0.0.1";
	private const int MaxConnections = 3;

	private ENetMultiplayerPeer _peer = null;

	public Error CreateGame()
	{
		if (_peer != null) return Error.Skip;

		_peer = new ENetMultiplayerPeer();
		Error error = _peer.CreateServer(Port, MaxConnections);
		if (error != Error.Ok)
		{
			GD.PrintErr($"Failed to create server: {error}");
			_peer = null;
			return error;
		}

		NetworkManager.Instance.Multiplayer.MultiplayerPeer = _peer;
		GD.Print("Server created");

		NetworkManager.Instance.PlayerList.RegisterLocalPlayer();
		return Error.Ok;
	}

	public Error JoinGame(string address = "")
	{
		if (_peer != null) return Error.AlreadyInUse;
		if (string.IsNullOrEmpty(address)) address = DefaultIP;

		_peer = new ENetMultiplayerPeer();
		Error error = _peer.CreateClient(address, Port);
		if (error != Error.Ok)
		{
			GD.PrintErr($"Failed to create client: {error}");
			_peer = null;
			return error;
		}

		NetworkManager.Instance.Multiplayer.MultiplayerPeer = _peer;
		GD.Print("Client joined");
		return Error.Ok;
	}

	public void ClearPeer()
	{
		_peer = null;
	}
}
