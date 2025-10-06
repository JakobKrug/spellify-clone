extends Control
class_name Keyboard

var image_folder : String = "res://manaSymbols/"
var hidden_mana_symbols : Array = [
	"_.png"
]
@export var game_logic : GameLogic
@export var keyboard_container : GridContainer

signal key_pressed(key_value: String)

func _ready():
	_load_keyboard_images()

func _load_keyboard_images():
	var dir = DirAccess.open(image_folder)
	if dir == null:
		print("Failed to open folder: ", image_folder)
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and (file_name.ends_with(".png") or file_name.ends_with(".webp")) and not file_name in hidden_mana_symbols:
			_create_key_button(file_name)
		file_name = dir.get_next()
	dir.list_dir_end()

func _create_key_button(file_name: String):
	var button = TextureButton.new()
	var texture = load(image_folder + file_name) as Texture2D
	if texture:
		button.texture_normal = texture
	
	var key_value = "{" + file_name.get_basename().to_upper() + "}"
	button.pressed.connect(Callable(self, "_emit_key_pressed").bind(key_value))
	
	button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	button.size_flags_horizontal = TextureButton.SIZE_EXPAND_FILL
	button.size_flags_vertical = TextureButton.SIZE_EXPAND_FILL
	button.ignore_texture_size = true
	keyboard_container.add_child(button)

func _emit_key_pressed(key_value: String):
	emit_signal("key_pressed", key_value)
	print("Emitted key_pressed signal: ", key_value)
