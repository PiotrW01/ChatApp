class_name Message
extends PanelContainer

@export var username = ""
@export var text = ""


# Called when the node enters the scene tree for the first time.
func _ready():
	if username:
		username[0] = username[0].to_upper()
	%Username.text = ""
	%Username.push_bold()
	%Username.append_text(username + ":")
	
	%Message.text = ""
	var words = text.split(" ")
	for word in words:
		if word.begins_with(":") and word.ends_with(":"):
			var emoji = word.trim_suffix(":").trim_prefix(":")
			var emoji_size = 30
			if words.size() == 1:
				emoji_size = 50
			if Emoji.get_image(emoji) != null:
				%Message.add_image(Emoji.get_image(emoji), 0, emoji_size)
			else:
				%Message.add_image(PlaceholderTexture2D.new(), 0, emoji_size, Color(1,1,1,1), 5, Rect2(0,0,0,0), emoji)
				Emoji.request_emoji(self, emoji)
		else:
			%Message.append_text(word + " ")
	
func update_image(id, img):
	%Message.update_image(id, RichTextLabel.UPDATE_TEXTURE, img)
