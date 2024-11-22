class_name MainPanel
extends MarginContainer

static var messageScene = load("res://components/message.tscn")
@export var message_container: VBoxContainer
@export var scroll_node: ScrollContainer
@export var text_input: LineEdit

func _ready():
	if Client.INSTANCE:
		Client.INSTANCE.disconnected.connect(clear_messages)
		Client.INSTANCE.logged_in.connect(_on_login)
		Client.INSTANCE.message_received.connect(add_message)
	
	
func _input(event):
	if event is InputEventKey and event.pressed:
		var focused = get_viewport().gui_get_focus_owner()
		if not focused:
			text_input.grab_focus()
	
func add_message(data):
	var message = messageScene.instantiate()
	message.username = str(data.username)
	message.text = str(data.message)
	message_container.add_child(message)
	if message_container.get_child_count() > 50:
		message_container.get_child(0).queue_free()
	await scroll_node.get_v_scroll_bar().changed
	scroll_node.scroll_vertical = scroll_node.get_v_scroll_bar().max_value

func clear_messages():
	for message in message_container.get_children():
		message.queue_free()


func _on_message_submitted(text):
	text_input.text = ""
	if Client.INSTANCE.socket.get_ready_state() != WebSocketPeer.STATE_OPEN:
		return
	
	var packet = {
		"type": Client.DataType.MESSAGE,
		"session_id": Client.INSTANCE.session_id,
		"message": text,
	}
	Client.INSTANCE.socket.send_text(JSON.stringify(packet))

func _on_login(data):
	for message in data.messages:
		add_message(message)
