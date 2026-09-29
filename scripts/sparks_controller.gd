extends Node2D

@export var spark_scene: PackedScene
@export var spark_count: int = 12

func burst() -> void:
	for i in spark_count:
		var spark = spark_scene.instantiate()
		var angle = (TAU / spark_count) * i
		spark.velocity = Vector2(cos(angle), sin(angle)) * randf_range(200, 400)
		add_child(spark)
