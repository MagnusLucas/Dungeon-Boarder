extends Control

@export var panel_size: Vector2 = Vector2(360, 220)
@export var max_displayed_messages: int = 40

var _chat_log: RichTextLabel
var _chat_input: LineEdit
var _send_button: Button
var _message_count: int = 0

func _ready() -> void:
	custom_minimum_size = panel_size

	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(vbox)

	_chat_log = RichTextLabel.new()
	_chat_log.bbcode_enabled = true
	_chat_log.scroll_following = true
	_chat_log.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_chat_log.custom_minimum_size = Vector2(0, panel_size.y - 32)
	vbox.add_child(_chat_log)

	var hbox := HBoxContainer.new()
	vbox.add_child(hbox)

	_chat_input = LineEdit.new()
	_chat_input.placeholder_text = "Say something..."
	_chat_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(_chat_input)

	_send_button = Button.new()
	_send_button.text = "Send"
	hbox.add_child(_send_button)

	_send_button.pressed.connect(_send_current_input)
	_chat_input.text_submitted.connect(func(_t): _send_current_input())

	if NetworkManager and NetworkManager.ChatManager:
		NetworkManager.ChatManager.ChatMessageReceived.connect(_on_chat_message_received)

func _send_current_input() -> void:
	var text := _chat_input.text.strip_edges()
	if text.is_empty():
		return

	NetworkManager.SendChatMessage(text)
	_chat_input.text = ""
	_chat_input.grab_focus()

func _on_chat_message_received(_sender_id: int, player_name: String, message: String) -> void:
	_chat_log.append_text("[b]%s:[/b] %s\n" % [player_name, message])
	_message_count += 1

	if _message_count > max_displayed_messages:
		_chat_log.remove_paragraph(0)
		_message_count -= 1
