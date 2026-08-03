using Godot;
using Godot.Collections;

// use to define the activation logic of a trait (implement this where it needs to be)
public enum TraitActivationType
{
	OnSpawn,
	RoundStart,
	RoundEnd,
	TurnStart,
	TurnEnd,
	OnAttack,
	OnHit,
	OnDeath,
	OnMove
}

public class TraitContext
{
	public CharacterBackendData Self;
	public CharacterBackendData Target;

	public TraitContext(CharacterBackendData self, CharacterBackendData target = null)
	{
		Self = self;
		Target = target;
	}
}

[GlobalClass]
public abstract partial class CharacterTrait : Resource
{
	[Export] public string TraitName;
	[Export] public string Description;
	[Export] public TraitActivationType ActivationType;

	public abstract void Activate(TraitContext context);
}
