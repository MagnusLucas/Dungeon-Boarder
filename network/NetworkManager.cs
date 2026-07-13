using Godot;
using Godot.Collections;

public partial class NetworkManager : Node
{
	public static NetworkManager Instance { get; private set; }
	
	public enum BackendType { ENet, Steam }
	public BackendType CurrentBackend { get; private set; } = BackendType.Steam;

	[Signal] public delegate void PlayerConnectedEventHandler(int peerId, Dictionary<string, string> playerInfo);
	[Signal] public delegate void PlayerDisconnectedEventHandler(int peerId);
	[Signal] public delegate void ServerDisconnectedEventHandler();
	[Signal] public delegate void AvatarLoadedEventHandler(long steamId);

	public PlayerList PlayerList { get; private set; }
	public LobbyManager LobbyManager { get; private set; }
	public SteamManager SteamManager { get; private set; }
	public ChatManager ChatManager { get; private set; }
	public AchievementManager AchievementManager { get; private set; }

	public override void _Ready()
	{
		Instance = this;

		PlayerList = new PlayerList();
		PlayerList.Name = "PlayerList";
		AddChild(PlayerList);

		InitLobbyManager();

		SteamManager = new SteamManager();
		SteamManager.Name = "SteamManager";
		AddChild(SteamManager);
		
		ChatManager = new ChatManager();
		ChatManager.Name = "ChatManager";
		AddChild(ChatManager);
		
		AchievementManager = new AchievementManager();
		AchievementManager.Name = "AchievementManager";
		AddChild(AchievementManager);
		
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

	// Wrappers
	public Error CreateGame() => LobbyManager.CreateGame();
	public Error JoinGame(string address = "") => LobbyManager.JoinGame(address);
	public void OpenInviteOverlay() => LobbyManager.OpenInviteOverlay();
	public void BroadcastTestMessage(string message) => 
		PlayerList.Rpc("SendTestMessage", message);
	public void SendChatMessage(string message) => ChatManager.SendMessage(message);
	public void UnlockAchievement(string achievementId) => AchievementManager.Unlock(achievementId);
	public void ResetAchievements() => AchievementManager.ResetAll();

	private void OnPeerConnected(long peerId)
	{
		GD.Print("Peer connected with Peer ID = " + peerId);
		PlayerList.SendLocalInfoTo(peerId);

		if (Multiplayer.IsServer())
			ChatManager.SendChatHistoryTo(peerId);
	}

	private void OnPeerDisconnected(long peerId)
	{
		GD.Print($"Peer disconnected: {peerId}, IsServer: {Multiplayer.IsServer()}");
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
		PlayerList.Clear();
		LobbyManager.DisconnectServer();
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
	public void KickPlayer(long peerId)
	{
		if (!Multiplayer.IsServer()) return;
		RpcId(peerId, MethodName.ForceDisconnect);
		LobbyManager.KickPeer((int)peerId);
		PlayerList.Remove(peerId);
		EmitSignal(SignalName.PlayerDisconnected, (int)peerId);
	}
	
	[Rpc(MultiplayerApi.RpcMode.Authority, CallLocal = false, TransferMode = MultiplayerPeer.TransferModeEnum.Reliable)]
	private void ForceDisconnect()
	{
		Multiplayer.MultiplayerPeer = null;
		LobbyManager.DisconnectServer();
		PlayerList.Clear();
		EmitSignal(SignalName.ServerDisconnected);
	}
	
	public void SwitchBackend(BackendType backend)
	{
		if (Multiplayer.MultiplayerPeer != null)
		{
			if (Multiplayer.IsServer())
				Rpc(MethodName.ForceDisconnect);
			OnServerDisconnected();
		}

		CurrentBackend = backend;
		InitLobbyManager();
	}
	
	private void InitLobbyManager()
	{
		if (LobbyManager != null)
		{
			LobbyManager.QueueFree();
			LobbyManager = null;
		}
	
		LobbyManager = CurrentBackend == BackendType.Steam
			? new SteamLobbyManager()
			: new ENetLobbyManager();
		LobbyManager.Name = "LobbyManager";
		AddChild(LobbyManager);
	}
}
