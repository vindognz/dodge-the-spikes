extends Control

@onready var entry_list: VBoxContainer = $Panel/VBox/Scroll/EntryList
@onready var scroll: ScrollContainer = $Panel/VBox/Scroll
@onready var loading_label: Label = $Panel/VBox/LoadingLabel

var loading_timer: float = 0.0
var loading_dots: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scroll.visible = false
	loading_label.visible = true
	loading_label.text = "Loading"
	Global.fetch_leaderboard(populate)

func _process(delta: float) -> void:
	if loading_label.visible:
		loading_timer += delta
		if loading_timer >= 1.0:
			loading_timer = 0.0
			loading_dots = (loading_dots + 1) % 4
			loading_label.text = "Loading" + ".".repeat(loading_dots)

func populate(entries: Array) -> void:
	loading_label.visible = false
	scroll.visible = true
	
	for i in entries.size():
		var entry = entries[i]
		
		var row = HBoxContainer.new()
		
		var rank_label = Label.new()
		rank_label.text = str(i + 1) + "."
		rank_label.add_theme_font_size_override("font_size", 24)
		rank_label.add_theme_color_override("font_color", Color.WHITE)
		
		var name_label = Label.new()
		name_label.text = str(entry["name"])
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_label.add_theme_font_size_override("font_size", 24)
		name_label.add_theme_color_override("font_color", Color.WHITE)
		
		var score_label = Label.new()
		score_label.text = str(int(entry["score"]))
		score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		score_label.add_theme_font_size_override("font_size", 24)
		score_label.add_theme_color_override("font_color", Color.WHITE)
		
		row.add_child(rank_label)
		row.add_child(name_label)
		row.add_child(score_label)
		entry_list.add_child(row)

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")
