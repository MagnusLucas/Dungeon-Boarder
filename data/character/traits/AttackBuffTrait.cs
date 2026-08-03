using Godot;

// example implementation for a trait
[GlobalClass]
public partial class AttackBuffTrait : CharacterTrait
{
	[Export] public int AttackBonus = 2;

	public AttackBuffTrait()
	{
		TraitName = "I like to lift sometimes";
		Description = "Sometimes hitting the gym is worthwhile";
		ActivationType = TraitActivationType.OnSpawn;
	}
	
	public override void Activate(TraitContext context)
	{
		context.Self.CurrentAttack = context.Self.MaxAttack + AttackBonus;
	}
}
