extends Node2D

@onready var game_over_screen: Control = $CanvasLayer/GameOverScreen
@onready var leaderboard: Control = $CanvasLayer/GameOverScreen/Leaderboard
@onready var name_prompt: Control = $CanvasLayer/GameOverScreen/NamePrompt
@onready var name_input: LineEdit = $CanvasLayer/GameOverScreen/NamePrompt/NameInput
@onready var confirm_name_button: Button = $CanvasLayer/GameOverScreen/NamePrompt/ConfirmNameButton
@onready var score_label: Label = $CanvasLayer/HUD/ScoreLabel
@onready var player: CharacterBody2D = $Player

var game_over_triggered: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_over_screen.visible = false
	leaderboard.visible = false
	name_prompt.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not Global.running:
		if not game_over_triggered:
			game_over_triggered = true
			game_over_screen.visible = true
			on_game_over()
	else:
		score_label.text = "Score: " + str(Global.score)
		Global.highscore = max(Global.score, Global.highscore)

func on_game_over() -> void:
	if Global.current_player_name == "":
		name_prompt.visible = true
		leaderboard.visible = false
	else:
		name_prompt.visible = false
		leaderboard.visible = true
		
		Global.submit_score(
			Global.current_player_name,
			func():
				if is_instance_valid(leaderboard):
					Global.fetch_leaderboard(leaderboard.populate)
		)

func _on_play_again_button_pressed() -> void:
	Global.reset()
	get_tree().reload_current_scene()

func _on_confirm_name_button_pressed() -> void:
	var name_text = name_input.text.strip_edges()
	if name_text == "":
		name_text = "Anonymous"
	
	Global.current_player_name = name_text
	name_prompt.visible = false
	leaderboard.visible = true
	
	Global.submit_score(
		Global.current_player_name,
		func():
			if is_instance_valid(leaderboard):
				Global.fetch_leaderboard(leaderboard.populate)
	)
