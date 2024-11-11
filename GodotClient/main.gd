extends Node2D

var messageScene = preload("res://message.tscn")
var displayedUserScene = preload("res://displayed_user.tscn")

var socket = WebSocketPeer.new()
var URL = "wss://"
var json = JSON.new()

var session_id = ""
var username = ""

@onready var user_container = %UserContainer
@onready var message_container = %MessageContainer
@onready var text_input = %TextInput

func _ready():
	socket.handshake_headers = ['user-agent: Mozilla']
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
				match data.type as DataType:
					DataType.MESSAGE:
						var message = messageScene.instantiate()
						message.username = str(data.username)
						message.text = str(data.message)
						message_container.add_child(message)
						if message_container.get_child_count() > 100:
							message_container.get_child(0).queue_free()
					DataType.LOGIN:
						$CanvasLayer/Control/LineEdit.editable = false
						$CanvasLayer/Control/login.disabled = true;
						
						session_id = data.session_id
						print("id assigned: ", session_id)
						for username in data.users:
							add_user_to_list(username)
					DataType.USER_CONNECTED:
						if data.username != username:
							add_user_to_list(str(data.username))
					DataType.USER_DISCONNECTED:
						remove_user_from_list(str(data.username))
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

func _on_message_submitted(text):
	text_input.text = ""
	var packet = {
		"type": DataType.MESSAGE,
		"session_id": session_id,
		"message": text,
	}
	socket.send_text(JSON.stringify(packet))
	


func _on_connect_button_down():
	print(socket.get_ready_state())
	if socket.get_ready_state() != WebSocketPeer.STATE_CLOSED:
		return
	URL += $CanvasLayer/Control/LineEdit2.text
	$CanvasLayer/Control/LineEdit2.text = ""
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
	


func _on_login_button_down():
	username = $CanvasLayer/Control/LineEdit.text
	$CanvasLayer/Control/LineEdit.text = ""
	var packet = {
		"type": DataType.LOGIN,
		"username": username,
	}
	socket.send_text(JSON.stringify(packet))


enum DataType{
	INIT,
	MESSAGE,
	LOGIN,
	USER_CONNECTED,
	USER_DISCONNECTED,
}


func _on_disconnect_button_down():
	socket.close()
	for child in user_container.get_children():
		child.queue_free()
	for message in message_container.get_children():
		message.queue_free()
	$CanvasLayer/Control/LineEdit.editable = true
	$CanvasLayer/Control/login.disabled = false;
