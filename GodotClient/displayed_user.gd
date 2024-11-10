class_name UserDisplay
extends Control

var username = ""



# Called when the node enters the scene tree for the first time.
func _ready():
	$CenterContainer/PanelContainer/NameLabel.text = username
