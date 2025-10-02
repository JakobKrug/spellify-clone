extends Node
class_name Scryfall

signal card_fetched(card_data: Dictionary)

func fetch_random_card():
    var http_request = HTTPRequest.new()
    add_child(http_request)
    http_request.request_completed.connect(_on_request_completed)
    http_request.request("https://api.scryfall.com/cards/random?q=f%3Av+colors%3C%3D1+is%3Aspell+-is%3Asplit+-is%3Aflip+-is%3Atransform+-is%3Ameld+-is%3Aleveler+-is%3Amdfc",
        ["Accept: */*", "User-Agent: MTGCardGuessing/1"])

func _on_request_completed(_result, _response_code, _headers, body):
    var json = JSON.parse_string(body.get_string_from_utf8())
    emit_signal("card_fetched", json)