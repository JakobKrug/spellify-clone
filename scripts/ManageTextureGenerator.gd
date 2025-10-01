extends Node 
class_name ManageTextureGenerator
var http_request
var cardtext : Label
var cardname : Label
var button	 : Button
var manaCost : HBoxContainer
const manaScene: PackedScene   = preload("res://scenes/mana.tscn")
var colorToTexture: Dictionary ={
	"R": "res://manaSymbols/R.webp",
	"G": "res://manaSymbols/G.webp",
	"U": "res://manaSymbols/U.webp",
	"W": "res://manaSymbols/W.webp",
	"B": "res://manaSymbols/B.webp",
	"1" : "res://manaSymbols/1.webp",
	"2" : "res://manaSymbols/2.webp",
	"3" : "res://manaSymbols/3.webp",
	"4" : "res://manaSymbols/4.webp", 
	"5" : "res://manaSymbols/5.webp", 
	"6" : "res://manaSymbols/6.webp",
	"7" : "res://manaSymbols/7.webp",
	"8" : "res://manaSymbols/8.webp",
	"9" : "res://manaSymbols/9.webp",
	"11" : "res://manaSymbols/11.webp",
	"12" : "res://manaSymbols/12.webp",
	"13" : "res://manaSymbols/13.webp",
	"14" : "res://manaSymbols/14.webp",
	"15" : "res://manaSymbols/15.webp",
	"16" : "res://manaSymbols/16.webp",
	"17" : "res://manaSymbols/17.webp",
	"18" : "res://manaSymbols/18.webp",
	"19" : "res://manaSymbols/19.webp",
	"20" : "res://manaSymbols/20.webp", 
	"X"  : "res://manaSymbols/20.webp"}
func _ready() -> void:
	cardtext = $"../VBoxContainer/Card/Cardtext"
	cardname = $"../VBoxContainer/Card/Cardname"
	button = $"../VBoxContainer/Button"
	manaCost = $"../VBoxContainer/Card/HBoxContainer"
	button.pressed.connect(_get_card)

func _init_card_mana(manaText : String):
	var regex := RegEx.new()
	regex.compile("\\{.*?\\}")
	var results: Array[Variant] = []
	for result in regex.search_all(manaText):
		results.push_front(result.get_string().remove_chars('{').remove_chars('}'))
	for child in manaCost.get_children():
		manaCost.remove_child(child)
	for r in results:
		manaCost.add_child(get_mana_texture(r))
	
func get_mana_texture(manaText : String)->TextureRect:
	var mana = manaScene.instantiate() as TextureRect
	mana.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	mana.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT 
	if(colorToTexture.has(manaText)):
		mana.texture = load(colorToTexture[manaText])
	else:
		mana.texture = load("res://icon.svg")
		print("keine Textur gefunden zu "+manaText)
	return mana

func _get_card():
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_card_loaded)
	http_request.request("https://api.scryfall.com/cards/random",["Accept: */*", "User-Agent: MTGCardGuessing/1"])

func _card_loaded(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	cardname.text = (json["name"])
	if json.has("mana_cost"):
		_init_card_mana(json["mana_cost"])
	#label.text = body.get_string_from_utf8()
	#print(json["mana_cost"])
