class_name Emoji
extends Resource

static var emojis = {
	"godot": preload("res://emojis/icon.svg"),
	"shinobu": preload("res://emojis/shinobu.gif"),
	"sus": preload("res://emojis/sus.webp")
}

static func get_image(name: String):
	return emojis.get(name)

static func exists(name: String):
	return emojis.has(name)
