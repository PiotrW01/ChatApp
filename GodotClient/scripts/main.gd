class_name Client
extends Node2D

enum DataType {
	INIT,
	MESSAGE,
	LOGIN,
	USER_CONNECTED,
	USER_DISCONNECTED,
	CONNECTED,
	DISCONNECTED,
}

var socket = WebSocketPeer.new()
var json = JSON.new()

var session_id = ""
var username = ""
static var INSTANCE

@export var side_panel: SidePanel
@export var main_panel: MainPanel


signal connected
signal disconnected
signal logged_in(data)
signal user_connected(username)
signal user_disconnected(username)
signal message_received(data)

func _init():
	if INSTANCE == null:
		INSTANCE = self

func _ready():
	socket.handshake_headers = ['user-agent: Mozilla']
	await_connection()
	set_process(false)

func _process(delta):
	socket.poll()
	var state = socket.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count():
			var packet = socket.get_packet().get_string_from_utf8()
			var result = json.parse(packet)
			if result == OK:
				_on_data_received(json.data)
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


func _on_data_received(data):
	match data.type as DataType:
		DataType.MESSAGE:
			emit_signal("message_received", data)
		DataType.LOGIN:
			session_id = data.session_id
			emit_signal("logged_in", data)
			print("id assigned: ", session_id)
		DataType.USER_CONNECTED:
			if data.username != username:
				emit_signal("user_connected", str(data.username))
		DataType.USER_DISCONNECTED:
			emit_signal("user_disconnected", str(data.username))
		_:
			push_warning("Received invalid data type: ", data.type)
			

func await_connection():
	while true:
		await get_tree().process_frame
		if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
			emit_signal("connected")
			return
			
