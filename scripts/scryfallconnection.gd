extends Node 
class_name ScryfallHttpRequest
var http_request
var cardname : Label
var cardtype : Label
var cardtext : Label
var cardstats : Label
var button
var manaCost
var manaTextureGenerator : ManaTextureGenerator

func _ready() -> void:
	cardname = $"../VBoxContainer/Card/Cardname"
	cardtype = $"../VBoxContainer/Card/Cardtype"
	cardtext = $"../VBoxContainer/Card/Cardtext"
	cardstats = $"../VBoxContainer/Card/CardPowerToughness"
	button = $"../VBoxContainer/Button"
	manaCost = $"../VBoxContainer/Card/HBoxContainer"
	manaTextureGenerator = $"./ManaTextureGenerator"
	manaTextureGenerator.manaCost = $"../VBoxContainer/Card/HBoxContainer"
	button.pressed.connect(_get_card)

func _get_card():
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_get_callback)
	http_request.request(r"https://api.scryfall.com/cards/random?q=f%3Av",["Accept: */*", "User-Agent: MTGCardGuessing/1"])

func _get_callback(_result, _response_code, _headers, body):
	var json : Dictionary = JSON.parse_string(body.get_string_from_utf8())
	if json.has("mana_cost"):
		manaTextureGenerator._init_card_mana(json["mana_cost"])
	if json.has("name"):
		cardname.text = _strip_characters(json["name"])
	if json.has("type_line"):
		cardtype.text = _strip_characters(json["type_line"])
	if json.has("oracle_text"):
		cardtext.text = _strip_characters(json["oracle_text"])
	if "Creature" in json["type_line"]:
		cardstats.show()
		cardstats.text = _strip_characters(json["power"]) + "/" + _strip_characters(json["toughness"])
	else:
		cardstats.hide()

func _strip_characters(string : String) -> String:
	print(string)
	var regex_braces := RegEx.new()
	regex_braces.compile(r"\{.*?\}")
	var tap_symbol_string = regex_braces.sub(string, "○", -1)
	var regex := RegEx.new()
	regex.compile(r"[^\n /:?!—○,.()]")
	var stripped_text : String = regex.sub(tap_symbol_string, "_ ", -1)
	return stripped_text.replace("  ", "   ")
