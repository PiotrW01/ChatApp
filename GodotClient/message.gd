class_name Message
extends PanelContainer

var username = ""
var text = ""


# Called when the node enters the scene tree for the first time.
func _ready():
	$MarginContainer/HBoxContainer/Username.text = username
	$MarginContainer/HBoxContainer/Message.text = text
	
	
