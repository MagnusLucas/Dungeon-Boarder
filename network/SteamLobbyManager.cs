using Godot;

public partial class SteamLobbyManager : LobbyManager
{
	private GodotObject _steam;
	private ulong _lobbyId = 0;
	
	public override void _Ready()
	{
		_steam = Engine.GetSingleton("Steam");
		_steam.Connect("lobby_created", Callable.From<long, long>(OnLobbyCreated));
		_steam.Connect("join_requested", Callable.From<long, long>(OnJoinRequested));
		_steam.Connect("lobby_joined", Callable.From<long, long, bool, long>(OnLobbyJoined));
	}
	
	public override Error CreateGame()
	{
		if (!SteamManager.Instance.IsRunning) return Error.Failed;
		_steam.Call("createLobby", 2, 3);
		return Error.Ok;
	}

	public override Error JoinGame(string address = "")
	{
		if (!SteamManager.Instance.IsRunning)
		{
			GD.PrintErr("[Steam] Steam not running");
			return Error.Failed;
		}
		if (string.IsNullOrEmpty(address))
		{
			GD.PrintErr("[Steam] No lobby ID provided");
			return Error.Failed;
		}
		if (!long.TryParse(address, out long lobbyId)) 
		{
			GD.PrintErr("[Steam] Invalid lobby ID: " + address);
			return Error.Failed;
		}
	
		GD.Print("[Steam] Attempting to join lobby: " + lobbyId);
		_steam.Call("joinLobby", lobbyId);
		return Error.Ok;
	}
	
	private void OnLobbyCreated(long result, long lobbyId)
	{
		if (result != 1) { GD.PrintErr("[Steam] Failed: " + result); return; }
		_lobbyId = (ulong)lobbyId;
		GD.Print("[Steam] Lobby created: " + _lobbyId);
		var peer = (MultiplayerPeer)ClassDB.Instantiate("SteamMultiplayerPeer").AsGodotObject();
		peer.Call("create_host", 0);
		peer.Call("set", "server_relay", true);
		NetworkManager.Instance.Multiplayer.MultiplayerPeer = peer;
		NetworkManager.Instance.PlayerList.RegisterLocalPlayer();
		_steam.Call("setLobbyJoinable", lobbyId, true);
		_steam.Call("setLobbyData", lobbyId, "game", "DungeonBoarders");
	}

	private void OnJoinRequested(long lobbyId, long friendId)
	{
		GD.Print("[Steam] Join requested for lobby: " + lobbyId);
		_steam.Call("joinLobby", lobbyId);
	}

	private void OnLobbyJoined(long lobbyId, long permissions, bool locked, long response)
	{
		if (response != 1) { GD.PrintErr("[Steam] Failed to join: " + response); return; }

		long hostSteamId = _steam.Call("getLobbyOwner", lobbyId).AsInt64();
		long mySteamId = _steam.Call("getSteamID").AsInt64();
	
		GD.Print($"[Steam] Lobby joined: {lobbyId}");

		if (hostSteamId == mySteamId) return;

		GD.Print($"[Steam] Connecting to host: {hostSteamId}");
		var peer = (MultiplayerPeer)ClassDB.Instantiate("SteamMultiplayerPeer").AsGodotObject();
		peer.Call("create_client", hostSteamId, 0);
		NetworkManager.Instance.Multiplayer.MultiplayerPeer = peer;
	}
	
	public override void OpenInviteOverlay()
	{
		if (_lobbyId == 0) return;
		_steam.Call("activateGameOverlayInviteDialog", _lobbyId);
	}

	public override void KickPeer(int peerId)
	{
		if (_lobbyId == 0) return;
		var players = NetworkManager.Instance.PlayerList.GetAll();
		if (!players.TryGetValue(peerId, out var playerInfo)) return;
		long steamId = long.Parse(playerInfo["SteamId"]);
		_steam.Call("kickLobbyMember", (long)_lobbyId, steamId);
	}
	
	public override void DisconnectServer()
	{
		_lobbyId = 0;
	}
}
