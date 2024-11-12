extends Control

@onready var disconnect = $disconnect
@onready var login = $LoginInput/login
@onready var username_input = $LoginInput/username_input
@onready var connect = $ConnectionInput/connect
@onready var ip_input = $ConnectionInput/ip_input
var URL = ""

func _ready():
	_reset_buttons()
	Client.INSTANCE.disconnected.connect(_on_disconnect_button_down)
	Client.INSTANCE.logged_in.connect(_on_logged_in)

func _on_disconnect_button_down():
	Client.INSTANCE.socket.close()
	_clear_messages()
	_clear_users()
	_reset_buttons()


func _on_login_button_down():
	Client.INSTANCE.username = username_input.text
	username_input.text = ""
	if Client.INSTANCE.username == "":
		return
	var packet = {
		"type": Client.INSTANCE.DataType.LOGIN,
		"username": Client.INSTANCE.username,
	}
	if Client.INSTANCE.socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		Client.INSTANCE.socket.send_text(JSON.stringify(packet))


func _on_connect_button_down():
	if Client.INSTANCE.socket.get_ready_state() != WebSocketPeer.STATE_CLOSED:
		return
	var ip: String = ip_input.text
	ip_input.text = ""
	if ip.ends_with("localhost") or ip == "":
		URL = "ws://localhost:3000"
	else:
		URL = "wss://" + ip
	Client.INSTANCE.socket.connect_to_url(URL)
	Client.INSTANCE.set_process(true)
	
	ip_input.editable = false
	connect.disabled = true
	
	while(true):
		await get_tree().process_frame
		if Client.INSTANCE.socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
			$ConnectionInput.visible = false
			
			$LoginInput.visible = true
			login.disabled = false
			username_input.editable = true
			return



func _on_logged_in():
	$LoginInput.visible = false
	disconnect.visible = true
	disconnect.disabled = false


func _reset_buttons():
	disconnect.visible = false
	$LoginInput.visible = false
	$ConnectionInput.visible = true
	connect.disabled = false
	ip_input.editable = true


func _clear_messages():
	for message in Client.INSTANCE.message_container.get_children():
		message.queue_free()


func _clear_users():
	for child in Client.INSTANCE.user_container.get_children():
		child.queue_free()
