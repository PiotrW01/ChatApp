extends Node2D

var socket = WebSocketPeer.new()
const URL = "ws://localhost:3000"

func _ready():
	socket.connect_to_url(URL)

func _process(delta):
	socket.poll()
	var state = socket.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count():
			var json = JSON.parse_string(socket.get_packet().get_string_from_ascii())
			print(json)
			
			
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
	var state = socket.get_ready_state()
	if state != WebSocketPeer.STATE_CLOSED:
		return
	socket.connect_to_url(URL)
	set_process(true)
