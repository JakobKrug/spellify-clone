extends Node
class_name GameLogic

var card_background_path = "res://cardBackgrounds/"
var guessedCharacters : Array = []
var current_card : Dictionary = {}
var font_size : int = 14
var revealed : bool = false
var always_revealed_characters = "—():,."

@export var keyboard : Keyboard

# Assign Nodes to Variables as soon as the Scene is ready 
@onready var scryfall: Scryfall = $"../Scryfall"
@onready var card: TextureRect = $"../VBoxContainer/CentralContainer/Card"
@onready var cardname: Label = $"../VBoxContainer/CentralContainer/Card/Cardname"
@onready var manacost: RichTextLabel = $"../VBoxContainer/CentralContainer/Card/ManaCost"
@onready var cardtype: Label = $"../VBoxContainer/CentralContainer/Card/Cardtype"
@onready var cardtext: RichTextLabel = $"../VBoxContainer/CentralContainer/Card/OracleText"
@onready var cardstats: Label = $"../VBoxContainer/CentralContainer/Card/CardPowerToughness"
@onready var new_card = $"../VBoxContainer/Settings/NewCard"
@onready var reveal = $"../VBoxContainer/Settings/Revealed"
@onready var guess: LineEdit = $"../VBoxContainer/Guess"

func _ready():
	scryfall.card_fetched.connect(_on_card_fetched)
	new_card.pressed.connect(_on_button_pressed)
	guess.text_submitted.connect(_on_guess)
	scryfall.fetch_random_card()
	keyboard.key_pressed.connect(_on_key_pressed)

func _on_key_pressed(key_value: String):
	guessedCharacters.append(key_value)
	update_card_display()

func _on_guess(guessed_char : String):
	if guessed_char not in guessedCharacters:
		guessedCharacters.append(guessed_char.to_lower())
		guessedCharacters.append(guessed_char.to_upper())
	update_card_display()

func _on_button_pressed():
	revealed = false
	scryfall.fetch_random_card()

func _on_card_fetched(json):
	font_size = 14
	current_card = json
	guessedCharacters = []
	update_card_display()

func update_card_display():
	if current_card.has("mana_cost"):
		_fill_mana_cost(current_card["mana_cost"])
	if current_card.has("name"):
		cardname.text = _strip_characters(current_card["name"])
	if current_card.has("type_line"):
		var type : String = current_card["type_line"]
		var colors : Array = current_card["colors"] if current_card.has("colors") else []
		card.texture = _load_background(type, colors)
		cardtype.text = _strip_characters(type)
	if current_card.has("oracle_text"):
		_fill_text_field(current_card["oracle_text"])
	if current_card.has("type_line") and "Creature" in current_card["type_line"]:
		cardstats.show()
		cardstats.text = _strip_characters(current_card.get("power", "")) + "/" + _strip_characters(current_card.get("toughness", ""))
	else:
		cardstats.hide()
	guess.placeholder_text = "Guess:"
	guess.text = ""
	guess.grab_focus()
	print(guessedCharacters)

func _get_color_from_array(colors: Array) -> String:
	var color_map = {
		"W" : "white",
		"U" : "blue",
		"B" : "black",
		"R" : "red",
		"G" : "green"
	}
	if colors.size() > 0 and color_map.has(colors[0]):
		return color_map[colors[0]]
	return "colorless"

func _load_background(type: String, colors: Array) -> Texture2D:
	var suffix := "-creature.png" if "Creature" in type else "-noncreature.png"
	var color = _get_color_from_array(colors)
	return load(card_background_path + color + suffix)

func _fill_mana_cost(string : String):
	var matches = string.split("{")
	var bbcode_text = matches[0]

	for i in range(1, matches.size()):
		var part = matches[i]
		if part.find("}") != -1:
			var symbol = part.substr(0, part.find("}"))
			var rest = part.substr(part.find("}") + 1)
			if revealed or "{" + symbol + "}" in guessedCharacters:
				bbcode_text += "[img width=16 height=16]res://manaSymbols/%s.webp[/img]" % symbol + rest
			else:
				bbcode_text += "[img width=16 height=16]res://manaSymbols/_.png[/img]" + rest
	if not string == "":
		manacost.show()
		manacost.bbcode_text = bbcode_text
	else:
		manacost.hide()

func _fill_text_field(string : String):
	cardtext.size_flags_horizontal = Control.SIZE_FILL
	cardtext.size_flags_vertical = Control.SIZE_FILL

	var text = _strip_characters(string)
	if revealed:
		text = string
	var matches = text.split("{")
	var bbcode_text = matches[0]

	for i in range(1, matches.size()):
		var part = matches[i]
		if part.find("}") != -1:
			var symbol = part.substr(0, part.find("}"))
			var rest = part.substr(part.find("}") + 1)
			if revealed or "{" + symbol + "}" in guessedCharacters:
				bbcode_text += "[img width=font-size height=font-size]res://manaSymbols/%s.webp[/img]" % symbol + rest
			else:
				bbcode_text += "[img width=font-size height=font-size]res://manaSymbols/_.png[/img]" + rest
		else:
			bbcode_text += "{" + part

	cardtext.bbcode_text = ("[font_size=font-size]" + bbcode_text + "[/font_size]").replace("font-size", str(font_size))
	while cardtext.get_content_height() > 159.0:
		if font_size <= 9:
			break
		font_size = font_size - 1
		cardtext.bbcode_text = ("[font_size=font-size]" + bbcode_text + "[/font_size]").replace("font-size", str(font_size))

func _on_revealed_pressed() -> void:
	font_size = 14
	revealed = !revealed
	update_card_display()

func _strip_characters(string : String) -> String:
	var stripped_text : String = ""
	var regex := RegEx.new()
	regex.compile(r"\{[^}]*\}|\\n|\n|\t| |.")
	for match in regex.search_all(string):
		var m : String = match.get_string()
		if m == " " or m == "\n":
			stripped_text += m
		elif m.begins_with("{") and m.ends_with("}") or m in guessedCharacters or m in always_revealed_characters:
			stripped_text += m
		else:
			stripped_text += "_"
	if revealed:
		return string
	else:
		return stripped_text
