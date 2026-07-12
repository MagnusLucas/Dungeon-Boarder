extends Control

@export var panel_size: Vector2 = Vector2(280, 260)

var _test_achievements := [
	{"id": "ACH_TEST_1", "name": "Test 1"},
	{"id": "ACH_TEST_2", "name": "Test 2"},
]

func _ready() -> void:
	custom_minimum_size = panel_size

	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(vbox)

	var title := Label.new()
	title.text = "Achievement Test Panel"
	vbox.add_child(title)

	for entry in _test_achievements:
		var button := Button.new()
		button.text = "Unlock: %s" % entry["name"]
		button.pressed.connect(_on_unlock_pressed.bind(entry["id"]))
		vbox.add_child(button)

	var separator := HSeparator.new()
	vbox.add_child(separator)

	var reset_button := Button.new()
	reset_button.text = "Reset All Achievements"
	reset_button.pressed.connect(_on_reset_pressed)
	vbox.add_child(reset_button)

	if NetworkManager and NetworkManager.AchievementManager:
		NetworkManager.AchievementManager.AchievementUnlocked.connect(_on_achievement_unlocked)
	else:
		push_warning("AchievementTestPanel: NetworkManager.AchievementManager not found.")

func _on_unlock_pressed(achievement_id: String) -> void:
	NetworkManager.UnlockAchievement(achievement_id)

func _on_reset_pressed() -> void:
	NetworkManager.ResetAchievements()

func _on_achievement_unlocked(achievement_id: String) -> void:
	print("Achievement unlocked: ", achievement_id)
