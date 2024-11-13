class_name Emoji
extends Resource

static var emoji = {
	"godot": preload("res://emojis/icon.svg"),
	"shinobu": preload("res://emojis/shinobu.gif"),
	"sus": preload("res://emojis/sus.webp")
}

static func get_image(name: String):
	return emoji.get(name)

static func exists(name: String):
	return emoji.has(name)
