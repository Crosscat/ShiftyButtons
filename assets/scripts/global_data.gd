extends Node

var easy_high_score = 0
var normal_high_score = 0
var hard_high_score = 0
var easy_high_score_timed = 0
var normal_high_score_timed = 0
var hard_high_score_timed = 0

func _ready():
	load_game()
	
func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		save_game()
		get_tree().quit()

func _save_data():
	var save_dict = {
		"easy_high_score": easy_high_score,
		"normal_high_score": normal_high_score,
		"hard_high_score": hard_high_score,
		"easy_high_score_timed": easy_high_score_timed,
		"normal_high_score_timed": normal_high_score_timed,
		"hard_high_score_timed": hard_high_score_timed,
	}
	return save_dict

func save_game():
	var save_game = File.new()
	save_game.open("user://savegame.save", File.WRITE)
	print(_save_data())
	save_game.store_line(to_json(_save_data()))
	save_game.close()

func load_game():
	var save_game = File.new()
	if not save_game.file_exists("user://savegame.save"):
		return
		
	save_game.open("user://savegame.save", File.READ)
	while save_game.get_position() < save_game.get_len():
		var node_data = parse_json(save_game.get_line())
		
		easy_high_score = node_data["easy_high_score"]
		normal_high_score = node_data["normal_high_score"]
		hard_high_score = node_data["hard_high_score"]
		easy_high_score_timed = node_data["easy_high_score_timed"]
		normal_high_score_timed = node_data["normal_high_score_timed"]
		hard_high_score_timed = node_data["hard_high_score_timed"]

	save_game.close()
