extends Node2D

var messageScene = preload("res://message.tscn")
var displayedUserScene = preload("res://displayed_user.tscn")

var socket = WebSocketPeer.new()
const URL = "ws://localhost:3000"
var json = JSON.new()

var session_id = ""

@onready var user_container = %UserContainer
@onready var message_container = %MessageContainer
@onready var text_input = %TextInput

func _ready():
	set_process(false)

func _process(delta):
	socket.poll()
	var state = socket.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count():
			
			var packet = socket.get_packet().get_string_from_ascii()
			var result = json.parse(packet)
			if result == OK:
				var data = json.data
				match data.type:
					"message":
						var message = messageScene.instantiate()
						message.username = str(data.username)
						message.text = str(data.message)
						message_container.add_child(message)
						if message_container.get_child_count() > 100:
							message_container.get_child(0).queue_free()
					"initialize":
						session_id = data.session_id
						print("id assigned: ", session_id)
						for username in data.users:
							add_user_to_list(username)
					"user_connected":
						add_user_to_list(str(data.session_id))
					"user_disconnected":
						remove_user_from_list(str(data.session_id))
						
					_:
						push_warning("Received invalid data type: ", data.type)
						
			else:
				print(packet)
			
	elif state == WebSocketPeer.STATE_CLOSING:
		pass
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = socket.get_close_code()
		var reason = socket.get_close_reason()
		print("Websocket closed with code: %d, reason: %s" % [code, reason])
		set_process(false)


func _on_button_down():
	var array = PackedByteArray()
	var val = 0x89
	array.append(val)
	array.append(0x00)
	socket.put_packet(array)
	#socket.send_text("message 9423")


func _on_reconnect_button_down():
	socket.close()
	for child in user_container.get_children():
		child.queue_free()
	for message in message_container.get_children():
		message.queue_free()

func _on_message_submitted(text):
	text_input.text = ""
	var packet = {
		"type": "message",
		"session_id": session_id,
		"message": text,
	}
	socket.send_text(JSON.stringify(packet))
	


func _on_connect_button_down():
	print(socket.get_ready_state())
	if socket.get_ready_state() != WebSocketPeer.STATE_CLOSED:
		return
	socket.connect_to_url(URL)
	set_process(true)


func add_user_to_list(username):
	var new_user = displayedUserScene.instantiate()
	new_user.username = str(username)
	new_user.name = str(username)
	user_container.add_child(new_user)

func remove_user_from_list(username):
	for child in user_container.get_children():
		if child.name == username:
			child.queue_free()
	
	
	
