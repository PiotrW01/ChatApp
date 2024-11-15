class_name UserDisplay
extends Control

var username = ""



# Called when the node enters the scene tree for the first time.
func _ready():
	username[0] = username[0].to_upper()
	$CenterContainer/PanelContainer/NameLabel.text = username
