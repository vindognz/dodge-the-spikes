extends Node2D

const SUPABASE_URL="https://iouyugorzkjsugypqsan.supabase.co"
const SUPABASE_KEY="sb_publishable_pb5oBJ0UfdFDiWoVcmM7Dg_qRVDEsuj"

var running: bool = true
var score: int = 0
var highscore: int = 0
var current_player_name: String = ""

func reset() -> void:
	running = true
	score = 0

func submit_score(player_name: String, on_complete: Callable = Callable()) -> void:
	if score == 0:
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
	var js_code = """
	fetch('%s/rest/v1/rpc/get_leaderboard', {
		headers: {
			'apikey': '%s',
			'Authorization': 'Bearer %s'
		}
	})
	.then(r => r.json())
	.then(data => window.leaderboardData = data);
	""" % [SUPABASE_URL, SUPABASE_KEY, SUPABASE_KEY]
	
	JavaScriptBridge.eval(js_code)
	
	# poll for the data
	var timer = 0.0
	while timer < 5.0:
		if JavaScriptBridge.eval("typeof window.leaderboardData !== 'undefined'"):
			var data_str = JavaScriptBridge.eval("JSON.stringify(window.leaderboardData)")
			var data = JSON.parse_string(data_str)
			callback.call(data)
			return
		timer += 0.1
		await get_tree().create_timer(0.1).timeout
	
	callback.call([])
