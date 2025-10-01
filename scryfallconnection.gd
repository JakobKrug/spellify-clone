extends Node 
class_name ScryfallHttpRequest
var http_request
var cardtext
var cardname
var button
var manaCost

func _ready() -> void:
	cardtext = $"../VBoxContainer/Card/Cardtext"
	cardname = $"../VBoxContainer/Card/Cardname"
	button = $"../VBoxContainer/Button"
	manaCost = $"../VBoxContainer/Card/HBoxContainer"
	button.pressed.connect(_get_card)

func _get_card():
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_get_callback)
	http_request.request("https://api.scryfall.com/cards/random",["Accept: */*", "User-Agent: MTGCardGuessing/1"])

func _get_callback(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	cardname.text = (json["name"])
	#label.text = body.get_string_from_utf8()
	print(body.get_string_from_utf8())
