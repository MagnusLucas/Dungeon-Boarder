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
			GD.PrintErr("[Steam] Not found — is GodotSteam loaded?");
			return;
		}

		_steam = Engine.GetSingleton("Steam");

		var result = (Dictionary)_steam.Call("steamInitEx");

		if (result["status"].AsInt32() == 0)
		{
			IsRunning = true;
			GD.Print("[Steam] Running! Name: " + _steam.Call("getPersonaName").AsString());
		}
		else
		{
			GD.PrintErr("[Steam] Failed: " + result["verbal"].AsString());
		}
	}

	public override void _Process(double delta)
	{
		if (IsRunning)
			_steam.Call("run_callbacks");
	}

	public override void _ExitTree() => Instance = null;
}
