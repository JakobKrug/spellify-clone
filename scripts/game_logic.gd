extends Node
class_name GameLogic

var scryfall : Scryfall
var manaTextureGenerator: ManaTextureGenerator
var card : TextureRect
var cardname : Label
var cardtype : Label
var cardtext : Label
var cardstats : Label
var guess : LineEdit
var button
var manaCost
var card_background_path = "res://cardBackgrounds/"

func _ready():
	scryfall = $"../Scryfall"
	manaTextureGenerator = $"../ManaTextureGenerator"
	card = $"../VBoxContainer/Card"
	cardname = $"../VBoxContainer/Card/Cardname"
	cardtype = $"../VBoxContainer/Card/Cardtype"
	cardtext = $"../VBoxContainer/Card/Cardtext"
	cardstats = $"../VBoxContainer/Card/CardPowerToughness"
	button = $"../VBoxContainer/Button"
	manaCost = $"../VBoxContainer/Card/HBoxContainer"
	guess = $"../VBoxContainer/Guess"
	manaTextureGenerator.manaCost = manaCost
	scryfall.card_fetched.connect(_on_card_fetched)
	button.pressed.connect(_on_button_pressed)
	guess.text_submitted.connect(_on_guess)

func _on_guess(guessed_char : String):
	print("Character guessed: " + guessed_char)

func _on_button_pressed():
	scryfall.fetch_random_card()

func _on_card_fetched(json : Dictionary):
	if json.has("mana_cost"):
		manaTextureGenerator._init_card_mana(json["mana_cost"])
	if json.has("name"):
		cardname.text = _strip_characters(json["name"])
	if json.has("type_line"):
		var type : String = json["type_line"]
		var colors : Array = json["colors"]
		cardtype.text = _strip_characters(type)
		var suffix := "-creature.png" if "Creature" in type else "-noncreature.png"
		var color_map = {
			"W" : "white",
			"U" : "blue",
			"B" : "black",
			"R" : "red",
			"G" : "green"
		}
		var color = color_map.get(colors[0], "colorless") if colors.size() > 0 else "colorless"
		card.texture = load(card_background_path + color + suffix)
	if json.has("oracle_text"):
		cardtext.text = _strip_characters(json["oracle_text"])
	if "Creature" in json["type_line"]:
		cardstats.show()
		cardstats.text = _strip_characters(json["power"]) + "/" + _strip_characters(json["toughness"])
	else:
		cardstats.hide()

func _strip_characters(string : String) -> String:
	var regex_braces := RegEx.new()
	regex_braces.compile(r"\{.*?\}")
	var tap_symbol_string = regex_braces.sub(string, "○", -1)
	var regex := RegEx.new()
	regex.compile(r"[^\n /:?!—○,.()]")
	var stripped_text : String = regex.sub(tap_symbol_string, "_ ", -1)
	return stripped_text.replace("  ", "   ")
