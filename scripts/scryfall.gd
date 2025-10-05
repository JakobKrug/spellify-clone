extends Node
class_name Scryfall

signal card_fetched(card_data: Dictionary)

var filters := {
	"land": false,
	"artifact": false,
	"creature": false,
	"enchantment": false,
	"instant": false,
	"sorcery": false,
}

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
	var exclude_parts := []

	# whitelist of valid keys
	var valid_keys := ["land","artifact","creature","enchantment","instant","sorcery"]

	for key in valid_keys:
		if filters[key]:
			include_parts.append("is%3A" + key)   # colon encoded
		else:
			exclude_parts.append("-is%3A" + key)

	# build OR group
	var include_query := ""
	if include_parts.size() > 0:
		include_query = "%28" + "%20OR%20".join(include_parts) + "%29"  # %28 = ( , %29 = )

	# build AND group
	var exclude_query := ""
	if exclude_parts.size() > 0:
		exclude_query = "%20AND%20".join(exclude_parts)

	# combine everything with base query
	query = base_query
	if include_query != "":
		query += "+" + include_query
	if exclude_query != "":
		query += "+" + exclude_query

	# append other exclusions
	query += "+-is%3Asplit+-is%3Aflip+-is%3Atransform+-is%3Ameld+-is%3Aleveler+-is%3Amdfc+-is%3Aplaneswalker"

	print("Built query:", query)


func _on_request_completed(_result, _response_code, _headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	emit_signal("card_fetched", json)
