class_name Client
extends Node2D

var messageScene = preload("res://message.tscn")
var displayedUserScene = preload("res://displayed_user.tscn")

var socket = WebSocketPeer.new()
var json = JSON.new()

var session_id = ""
var username = ""
static var INSTANCE

@export var user_container: VBoxContainer
@export var message_container: VBoxContainer
@export var text_input: LineEdit
@export var scroll_msg_container: ScrollContainer

enum DataType{
	INIT,
	MESSAGE,
	LOGIN,
	USER_CONNECTED,
	USER_DISCONNECTED,
}


signal logged_in
signal disconnected

func _init():
	if INSTANCE == null:
		INSTANCE = self

func _ready():
	socket.handshake_headers = ['user-agent: Mozilla']
	set_process(false)

func _process(delta):
	socket.poll()
	var state = socket.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count():
			var packet = socket.get_packet().get_string_from_utf8()
			var result = json.parse(packet)
			if result == OK:
				var data = json.data
				_on_data_received(data)
			else:
				print("Could not parse data packet:", packet)
	elif state == WebSocketPeer.STATE_CLOSING:
		pass
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = socket.get_close_code()
		var reason = socket.get_close_reason()
		print("Websocket closed with code: %d, reason: %s" % [code, reason])
		emit_signal("disconnected")
		set_process(false)

func _on_message_submitted(text):
	text_input.text = ""
	if socket.get_ready_state() != WebSocketPeer.STATE_OPEN:
		return
	
	var packet = {
		"type": DataType.MESSAGE,
		"session_id": session_id,
		"message": text,
	}
	socket.send_text(JSON.stringify(packet))
	

func _on_data_received(data):
	match data.type as DataType:
		DataType.MESSAGE:
			_resolve_message(data)
		DataType.LOGIN:
			_resolve_login(data)
		DataType.USER_CONNECTED:
			if data.username != username:
				add_user_to_list(str(data.username))
		DataType.USER_DISCONNECTED:
			remove_user_from_list(str(data.username))
		_:
			push_warning("Received invalid data type: ", data.type)
			

func add_user_to_list(username):
	var new_user = displayedUserScene.instantiate()
	username[0] = username[0].to_upper()
	new_user.username = str(username)
	new_user.name = str(username)
	user_container.add_child(new_user)

func remove_user_from_list(username):
	for child in user_container.get_children():
		if child.name == username:
			child.queue_free()
	
func _resolve_message(data):
	var message = messageScene.instantiate()
	message.username = str(data.username)
	message.text = str(data.message)
	message_container.add_child(message)
	if message_container.get_child_count() > 50:
		message_container.get_child(0).queue_free()
	await scroll_msg_container.get_v_scroll_bar().changed
	scroll_msg_container.scroll_vertical = scroll_msg_container.get_v_scroll_bar().max_value
	
func _resolve_login(data):
	session_id = data.session_id
	print("id assigned: ", session_id)
	for username in data.users:
		add_user_to_list(username)
	emit_signal("logged_in")
