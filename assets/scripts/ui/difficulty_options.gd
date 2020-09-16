extends Node

func _on_OptionDropdown_item_selected(index):
	GlobalSettings.difficulty = index
