extends Node
class_name Scryfall

signal card_fetched(card_data: Dictionary)
signal image_fetched(card_data: ImageTexture)
func fetch_random_card():
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)
	http_request.request("https://api.scryfall.com/cards/random?q=f%3Av+colors%3C%3D1+is%3Aspell+-is%3Asplit+-is%3Aflip+-is%3Atransform+-is%3Ameld+-is%3Aleveler+-is%3Amdfc",
		["Accept: */*", "User-Agent: MTGCardGuessing/1"])

func _on_request_completed(_result, _response_code, _headers, body): 
	var json = JSON.parse_string(body.get_string_from_utf8())
	var croparturl = json["image_uris"]["art_crop"]
	print (croparturl)
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_image_loaded)
	http_request.request(croparturl, ["Accept: */*", "User-Agent: MTGCardGuessing/1"])
	emit_signal("card_fetched", json)
	
func _on_image_loaded(_result, _response_code, _headers, body):
	print("image loaded")
	var image = Image.new()
	var error = image.load_jpg_from_buffer(body)
	if error != OK:
		print(error);
	else:
		var texture: ImageTexture = ImageTexture.create_from_image(image)
		emit_signal("image_fetched", texture)
#http_request.request(r"https://api.scryfall.com/cards/random?q=f%3Av",["Accept: */*", "User-Agent: MTGCardGuessing/1"])
#http_request.request(r"https://api.scryfall.com/cards/named?exact=Underground%20River",["Accept: */*", "User-Agent: MTGCardGuessing/1"])
#http_request.request(r"https://api.scryfall.com/cards/named?exact=Norwood%20Riders",["Accept: */*", "User-Agent: MTGCardGuessing/1"])