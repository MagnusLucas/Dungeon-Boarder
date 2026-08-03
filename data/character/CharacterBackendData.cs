using Godot;
using Godot.Collections;
using System.Collections.Generic;

[GlobalClass]
public partial class CharacterBackendData : Resource
{
	[Export] public string Id;
	[Export] public string Name;

	// add more stats, these are just some I added that came to my head at the moment
	[Export] public int BaseHealth = 10;
	[Export] public int BaseAttack = 2;
	[Export] public int BaseDefense = 10;
	[Export] public int BaseMovement = 3;
	[Export] public int BaseCost = 3;

	[Export] public Array<CharacterTrait> Traits = new();
	
	public int OwnerPeerId;
	public Vector2I BoardPosition;
	
	public bool HasActedThisTurn = false;

	public int MaxHealth;
	public int CurrentHealth;

	public int MaxAttack;
	public int CurrentAttack;

	public int MaxDefense;
	public int CurrentDefense;

	public int MaxMovement;
	public int CurrentMovement;
	
	public bool IsAlive() => CurrentHealth > 0;

	public void ResetTurn() => HasActedThisTurn = false;

	// use to initialize character stats upon spawning em on the board
	public void Init(int ownerPeerId, Vector2I position)
	{
		OwnerPeerId = ownerPeerId;
		BoardPosition = position;
		HasActedThisTurn = false;

		MaxHealth = BaseHealth;
		CurrentHealth = BaseHealth;

		MaxAttack = BaseAttack;
		CurrentAttack = BaseAttack;

		MaxDefense = BaseDefense;
		CurrentDefense = BaseDefense;

		MaxMovement = BaseMovement;
		CurrentMovement = BaseMovement;
	}
	
	// use to get all traits of a specific character by TraitActivationType
	public IEnumerable<CharacterTrait> GetTraits(TraitActivationType type)
	{
		foreach (var trait in Traits)
			if (trait.ActivationType == type)
				yield return trait;
	}
}
