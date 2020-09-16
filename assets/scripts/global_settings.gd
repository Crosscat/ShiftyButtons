extends Node

const Difficulty = preload("consts/difficulty.gd")
const GameType = preload("consts/game_type.gd")

var game_type = GameType.STANDARD
var difficulty = Difficulty.EASY
var guide_marker = false
