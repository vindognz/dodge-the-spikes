extends Node2D

const SUPABASE_URL="https://iouyugorzkjsugypqsan.supabase.co"
const SUPABASE_KEY="sb_publishable_pb5oBJ0UfdFDiWoVcmM7Dg_qRVDEsuj"

const SPIKES_PER_LEVEL = 10

var level: int = 1
var score: int = 0
var highscore: int = 0
var spawned_this_level: int = 0

var running: bool = true
var in_transition: bool = false
var mute_sfx: bool = false

var current_player_name: String = ""

func reset() -> void:
	running = true
	in_transition = false
	score = 0
	spawned_this_level = 0
	level = 1

func submit_score(player_name: String, on_complete: Callable = Callable()) -> void:
	if score == 0:
		if on_complete.is_valid():
			on_complete.call()
		return
	
	var http = HTTPRequest.new()
	get_tree().root.add_child(http)
	
	var url = SUPABASE_URL + "/rest/v1/leaderboard"
	var headers = [
		"Content-Type: application/json",
		"apikey: " + SUPABASE_KEY,
		"Authorization: Bearer " + SUPABASE_KEY
	]
	var body = JSON.stringify({
		"name": player_name,
		"score": score
	})
	
	var error = http.request(url, headers, HTTPClient.METHOD_POST, body)
	
	if error != OK:
		print("HTTP request failed to start: ", error)
		http.queue_free()
		if on_complete.is_valid():
			on_complete.call()
		return
	
	http.request_completed.connect(
		func(_result, code, _headers, _body):
			if code == 201:
				print("Score submitted!")
			else:
				print("Submit failed: ", code)
			http.queue_free()
			
			if on_complete.is_valid():
				on_complete.call()
	)

func fetch_leaderboard(callback: Callable) -> void:
	if OS.has_feature("web"):
		_fetch_leaderboard_web(callback)
	else:
		_fetch_leaderboard_http(callback)

func _fetch_leaderboard_http(callback: Callable) -> void:
	var http = HTTPRequest.new()
	get_tree().root.add_child(http)
	
	var url = SUPABASE_URL + "/rest/v1/rpc/get_leaderboard"
	var headers = [
		"apikey: " + SUPABASE_KEY,
		"Authorization: Bearer " + SUPABASE_KEY
	]
	http.request(url, headers, HTTPClient.METHOD_GET)
	http.request_completed.connect(func(_result, code, _headers, body):
		if code == 200 and callback.is_valid():
			callback.call(JSON.parse_string(body.get_string_from_utf8()))
		else:
			print("Fetch failed: ", code)
		http.queue_free()
	)

func _fetch_leaderboard_web(callback: Callable) -> void:
	# reset first, otherwise the poll sees stale data from the previous fetch
	JavaScriptBridge.eval("window.leaderboardData = undefined;")
	JavaScriptBridge.eval("""
	fetch('%s/rest/v1/rpc/get_leaderboard', {
		cache: 'no-store',
		headers: {
			'apikey': '%s',
			'Authorization': 'Bearer %s'
		}
	})
	.then(r => r.json())
	.then(data => window.leaderboardData = data)
	.catch(e => window.leaderboardData = []);
	""" % [SUPABASE_URL, SUPABASE_KEY, SUPABASE_KEY])
	
	var timer = 0.0
	while timer < 5.0:
		if JavaScriptBridge.eval("typeof window.leaderboardData !== 'undefined'"):
			var data = JSON.parse_string(JavaScriptBridge.eval("JSON.stringify(window.leaderboardData)"))
			if callback.is_valid():
				callback.call(data)
			return
		timer += 0.1
		await get_tree().create_timer(0.1).timeout
	
	if callback.is_valid():
		callback.call([])
