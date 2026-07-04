extends Node2D

@onready var game_over_screen: Node2D = $CanvasLayer/GameOverScreen
@onready var game_over_score_label: Label = $CanvasLayer/GameOverScreen/ScoreLabel
@onready var score_label: Label = $CanvasLayer/HUD/ScoreLabel
@onready var player: CharacterBody2D = $Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_over_screen.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not Global.running:
		game_over_screen.visible = true
		game_over_score_label.text = "Your score was " + str(Global.score)
	else:
		score_label.text = "Score: " + str(Global.score)
		Global.highscore = max(Global.score, Global.highscore)

func _on_play_again_button_pressed() -> void:
	get_tree().reload_current_scene()
	Global.reset()

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_submit_score_button_pressed() -> void:
	Global.submit_score("test")

func _on_leaderboard_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/leaderboard.tscn")
