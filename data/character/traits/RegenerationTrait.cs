using Godot;

// example implementation for a trait
[GlobalClass]
public partial class RegenerationTrait : CharacterTrait
{
	[Export] public int HealAmount = 2;
	
	public RegenerationTrait()
	{
		TraitName = "Heal me a little bit";
		Description = "Works better than a doctor";
		ActivationType = TraitActivationType.RoundStart;
	}

	public override void Activate(TraitContext context)
	{
		context.Self.CurrentHealth = Mathf.Min(
			context.Self.CurrentHealth + HealAmount,
			context.Self.MaxHealth
		);
	}
}
