using Godot;
using System.Collections.Generic;

public partial class AchievementManager : Node
{
	public static AchievementManager Instance { get; private set; }

	[Signal] public delegate void AchievementUnlockedEventHandler(string achievementId);

	private const string SavePath = "user://achievements.json";
	private readonly HashSet<string> _unlocked = new();

	public override void _Ready()
	{
		Instance = this;
		LoadLocal();
	}

	public void Unlock(string achievementId)
	{
		if (AchievementDatabase.Get(achievementId) == null)
		{
			GD.PrintErr($"[AchievementManager] Unknown achievement id: {achievementId}");
			return;
		}

		if (_unlocked.Contains(achievementId))
			return;

		_unlocked.Add(achievementId);
		SaveLocal();

		if (IsSteamActive())
		{
			NetworkManager.Instance.SteamManager.UnlockAchievement(achievementId);
		}

		EmitSignal(SignalName.AchievementUnlocked, achievementId);
	}

	public bool IsUnlocked(string achievementId) => _unlocked.Contains(achievementId);

	public void ResetAll()
	{
		_unlocked.Clear();
		SaveLocal();

		if (IsSteamActive())
		{
			NetworkManager.Instance.SteamManager.ResetAllAchievements();
		}

		GD.Print("[AchievementManager] All achievement progress reset.");
	}

	private bool IsSteamActive()
	{
		return NetworkManager.Instance != null
			   && NetworkManager.Instance.CurrentBackend == NetworkManager.BackendType.Steam
			   && NetworkManager.Instance.SteamManager != null
			   && NetworkManager.Instance.SteamManager.IsRunning;
	}

	private void SaveLocal()
	{
		var arr = new Godot.Collections.Array();
		foreach (var id in _unlocked)
			arr.Add(id);
		
		// TODO - fix later
		DirAccess.MakeDirRecursiveAbsolute("res://saves/achievements.json");

		using var file = FileAccess.Open(SavePath, FileAccess.ModeFlags.Write);
		if (file == null)
		{
			GD.PrintErr($"[AchievementManager] Failed to save: {FileAccess.GetOpenError()}");
			return;
		}
		file.StoreString(Json.Stringify(arr));
	}

	private void LoadLocal()
	{
		if (!FileAccess.FileExists(SavePath))
			return;

		using var file = FileAccess.Open(SavePath, FileAccess.ModeFlags.Read);
		if (file == null) return;

		var parsed = Json.ParseString(file.GetAsText());
		if (parsed.VariantType != Variant.Type.Array) return;

		foreach (var item in parsed.AsGodotArray())
			_unlocked.Add(item.AsString());
	}
}
