extends Node2D

const SUPABASE_URL="https://iouyugorzkjsugypqsan.supabase.co"
const SUPABASE_KEY="sb_publishable_pb5oBJ0UfdFDiWoVcmM7Dg_qRVDEsuj"

var running: bool = true
var score: int = 0
var highscore: int = 0

func reset() -> void:
	running = true
	score = 0

func submit_score(player_name: String) -> void:
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
	
	http.request(url, headers, HTTPClient.METHOD_POST, body)
	http.request_completed.connect(func(result, code, _headers, _body):
		if code == 201:
			print("Score submitted!")
		else:
			print("Submit failed: ", code)
		http.queue_free()
	)

func fetch_leaderboard(callback: Callable) -> void:
	var http = HTTPRequest.new()
	get_tree().root.add_child(http)
	
	var url = SUPABASE_URL + "/rest/v1/rpc/get_leaderboard"
	var headers = [
		"apikey: " + SUPABASE_KEY,
		"Authorization: Bearer " + SUPABASE_KEY
	]
	http.request(url, headers, HTTPClient.METHOD_GET)
	http.request_completed.connect(func(result, code, _headers, body):
		if code == 200:
			var json = JSON.parse_string(body.get_string_from_utf8())
			callback.call(json)
		else:
			print("Fetch failed: ", code)
		http.queue_free()
	)
