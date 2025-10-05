extends VBoxContainer

@export var scryfall : Scryfall

func _ready() -> void:
    _make_filter_button("Land")
    _make_filter_button("Artifact")
    _make_filter_button("Creature")
    _make_filter_button("Enchantment")
    _make_filter_button("Instant")
    _make_filter_button("Sorcery")

func _make_filter_button(string : String):
    var btn := CheckButton.new()
    btn.text = string
    add_child(btn)

    var key = name.to_lower()

    btn.toggled.connect(func(pressed):
        scryfall.filters[key] = pressed
        scryfall._build_query()
        print("Filter changed:", scryfall.query)
    )
