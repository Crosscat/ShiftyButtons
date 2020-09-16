extends Node

var _nodes;

func _ready():
	_nodes = get_children()

func blink(nums):
	for num in nums:
		_nodes[num].modulate = Color(1, 1, 1, 0.5)
		_nodes[num].play("blink")
		
func green_blink():
	for node in _nodes:
		node.modulate = Color(0, .7, 0, 1)
		node.play("blink")

func unblink():
	for node in _nodes:
		node.stop()
		node.set_frame(1)
