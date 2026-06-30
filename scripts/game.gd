extends Node2D

@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var score_label: Label = $CanvasLayer/ScoreLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	canvas_layer.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not Global.running:
		canvas_layer.visible = true

func _on_canvas_layer_visibility_changed() -> void:
	score_label.text = "Your score was " + str(Global.score)
