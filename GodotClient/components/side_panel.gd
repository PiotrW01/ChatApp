class_name SidePanel
extends PanelContainer

@export var user_container: VBoxContainer

static var displayedUserScene = load("res://components/displayed_user.tscn")
var userNodes = {}


func _ready():
	Client.INSTANCE.logged_in.connect(_on_login)
	Client.INSTANCE.disconnected.connect(_on_disconnected)
	Client.INSTANCE.user_connected.connect(_on_user_connected)
	Client.INSTANCE.user_disconnected.connect(_on_user_disconnected)
	
	
	
func _on_login(data):
	for user in data.users:
		display_user(str(user))
	
	
func _on_disconnected():
	clear_users()
	
func _on_user_connected(username):
	display_user(username)
	
func _on_user_disconnected(username):
	remove_user(username)
	
func display_user(username):
	if userNodes.has(username):
		return
	var new_user = displayedUserScene.instantiate()
	new_user.username = str(username)
	new_user.name = str(username)
	user_container.add_child(new_user)
	userNodes[username] = new_user
	
	
func remove_user(username):
	if userNodes.has(username):
		userNodes.get(username).queue_free()
		userNodes.erase(username)
	
	
func clear_users():
	for child in user_container.get_children():
		child.queue_free()
		userNodes.clear()
	
	
