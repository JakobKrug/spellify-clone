extends Node 
class_name ScryfallHttpRequest
var http_request
var cardname : Label
var cardtype : Label
var cardtext : Label
var cardstats : Label
var button
var manaCost
var cardtextList :VBoxContainer
var manaTextureGenerator : ManaTextureGenerator
var guessedCharacters : String

func _ready() -> void:
	cardname = $"../VBoxContainer/Card/Cardname"
	cardtype = $"../VBoxContainer/Card/Cardtype"
	cardtext = $"../VBoxContainer/Card/Cardtext"
	cardtextList = $"../VBoxContainer/Card/CardTextList"
	cardstats = $"../VBoxContainer/Card/CardPowerToughness"
	button = $"../VBoxContainer/Button"
	manaCost = $"../VBoxContainer/Card/HBoxContainer"
	manaTextureGenerator = $"./ManaTextureGenerator"
	manaTextureGenerator.manaCost = $"../VBoxContainer/Card/HBoxContainer"
	guessedCharacters = ""
	manaTextureGenerator.guessedSymbols = []
	button.pressed.connect(_get_card)

func _get_card():
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_get_callback)
	http_request.request(r"https://api.scryfall.com/cards/random?q=f%3Av",["Accept: */*", "User-Agent: MTGCardGuessing/1"])
	#http_request.request(r"https://api.scryfall.com/cards/named?exact=Underground%20River",["Accept: */*", "User-Agent: MTGCardGuessing/1"])
	#http_request.request(r"https://api.scryfall.com/cards/named?exact=Norwood%20Riders",["Accept: */*", "User-Agent: MTGCardGuessing/1"])
func _get_callback(_result, _response_code, _headers, body):
	var json : Dictionary = JSON.parse_string(body.get_string_from_utf8())
	if json.has("mana_cost"):
		manaTextureGenerator._init_card_mana(json["mana_cost"])
	if json.has("name"):
		cardname.text = _strip_characters(json["name"])
	if json.has("type_line"):
		cardtype.text = _strip_characters(json["type_line"])
	if json.has("oracle_text"):
		_fillTextField(json["oracle_text"])
		#_fillTextField("Imprint — As this Vehicle enters, exile a creature card from a graveyard.\nTap two untapped creatures you control: Until end of turn, this Vehicle becomes a copy of the exiled card, except it's a Vehicle artifact in addition to its other types.")
		#cardtext.text = _strip_characters(json["oracle_text"])
	if "Creature" in json["type_line"]:
		cardstats.show()
		cardstats.text = _strip_characters(json["power"]) + "/" + _strip_characters(json["toughness"])
	else:
		cardstats.hide()
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
	print(string)
	var regex_braces := RegEx.new()
	regex_braces.compile(r"\{.*?\}")
	var tap_symbol_string = regex_braces.sub(string, "○", -1)
	var regex := RegEx.new()
	regex.compile(r"[^\n /:?!—○,.'()"+guessedCharacters+guessedCharacters.to_upper()+"]")
	var stripped_text : String = regex.sub(tap_symbol_string, "_ ", -1)
	return stripped_text.replace("  ", "   ")

func _fillTextField(string: String):
	#print(string)
	var paragraphs: Array[Variant] = string.split("\n")
	var lines = []
	var line : String =""
	for p in paragraphs:
		var words = p.split(" ")
		for w in words:
			if line.length()+w.length() < 43:
				line+=w+" "
			else:
				lines.push_back(line)
				line = w+" "
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
	
