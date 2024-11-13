extends VBoxContainer

@onready var scroll_container =  $".."

func _ready():
	visible = false
	_set_scroll_container_level(0)


func _on_input_text_changed(new_text: String):
	var emoji_name = new_text.split(" ")[-1]
	if (emoji_name.ends_with(":") and emoji_name.length() > 1) or emoji_name.length() == 0:
		visible = false
		_set_scroll_container_level(0)
		for child in get_children():
			child.queue_free()
		return
	if emoji_name.begins_with(":"):
		visible = true
		for child in get_children():
			child.queue_free()
		emoji_name = emoji_name.lstrip(":")
		for emoji: String in Emoji.emojis.keys():
			if emoji.begins_with(emoji_name) or emoji_name == "":
				var msg = Client.INSTANCE.messageScene.instantiate()
				msg.username = emoji
				msg.text = ":" + emoji + ":"
				add_child(msg)
				await get_tree().process_frame
				_set_scroll_container_level(get_child_count())
		return

func _set_scroll_container_level(height):
	var y_height = min(220, 60 * height)
	scroll_container.size.y = y_height
	scroll_container.position.y = -2 - y_height
