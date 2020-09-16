extends Node

const ButtonColor = preload("consts/button_color.gd")
const Difficulty = preload("consts/difficulty.gd")
const GameType = preload("consts/game_type.gd")
const Solutions = preload("solutions.gd")

var clickable = true
var _finished = false

var _rng = RandomNumberGenerator.new()
var _solution = []
var _selected_node_indices = []

var _moves = 1
var _moves_left = 0
var _timer = 0
var _wins = 0
var _attempts = 3
var _clicks = []

var _interactable_nodes;
var _solution_nodes;

func _ready():
	_interactable_nodes = $InteractableGrid.get_children()
	_solution_nodes = $SolutionGrid.get_children()
	_rng.randomize()
	_new_stage()
	
	if GlobalSettings.game_type == GameType.TIMED:
		$MovesLabel.visible = false
		$AttemptsLabel.visible = false
	else:
		$TimerLabel.visible = false
		$ResetButton.visible = false
	
func _process(delta):
	if GlobalSettings.game_type == GameType.TIMED and not _finished:
		_timer -= delta
		if _timer <= 0:
			get_tree().change_scene("res://assets/trees/Menu.tscn")
			#_timer = 0
			#_wins = 0
			#_set_wins()
			#_new_stage()
		_set_timer_label()

func _new_stage():
	_clicks = []
	
	if GlobalSettings.difficulty == Difficulty.EASY:
		_solution = Solutions.SOLUTIONS[0]
	elif GlobalSettings.difficulty == Difficulty.HARD:
		_solution = Solutions.SOLUTIONS[_rng.randi() % (Solutions.SOLUTIONS.size() - 1) + 1]
	else:
		_solution = Solutions.SOLUTIONS[_rng.randi() % Solutions.SOLUTIONS.size()]
	
	_invert_solution()
				
	var remaining_indexes = []
	for node in _interactable_nodes:
		remaining_indexes.push_back(node.index)
		
	_selected_node_indices = []
	_set_moves()
	for i in range(_moves):
		var index = remaining_indexes[_rng.randi() % remaining_indexes.size()]
		remaining_indexes.erase(index)
		_selected_node_indices.push_back(index)
	
	_attempts = 3
	_set_attempts()
	_set_timer()
	_set_timer_label()
	
	_reset_stage()
	
func instant_reset():
	for node in _interactable_nodes:
			node.set_color(_solution[node.index])
			
	for node in _solution_nodes:
		node.set_color(_solution[node.index])
	
	for index in _selected_node_indices:
		_interactable_nodes[index].flip_all()
	
func _reset_stage():
	if _clicks.size() == 0:
		instant_reset()
	else:
		for click in _clicks:
			_interactable_nodes[click].flip_all()
			yield(get_tree().create_timer(0.5), "timeout")
		_clicks = []
	
	_moves_left = _moves
	_set_moves_left()
	clickable = true

func check_solution(last_click):
	clickable = false
	
	_clicks.push_front(last_click)
	
	var colors = []
	for node in _interactable_nodes:
		colors.push_back(node.color)
		
	var diff = _get_solution_diff(colors, _solution)
	
	if diff.size() == 0:
		_finished = true
		_wins += 1
		_check_high_score()
		_set_moves()
		_set_wins()
		$HighlightGrid.green_blink()
		$SolutionHighlightGrid.green_blink()
		yield(get_tree().create_timer(1), "timeout")
		$HighlightGrid.unblink()
		$SolutionHighlightGrid.unblink()
		_new_stage()
		_finished = false
		return
	
	if GlobalSettings.game_type == GameType.STANDARD:
		_moves_left -= 1
		_set_moves_left()
		if _moves_left == 0:
			$HighlightGrid.blink(diff)
			$SolutionHighlightGrid.blink(diff)
			
			yield(get_tree().create_timer(1.5), "timeout")
			
			$HighlightGrid.unblink()
			$SolutionHighlightGrid.unblink()
			
			_attempts -= 1
			_set_attempts()
			if _attempts == 0:
				get_tree().change_scene("res://assets/trees/Menu.tscn")
				#_moves = 1
				#_wins = 0
				#_set_wins()
				#_new_stage()
			else:
				_reset_stage()
		else:
			yield(get_tree().create_timer(0.4), "timeout")
			clickable = true
	else:
		yield(get_tree().create_timer(0.4), "timeout")
		clickable = true
		
	
func _invert_solution():
	if _rng.randi_range(0, 1) == 0:
		for i in _solution.size():
			if _solution[i] == 0:
				_solution[i] = 1
			else:
				_solution[i] = 0
			
func _get_solution_diff(grid, solution):
	var diff = []
	for i in range(grid.size()):
		if grid[i] != solution[i]:
			diff.push_back(i)
	return diff
			
func highlight(button):
	$Highlight.global_position = button.global_position
	
func unhighlight():
	$Highlight.global_position = Vector2(10000, 10000)
	
func _set_wins():
	$WinsLabel.text = "Wins: " + str(_wins)
	
func _set_moves():
	if GlobalSettings.game_type == GameType.STANDARD:
		if GlobalSettings.difficulty != Difficulty.HARD:
			_moves = min(1 + _wins / 10, 4)
		else:
			_moves = min(1 + _wins / 10, 4) + 1
	else:
		_moves = min(1 + _wins / 12, 3)
		
func _set_timer():
	match GlobalSettings.difficulty:
		Difficulty.EASY:
			_timer = 5 + 10 * _moves - .1 * _wins
		Difficulty.NORMAL:
			_timer = 5 + 7 * _moves - .12 * _wins
		Difficulty.HARD:
			_timer = 5 + 5 * _moves - .15 * _wins
		
func _set_timer_label():
	$TimerLabel.text = "Time: " + str(round(_timer))
	
func _set_moves_left():
	$MovesLabel.text = "Moves: " + str(_moves_left)
	
func _set_attempts():
	$AttemptsLabel.text = "Attempts: " + str(_attempts)

func _check_high_score():
	if GlobalSettings.game_type == GameType.STANDARD:
		match GlobalSettings.difficulty:
			Difficulty.EASY:
				if _wins > Global.easy_high_score:
					Global.easy_high_score = _wins
			Difficulty.NORMAL:
				if _wins > Global.normal_high_score:
					Global.normal_high_score = _wins
			Difficulty.HARD:
				if _wins > Global.hard_high_score:
					Global.hard_high_score = _wins
	else:
		match GlobalSettings.difficulty:
			Difficulty.EASY:
				if _wins > Global.easy_high_score_timed:
					Global.easy_high_score_timed = _wins
			Difficulty.NORMAL:
				if _wins > Global.normal_high_score_timed:
					Global.normal_high_score_timed = _wins
			Difficulty.HARD:
				if _wins > Global.hard_high_score_timed:
					Global.hard_high_score_timed = _wins


func _on_ResetButton_pressed():
	instant_reset()
