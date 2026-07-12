using System.Collections.Generic;

public record Achievement(string Id, string Name, string Description);

public static class AchievementDatabase
{
	public static readonly List<Achievement> All = new()
	{
		new("ACH_TEST_1", "Test 1", "First test"),
		new("ACH_TEST_2", "Test 2", "Second test"),
		// Add more achievements here.
	};

	public static Achievement Get(string id) => All.Find(a => a.Id == id);
}
