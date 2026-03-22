using Godot;
using Godot.Collections;

public partial class GameManager : Node
{
	public static GameManager Instance { get; private set; }

	public override void _Ready()
	{
		Instance = this;
		PrintPlayers();
	}

	private void PrintPlayers()
	{
		var players = NetworkManager.Instance.PlayerList.GetAll();
		GD.Print($"Amount of players {players.Count}");
		foreach (var entry in players)
			GD.Print($"  PeerID: {entry.Key}");
	}
}
