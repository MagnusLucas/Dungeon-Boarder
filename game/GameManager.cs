using Godot;
using Godot.Collections;
using System.Linq;

public partial class GameManager : Node
{
	public static GameManager Instance { get; private set; }
	
	private Dictionary<string, CharacterBackendData> _characters = new();

	public override void _Ready()
	{
		Instance = this;
		PrintPlayers();
		
		// this is just a test (change peerId to the player who owns the character)
		var testPirate = GD.Load<CharacterBackendData>("res://data/character/test_pirate.tres");
		SpawnCharacter(testPirate, ownerPeerId: 1, position: new Vector2I(0, 0));

		PrintSpawnedCharacters();

	}
	
	public CharacterBackendData SpawnCharacter(CharacterBackendData characterData, int ownerPeerId, Vector2I position)
	{
		var character = (CharacterBackendData)characterData.Duplicate(true);
		character.Init(ownerPeerId, position);

		_characters[character.Id] = character;

		TriggerTraits(character, TraitActivationType.OnSpawn);
		return character;
	}
	
	public void TriggerTraits(CharacterBackendData character, TraitActivationType type, CharacterBackendData target = null)
	{
		if (!Multiplayer.IsServer()) return;

		var context = new TraitContext(character, target);
		foreach (var trait in character.GetTraits(type))
			trait.Activate(context);
	}

	private void PrintPlayers()
	{
		var players = NetworkManager.Instance.PlayerList.GetAll();
		GD.Print($"Amount of players {players.Count}");
		foreach (var entry in players)
			GD.Print($"  PeerID: {entry.Key}, Name: {entry.Value["Name"]}");
	}
	
	public void PrintSpawnedCharacters()
	{
		foreach (var c in _characters.Values)
		{
			var traits = string.Join(", ", c.Traits.Select(t => $"{t.TraitName}[{t.ActivationType}]"));
			GD.Print($"[{c.Id}] {c.Name} HP:{c.CurrentHealth}/{c.MaxHealth} ATK:{c.CurrentAttack} — Traits: {traits}");
		}
	}
}
