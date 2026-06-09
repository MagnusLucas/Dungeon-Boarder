using Godot;
using Godot.Collections;

public partial class SteamManager : Node
{
	public static SteamManager Instance { get; private set; }
	public bool IsRunning { get; private set; } = false;

	private GodotObject _steam;

	public override void _Ready()
	{
		Instance = this;

		if (!Engine.HasSingleton("Steam"))
		{
			return;
		}

		_steam = Engine.GetSingleton("Steam");

		var result = (Dictionary)_steam.Call("steamInitEx");

		if (result["status"].AsInt32() == 0)
		{
			IsRunning = true;
			_steam.Connect("avatar_loaded", Callable.From<long, int, byte[]>(OnAvatarLoaded));
			_steam.Connect("persona_state_change", Callable.From<long, int>(OnPersonaStateChange));
			CallDeferred(MethodName.RequestAvatar, 0L);
		}
		else
		{
			GD.PrintErr("[Steam] Failed: " + result["verbal"].AsString());
		}
	}

	public override void _Process(double delta)
	{
		if (IsRunning)
		{
			_steam.Call("run_callbacks");
		}
	}

	public string GetPersonaName()
	{
		if (!IsRunning) return "Player";
		return _steam.Call("getPersonaName").AsString();
	}
	
	public void RequestAvatar(long steamId = 0)
	{
		if (!IsRunning) return;
		if (steamId == 0)
			_steam.Call("getPlayerAvatar", 2);
		else
		{
			_steam.Call("requestUserInformation", steamId, false);
			_steam.Call("getPlayerAvatar", 2, steamId);
		}
	}

	public long GetSteamId()
	{
		if (!IsRunning) return 0;
		return _steam.Call("getSteamID").AsInt64();
	}

	private void OnAvatarLoaded(long steamId, int avatarSize, byte[] buffer)
	{
		var image = Image.CreateFromData(avatarSize, avatarSize, false, Image.Format.Rgba8, buffer);
		if (avatarSize > 128)
			image.Resize(128, 128, Image.Interpolation.Lanczos);
		var texture = ImageTexture.CreateFromImage(image);
		NetworkManager.Instance.PlayerList.SetSteamAvatar(steamId, texture);
		NetworkManager.Instance.EmitSignal(NetworkManager.SignalName.AvatarLoaded, steamId);
	}
	
	private void OnPersonaStateChange(long steamId, int flags)
	{
		if ((flags & 64) != 0)
			RequestAvatar(steamId);
	}

	public override void _ExitTree() => Instance = null;
}
