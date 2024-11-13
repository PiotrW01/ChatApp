class_name Message
extends PanelContainer

var username = ""
var text = ""


# Called when the node enters the scene tree for the first time.
func _ready():
	username[0] = username[0].to_upper()
	%Username.text = ""
	%Username.push_bold()
	%Username.append_text(username + ":")
	
	%Message.text = ""
	var words = text.split(" ")
	for word in words:
		if word.begins_with(":") and word.ends_with(":"):
			var emoji_name = word.trim_suffix(":").trim_prefix(":")
			var emoji_size = 30
			if words.size() == 1:
				emoji_size = 50
			if Emoji.exists(emoji_name):
				%Message.add_image(Emoji.get_image(emoji_name), 0, emoji_size)
		else:
			%Message.append_text(word + " ")
	
	
	
	
	
