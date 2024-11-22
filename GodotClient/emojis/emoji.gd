class_name Emoji
extends Node

#static var emojis = {
#	"godot": preload("res://emojis/icon.svg"),
#	"shinobu": preload("res://emojis/shinobu.gif"),
#	"sus": preload("res://emojis/sus.webp")
#}
var req
static var DOWNLOADER: Emoji
static var queue = []
var http_request: HTTPRequest

# Get emoji list from server at login, then download emoji using id when needed and cache it
static var emojis = {
	#"christmas": {"id": "NTbPRYh", "texture": null},
}

func _init():
	if DOWNLOADER == null:
		DOWNLOADER = self


func _ready():
	Client.INSTANCE.logged_in.connect(func (data): 
		for emoji in data.emojis:
			var split = emoji.split(".")
			emojis[split[0]] = {"format": split[1], "texture": null}
			)
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._http_request_completed)
	

func _process(delta):
	if !queue.is_empty() and http_request.get_http_client_status() == HTTPClient.STATUS_DISCONNECTED:
		req = queue.pop_front()
		if emojis[req.emoji].texture != null:
			req.msg_ref.update_image(req.emoji, emojis.get(req.emoji))
			return
		if emojis.has(req.emoji):
			var url = "https://cdn.glitch.global/8005e491-edd8-42b3-a76b-610847e30567/"
			if emojis[req.emoji].format == "webp":
				http_request.request(url + req.emoji + ".webp")
			else:
				pass
			http_request.request(url + req.emoji + ".gif")

func _http_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	print("request!")
	if emojis[req.emoji].format == "gif":
		var gif: AnimatedTexture = GifManager.animated_texture_from_buffer(body)
		emojis[req.emoji].texture = gif
		req.msg_ref.update_image(req.emoji, gif)
	else:
		var img = Image.new()
		img.load_webp_from_buffer(body)
		var texture = ImageTexture.create_from_image(img)
		emojis[req.emoji].texture = texture
		req.msg_ref.update_image(req.emoji, texture)
	
	
static func get_image(name: String):
	return emojis.get(name).texture

static func exists(name: String):
	return emojis.has(name)

static func request_emoji(msg, emoji):
	queue.append({"msg_ref": msg, "emoji": emoji})
	
