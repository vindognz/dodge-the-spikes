extends Node2D

@onready var level_banner: Label = $"../CanvasLayer/LevelBanner"

func _ready() -> void:
	level_banner.modulate.a = 0.0

func _process(_delta: float) -> void:
	if not Global.running or Global.in_transition:
		return
	
	if Global.spawned_this_level >= Global.SPIKES_PER_LEVEL:
		start_transition()

func start_transition() -> void:
	Global.in_transition = true
	
	# spawning has stopped, so wait for the moving spikes to skedaddle
	while get_tree().get_nodes_in_group("spikes").size() > 0:
		if not Global.running:
			return
		await get_tree().process_frame

	Global.level += 1
	Global.spawned_this_level = 0
	level_banner.text = "Level " + str(Global.level)
	
	var tween = create_tween()
	tween.tween_property(level_banner, "modulate:a", 1.0, 0.4)
	tween.tween_interval(1.2)
	tween.tween_property(level_banner, "modulate:a", 0.0, 0.4)
	await tween.finished
	
	Global.in_transition = false
