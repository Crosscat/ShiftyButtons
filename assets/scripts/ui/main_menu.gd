extends Node

func _ready():
	$GameTypeDropdown.select(GlobalSettings.game_type)
	$DifficultyDropdown.select(GlobalSettings.difficulty)
	
	$EasyModeHighScore.text = "Easy: " + str(Global.easy_high_score)
	$NormalModeHighScore.text = "Normal: " + str(Global.normal_high_score)
	$HardModeHighScore.text = "Hard: " + str(Global.hard_high_score)
	
	$EasyModeHighScoreTimed.text = "Easy: " + str(Global.easy_high_score_timed)
	$NormalModeHighScoreTimed.text = "Normal: " + str(Global.normal_high_score_timed)
	$HardModeHighScoreTimed.text = "Hard: " + str(Global.hard_high_score_timed)
