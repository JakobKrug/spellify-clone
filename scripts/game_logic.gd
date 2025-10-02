extends Node
class_name GameLogic

var card_background_path = "res://cardBackgrounds/"
var guessedCharacters : String = ""
var current_card : Dictionary = {}

# Assign Nodes to Variables as soon as the Scene is ready 
@onready var scryfall: Scryfall = $"../Scryfall"
@onready var manaTextureGenerator: ManaTextureGenerator = $"../ManaTextureGenerator"
@onready var card: TextureRect = $"../VBoxContainer/Card"
@onready var cardname: Label = $"../VBoxContainer/Card/Cardname"
@onready var cardtype: Label = $"../VBoxContainer/Card/Cardtype"
@onready var cardtext: Label = $"../VBoxContainer/Card/Cardtext"
@onready var cardtextList: VBoxContainer = $"../VBoxContainer/Card/CardTextList"
@onready var cardstats: Label = $"../VBoxContainer/Card/CardPowerToughness"
@onready var button = $"../VBoxContainer/Button"
@onready var manaCost: HBoxContainer = $"../VBoxContainer/Card/HBoxContainer"
@onready var guess: LineEdit = $"../VBoxContainer/Guess"

func _ready():
	scryfall.card_fetched.connect(_get_callback)
	button.pressed.connect(_on_button_pressed)
	guess.text_submitted.connect(_on_guess)
	scryfall.fetch_random_card()

func _on_guess(guessed_char : String):
	if guessed_char not in guessedCharacters:
		guessedCharacters += guessed_char.to_lower()
	update_card_display()

func _on_button_pressed():
	scryfall.fetch_random_card()

func _get_callback(json):
	current_card = json
	update_card_display()

func update_card_display():
	if current_card.has("mana_cost"):
		manaTextureGenerator._init_card_mana(current_card["mana_cost"])
	if current_card.has("name"):
		cardname.text = _strip_characters(current_card["name"])
	if current_card.has("type_line"):
		var type : String = current_card["type_line"]
		var colors : Array = current_card["colors"] if current_card.has("colors") else []
		cardtype.text = _strip_characters(type)
		card.texture = _load_background(type, colors)
	if current_card.has("oracle_text"):
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
	var regex_braces := RegEx.new()
	regex_braces.compile(r"\{.*?\}")
	var tap_symbol_string = regex_braces.sub(string, "○", -1)
	var regex := RegEx.new()
	regex.compile(r"[^\n /:?!—○,.'()" + guessedCharacters + guessedCharacters.to_upper() + "]")
	var stripped_text : String = regex.sub(tap_symbol_string, "_ ", -1)
	return stripped_text.replace("  ", "   ")

func _fillTextField(string: String):
	var paragraphs: Array = string.split("\n")
	var lines = []
	var line : String = ""
	for p in paragraphs:
		var words = p.split(" ")
		for w in words:
			if line.length() + w.length() < 43:
				line += w + " "
			else:
				lines.push_back(line)
				line = w + " "
	if line != "":
		lines.push_back(line)
	for child in cardtextList.get_children():
		cardtextList.remove_child(child)
		child.queue_free()
	for l in lines:
		_get_textline(l)
		
func _get_textline(line: String):
	var hbox =HBoxContainer.new()
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cardtextList.add_child(hbox)
	
	var manasymbols = line.count("{")
	var unparsedLine = line
	
	for i in range(manasymbols):
		var startMana = unparsedLine.find("{")
		var endMana = unparsedLine.find("}")
		var stringInfrontofMana = unparsedLine.substr(0,startMana)
		var mana = unparsedLine.substr(startMana, endMana+1-startMana).remove_chars('{').remove_chars('}')
		unparsedLine = unparsedLine.substr(endMana+1, unparsedLine.length()-endMana-1)
		#print("start: " +str(startMana)+" ende: "+str(endMana))
		#print(stringInfrontofMana+" | "+mana+" | "+ unparsedLine)
		hbox.add_child(_get_linesegment(stringInfrontofMana, float(stringInfrontofMana.length())/line.length()))
		
		var manatex =manaTextureGenerator.get_mana_texture(mana)
		manatex.size_flags_stretch_ratio = 3./line.length()
		manatex.expand_mode = TextureRect.EXPAND_FIT_HEIGHT
		manatex.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		manatex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
		hbox.add_child(manatex)
	if unparsedLine.length() > 0:
		hbox.add_child(_get_linesegment(unparsedLine, float(unparsedLine.length())/line.length()))
	
func _get_linesegment(string: String, stretchratio:float) -> Label:
	var lineSegment = Label.new()
	lineSegment.autowrap_mode=TextServer.AUTOWRAP_WORD
	lineSegment.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lineSegment.label_settings=load("res://labelSetting.tres")
	lineSegment.text = _strip_characters(string)
	lineSegment.size_flags_stretch_ratio = stretchratio
	return lineSegment
	
