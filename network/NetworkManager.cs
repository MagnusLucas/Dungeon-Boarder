using Godot;
using Godot.Collections;

public partial class NetworkManager : Node
{
	public static NetworkManager Instance { get; private set; }
	
	public enum BackendType { ENet, Steam }
	public BackendType CurrentBackend { get; private set; } = BackendType.ENet;

	[Signal] public delegate void PlayerConnectedEventHandler(int peerId, Dictionary<string, string> playerInfo);
	[Signal] public delegate void PlayerDisconnectedEventHandler(int peerId);
	[Signal] public delegate void ServerDisconnectedEventHandler();

	public PlayerList PlayerList { get; private set; }
	public LobbyManager LobbyManager { get; private set; }
	
	public SteamManager SteamManager { get; private set; }

	public override void _Ready()
	{
		Instance = this;

		PlayerList = new PlayerList();
		PlayerList.Name = "PlayerList";
		AddChild(PlayerList);

		LobbyManager = new LobbyManager();
		LobbyManager.Name = "LobbyManager";
		AddChild(LobbyManager);

		SteamManager = new SteamManager();
		SteamManager.Name = "SteamManager";
		AddChild(SteamManager);
		
		Multiplayer.PeerConnected += OnPeerConnected;
		Multiplayer.PeerDisconnected += OnPeerDisconnected;
		Multiplayer.ConnectedToServer += OnConnectOk;
		Multiplayer.ConnectionFailed += OnConnectionFail;
		Multiplayer.ServerDisconnected += OnServerDisconnected;
		
		if (CurrentBackend == BackendType.Steam)
		{
			GD.Print("[Network] Using Steam backend.");
		}
		else
		{
			GD.Print("[Network] Using ENet backend.");
		}
	}

	public Error CreateGame() => LobbyManager.CreateGame();
	public Error JoinGame(string address = "") => LobbyManager.JoinGame(address);
	
	public void BroadcastTestMessage(string message) => 
		PlayerList.Rpc("SendTestMessage", message);

	private void OnPeerConnected(long peerId)
	{
		GD.Print("Peer connected with Peer ID = " + peerId);
		PlayerList.SendLocalInfoTo(peerId);
	}

	private void OnPeerDisconnected(long peerId)
	{
		GD.Print("Peer disconnected with Peer ID = " + peerId);
		PlayerList.Remove(peerId);
		EmitSignal(SignalName.PlayerDisconnected, peerId);
	}

	private void OnConnectOk()
	{
		PlayerList.RegisterLocalPlayer();
	}

	private void OnConnectionFail()
	{
		Multiplayer.MultiplayerPeer = null;
	}

	private void OnServerDisconnected()
	{
		Multiplayer.MultiplayerPeer = null;
		LobbyManager.ClearPeer();
		PlayerList.Clear();
		GD.Print("Server disconnected");
		EmitSignal(SignalName.ServerDisconnected);
	}
	
	public void StartGame(string scenePath)
	{
		if (!Multiplayer.IsServer()) return;
		Rpc(MethodName.LoadGame, scenePath);
	}

	[Rpc(MultiplayerApi.RpcMode.Authority, CallLocal = true, TransferMode = MultiplayerPeer.TransferModeEnum.Reliable)]
	private void LoadGame(string scenePath)
	{
		GetTree().ChangeSceneToFile(scenePath);
	}
	
}
