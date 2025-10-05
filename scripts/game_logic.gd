extends Node
class_name GameLogic

var card_background_path = "res://cardBackgrounds/"
var guessedCharacters : String = " "
var current_card : Dictionary = {}
var font_size : int = 20
var revealed : bool = false

# Assign Nodes to Variables as soon as the Scene is ready 
@onready var scryfall: Scryfall = $"../Scryfall"
@onready var manaTextureGenerator: ManaTextureGenerator = $"../ManaTextureGenerator"
@onready var card: TextureRect = $"../VBoxContainer/CentralContainer/Card"
@onready var cardname: Label = $"../VBoxContainer/CentralContainer/Card/Cardname"
@onready var manaCost: HBoxContainer = $"../VBoxContainer/CentralContainer/Card/HBoxContainer"
@onready var cardtype: Label = $"../VBoxContainer/CentralContainer/Card/Cardtype"
@onready var cardtext: RichTextLabel = $"../VBoxContainer/CentralContainer/Card/OracleText"
@onready var cardstats: Label = $"../VBoxContainer/CentralContainer/Card/CardPowerToughness"
@onready var new_card = $"../VBoxContainer/Settings/NewCard"
@onready var reveal = $"../VBoxContainer/Settings/Revealed"
@onready var guess: LineEdit = $"../VBoxContainer/Guess"

func _ready():
	manaTextureGenerator.manaCost = manaCost
	scryfall.card_fetched.connect(_get_callback)
	new_card.pressed.connect(_on_button_pressed)
	guess.text_submitted.connect(_on_guess)
	scryfall.fetch_random_card()

func _on_guess(guessed_char : String):
	if guessed_char not in guessedCharacters:
		guessedCharacters += guessed_char.to_lower()
	update_card_display()

func _on_button_pressed():
	revealed = false
	scryfall.fetch_random_card()

func _get_callback(json):
	current_card = json
	print(current_card)
	update_card_display()

func update_card_display():
	if current_card.has("mana_cost"):
		if revealed:
			manaTextureGenerator._init_card_mana(current_card["mana_cost"])
		else: 
			manaTextureGenerator._init_card_mana(current_card["mana_cost"])
	if current_card.has("name"):
		if revealed:
			cardname.text = current_card["name"]
		else:
			cardname.text = _strip_characters(current_card["name"])
	if current_card.has("type_line"):
		var type : String = current_card["type_line"]
		var colors : Array = current_card["colors"] if current_card.has("colors") else []
		card.texture = _load_background(type, colors)
		if revealed:
			cardtype.text = type
		else:
			cardtype.text = _strip_characters(type)
	if current_card.has("oracle_text"):
		print(current_card["oracle_text"])
		_fillTextField(current_card["oracle_text"])
	if current_card.has("type_line") and "Creature" in current_card["type_line"]:
		cardstats.show()
		cardstats.text = _strip_characters(current_card.get("power", "")) + "/" + _strip_characters(current_card.get("toughness", ""))
	else:
		cardstats.hide()
	guess.placeholder_text = "Guess:"
	guess.text = ""
	guess.grab_focus()

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
#Idee: man könnte die Einzelnen Zeilen in VBoxen packen und dann immer wenn ein Mana element kommt dann ein HBox einfügen
#
#
#   ------------------------
#   | texttexttexttexttext |
#   ------------------------
#   | text|   |texttexttex | <- hier ist eine Hbox zeile mit "Lücke" für das mana
#   ------------------------
#   | texttexttexttexttext |  
#   ------------------------
#
func _strip_characters(string : String) -> String:
	var stripped_text : String = ""
	var regex := RegEx.new()
	regex.compile(r"\{[^}]*\}|\\n|\n|\t| |.")
	for match in regex.search_all(string):
		var m : String = match.get_string()
		if m == " " or m == "\n":
			stripped_text += m
		elif m.begins_with("{") and m.ends_with("}") or m in guessedCharacters:
			stripped_text += m
		else:
			stripped_text += "_"
	return stripped_text

func _fillTextField(string : String):
	cardtext.size_flags_horizontal = Control.SIZE_FILL
	cardtext.size_flags_vertical = Control.SIZE_FILL

	# Convert oracle text to BBCode with mana symbols
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
			# Insert image with width and height relative to font
			bbcode_text += "[img width=16 height=16]res://manaSymbols/%s.webp[/img]" % symbol + rest
		else:
			bbcode_text += "{" + part

	cardtext.bbcode_text = bbcode_text
	# await Engine.get_main_loop().process_frame
	# cardtext.push_font_size(20)
	# print(cardtext.get_visible_line_count())


func _on_revealed_pressed() -> void:
	revealed = !revealed
	update_card_display()
