class_name AuthInput
extends Control

@onready var connect_button = $ConnectionInput/ConnectButton
@onready var ip_input = $ConnectionInput/IpInput
@onready var login_button = $LoginInput/LoginButton
@onready var username_input = $LoginInput/UsernameInput
@onready var disconnect_button = $DisconnectButton
var URL = ""

func _ready():
	_reset_buttons()
	ip_input.text = "globcord.glitch.me"
	Client.INSTANCE.disconnected.connect(_on_disconnect_button_down)
	Client.INSTANCE.logged_in.connect(_on_logged_in)

func _input(event):
	if Input.is_action_just_pressed("ui_text_submit"):
		if $ConnectionInput.visible and ip_input.has_focus():
			_on_connect_button_down()
		elif $LoginInput.visible and username_input.has_focus():
			_on_login_button_down()
	elif event is InputEventMouseButton and event.pressed:
		var focused = get_viewport().gui_get_focus_owner()
		if focused and focused is Control:
			if not focused.get_global_rect().has_point(get_viewport().get_mouse_position()):
				focused.release_focus()

func _on_disconnect_button_down():
	Client.INSTANCE.socket.close()
	_reset_buttons()

func _on_login_button_down():
	var username = username_input.text.strip_edges()
	if not _is_username_valid(username):
		return
	Client.INSTANCE.username = username
	username_input.text = ""
	var packet = {
		"type": Client.DataType.LOGIN,
		"username": username,
	}
	if Client.INSTANCE.socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		Client.INSTANCE.socket.send_text(JSON.stringify(packet))


func _on_connect_button_down():
	if Client.INSTANCE.socket.get_ready_state() != WebSocketPeer.STATE_CLOSED:
		return
	var ip: String = ip_input.text
	if ip.ends_with("localhost") or ip == "":
		URL = "ws://localhost:3000"
	else:
		ip = ip.trim_prefix("https://").trim_prefix("http://").trim_prefix("www.")
		URL = "wss://" + ip
	Client.INSTANCE.socket.connect_to_url(URL)
	Client.INSTANCE.set_process(true)
	
	ip_input.editable = false
	connect_button.disabled = true
	
	var start_time = Time.get_ticks_msec()
	while(true):
		await get_tree().process_frame
		if Client.INSTANCE.socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
			ip_input.text = ""
			$ConnectionInput.visible = false
			$LoginInput.visible = true
			login_button.disabled = false
			username_input.editable = true
			username_input.call_deferred("grab_focus")
			return
		if Time.get_ticks_msec() - start_time > 5000:
			Client.INSTANCE.socket.close()
			_reset_buttons()
			return



func _on_logged_in(data):
	$LoginInput.visible = false
	disconnect_button.visible = true
	disconnect_button.disabled = false


func _reset_buttons():
	disconnect_button.visible = false
	$LoginInput.visible = false
	$ConnectionInput.visible = true
	connect_button.disabled = false
	ip_input.editable = true
	ip_input.call_deferred("grab_focus")

func _is_username_valid(username):
	username = username.strip_edges()
	var ascii_username = username.to_lower().to_ascii_buffer()
	if username.length() < 4:
		push_warning("Username too short.")
		return false
	if username.length() > 16:
		push_warning("Username too long.")
		return false
	@warning_ignore("shadowed_global_identifier")
	for char in ascii_username:
		if char < 97 or char > 122:
			push_warning("Username contains spaces or invalid characters.")
			return false
	return true
