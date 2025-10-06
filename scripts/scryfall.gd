extends Node
class_name Scryfall

var filters : Dictionary = {
	"land": false,
	"artifact": false,
	"creature": false,
	"enchantment": false,
	"instant": false,
	"sorcery": false
}

signal card_fetched(card_data: Dictionary)


var base_query := "https://api.scryfall.com/cards/random?q=f%3Av+colors%3C%3D1"
var query : String = ""

func fetch_random_card():
	var http_request := HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)
	_build_query()
	http_request.request(query, ["Accept: */*", "User-Agent: MTGCardGuessing/1"])

func _build_query():
	var include_parts := []

	for key in filters:
		if filters[key]:
			include_parts.append("type%3A" + key)
			print(key)

	var include_query := ""
	if include_parts.size() > 0:
		include_query = "%28" + "%20OR%20".join(include_parts) + "%29"

	query = base_query
	if include_query != "":
		query += "+" + include_query

	query += "+-is%3Asplit+-is%3Aflip+-is%3Atransform+-is%3Ameld+-is%3Aleveler+-is%3Amdfc+-type%3Aplaneswalker+-type%3Asaga"

	print("Built query:", query)


func _on_request_completed(_result, _response_code, _headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	emit_signal("card_fetched", json)
