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
			CallDeferred("_RequestAvatar");
		}
		else
		{
			GD.PrintErr("[Steam] Failed: " + result["verbal"].AsString());
		}
		//
		// foreach (var signal in _steam.GetSignalList())
		// 	GD.Print("Signal: " + signal);
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
	
	private void _RequestAvatar()
	{
		_steam.Call("getPlayerAvatar", 2);
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
		GD.Print("Avatar stored for steam ID: " + steamId);
	}

	public override void _ExitTree() => Instance = null;
}
