using Godot;
using Godot.Collections;

public partial class NetworkManager : Node
{
	public static NetworkManager Instance { get; private set; }
	
	private ENetMultiplayerPeer _peer = null;
	
	[Signal]
	public delegate void PlayerConnectedEventHandler(int peerId, Godot.Collections.Dictionary<string, string> playerInfo);
	[Signal]
	public delegate void PlayerDisconnectedEventHandler(int peerId);
	[Signal]
	public delegate void ServerDisconnectedEventHandler();
	
	private const int Port = 7000;
	private const string ServerIP = "127.0.0.1"; // IPv4 localhost
	private const int MaxConnections = 3;

	private Dictionary<long, Dictionary<string, string>> _players = new();
	
	private Dictionary<string, string> _playerInfo = new()
	{
		{ "Name", "PlayerName" }
	};
	
	private int _playersLoaded = 0;
	
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		Instance = this;
		Multiplayer.PeerConnected += OnPeerConnected;
		Multiplayer.PeerDisconnected += OnPeerDisconnected;
		Multiplayer.ConnectedToServer += OnConnectOk;
		Multiplayer.ConnectionFailed += OnConnectionFail;
		Multiplayer.ServerDisconnected += OnServerDisconnected;
	}

	public override void _Process(double delta)
	{
		
	}
	
	private Error JoinGame(string address = "127.0.0.1")
	{
		if (_peer != null)
		{
			return Error.AlreadyInUse;
		}
		_peer = new ENetMultiplayerPeer(); 
		
		if (string.IsNullOrEmpty(address))
		{
			address = ServerIP;
		}

		Error error = _peer.CreateClient(address, Port);

		if (error != Error.Ok)
		{
			GD.PrintErr($"Failed to create client: {error}");
			return error;
		}

		Multiplayer.MultiplayerPeer = _peer;
		GD.Print("Client joined");
		return Error.Ok;
	}
	
	public Error CreateGame()
	{
		if (_peer != null)
		{
			return Error.Skip;
		}
		
		_peer = new ENetMultiplayerPeer(); 
		
		Error error = _peer.CreateServer(Port, MaxConnections);
		if (error != Error.Ok)
		{
			GD.PrintErr($"Failed to create server: {error}");
			return error;
		}

		Multiplayer.MultiplayerPeer = _peer;
		GD.Print("Server created");
		
		_players[1] = _playerInfo;
		EmitSignal(SignalName.PlayerConnected, 1, _playerInfo);
		return Error.Ok;
	}
	
	private void RemoveMultiplayerPeer()
	{
		Multiplayer.MultiplayerPeer = null;
		_players.Clear();
	}

	// When the server decides to start the game from a UI scene,
	// do Rpc(Lobby.MethodName.LoadGame, filePath);
	[Rpc(CallLocal = true,TransferMode = MultiplayerPeer.TransferModeEnum.Reliable)]
	private void LoadGame(string gameScenePath)
	{
		GetTree().ChangeSceneToFile(gameScenePath);
	}

	// Every peer will call this when they have loaded the game scene.
	[Rpc(MultiplayerApi.RpcMode.AnyPeer,CallLocal = true,TransferMode = MultiplayerPeer.TransferModeEnum.Reliable)]
	private void PlayerLoaded()
	{
		if (Multiplayer.IsServer())
		{
			_playersLoaded += 1;
			if (_playersLoaded == _players.Count)
			{
				// GetNode<Game>("/root/Game").StartGame();
			}
		}
	}

	private void OnPeerConnected(long peerId)
	{
		GD.Print("Peer connected with Peer ID = " + peerId);
		RpcId(peerId, MethodName.RegisterPlayer, _playerInfo);
	}
	
	[Rpc(MultiplayerApi.RpcMode.AnyPeer,TransferMode = MultiplayerPeer.TransferModeEnum.Reliable)]
	private void RegisterPlayer(Godot.Collections.Dictionary<string, string> newPlayerInfo)
	{
		int newPlayerId = Multiplayer.GetRemoteSenderId();
		_players[newPlayerId] = newPlayerInfo;
		EmitSignal(SignalName.PlayerConnected, newPlayerId, newPlayerInfo);
	}

	private void OnPeerDisconnected(long peerId)
	{
		GD.Print("Peer disconnected with Peer ID = " + peerId);
		_players.Remove(peerId);
		EmitSignal(SignalName.PlayerDisconnected, peerId);
	}

	private void OnConnectOk()
	{
		int peerId = Multiplayer.GetUniqueId();
		_players[peerId] = _playerInfo;
		EmitSignal(SignalName.PlayerConnected, peerId, _playerInfo);
	}

	private void OnConnectionFail()
	{
		Multiplayer.MultiplayerPeer = null;
	}

	private void OnServerDisconnected()
	{
		Multiplayer.MultiplayerPeer = null;
		_peer = null;
		GD.Print("Server disconnected");
		_players.Clear();
		EmitSignal(SignalName.ServerDisconnected);
	}

	[Rpc(MultiplayerApi.RpcMode.AnyPeer, CallLocal = false, TransferMode = MultiplayerPeer.TransferModeEnum.Reliable)]
	private void SendTestMessage(string message)
	{
		GD.Print($"Message {message} received on peer {Multiplayer.GetUniqueId()}, from peer {Multiplayer.GetRemoteSenderId()}");
	}
	
	public Dictionary<long, Dictionary<string, string>> GetPlayers()
	{
		return _players;
	}
}
