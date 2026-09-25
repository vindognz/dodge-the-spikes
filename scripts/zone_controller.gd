extends Node2D

const COL_BOUNDARIES = [
	[-144.0, -48.0],
	[-48.0, 48.0],
	[48.0, 144.0]
]

const ZONE_WARN_TIME = 3.0
const ZONE_FAST_FLASH_TIME = 1.0
const CHECK_INTERVAL = 10.0
const TRIGGER_CHANCE = 0.45
const PLAYER_COL_BIAS = 0.65

var check_timer: float = 0.0
var active_zones: Array = []

@onready var player = get_parent().get_node("Player")

func _draw() -> void:
	for zone in active_zones:
		var col = COL_BOUNDARIES[zone.col]
		var x = col[0]
		var w = col[1] - col[0]
		
		if zone.phase == "warn":
			var in_fast = zone.timer > ZONE_WARN_TIME - ZONE_FAST_FLASH_TIME
			var flash_rate = 0.08 if in_fast else 0.3
			var flash_on = fmod(zone.timer, flash_rate * 2) < flash_rate
			var alpha = 0.55 if (flash_on and in_fast) else (0.3 if flash_on else 0.05)
			
			draw_rect(Rect2(x, -162, w, 162), Color(1, 0.1, 0.1, alpha))
			draw_rect(Rect2(x, -162, w, 162), Color(1, 0.2, 0.2, 0.8), false, 1.5)
		
		elif zone.phase == "collapse":
			var t = zone.timer / 0.5
			var h = 162 * (1.0 - t)
			var mid_y = -162 / 2.0
			draw_rect(Rect2(x, mid_y - h / 2.0, w, h), Color(1, 0.1, 0.1, 0.6 * (1.0 - t)))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not Global.running: return
	if Global.score < 10: return
	
	check_timer += delta
	if check_timer >= CHECK_INTERVAL:
		check_timer = 0.0
		maybe_spawn_zone()
	
	for zone in active_zones:
		zone.timer += delta
		if zone.phase == "warn" and zone.timer >= ZONE_WARN_TIME:
			# check if the player is in the zone
			var col = COL_BOUNDARIES[zone.col]
			if player.position.x >= col[0] and player.position.x < col[1]:
				Global.running = false
			zone.phase = "collapse"
			zone.timer = 0.0
	
	active_zones = active_zones.filter(func(z): return not (z.phase == "collapse" and z.timer >= 0.5))
	queue_redraw()

func get_player_col() -> int:
	var px = player.position.x
	
	for i in 3:
		if px >= COL_BOUNDARIES[i][0] and px < COL_BOUNDARIES[i][1]:
			return i
			
	return 1

func maybe_spawn_zone() -> void:
	if randf() > TRIGGER_CHANCE: return
	
	var count = 2 if Global.score >= 30 else 1
	var picks = pick_cols(count)
	
	for col in picks:
		active_zones.append({
			"col": col,
			"timer": 0.0,
			"phase": "warn"
		})

func pick_cols(count: int) -> Array:
	var player_col = get_player_col()
	var picks = []
	
	for i in count:
		if picks.size() == 0 and randf() < PLAYER_COL_BIAS:
			picks.append(player_col)
		else:
			var pool = [0, 1, 2].filter(func(c): return not picks.has(c))
			picks.append(pool[randi() % pool.size()])
			
	return picks
			
			
			
