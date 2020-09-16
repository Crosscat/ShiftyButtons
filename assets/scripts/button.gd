extends Area2D

const ButtonColor = preload("consts/button_color.gd")

var color = ButtonColor.RED
var _neighbors = []
var _main

export var index = 0
export var clickable = false

func _ready():
	_main = get_node("../..")
	var points = [Vector2(-256, -256), Vector2(0, -256), Vector2(256, -256), Vector2(-256, 0), Vector2(256, 0), Vector2(-256, 256), Vector2(0, 256), Vector2(256, 256)]
	for point in points:
		var hits = get_world_2d().direct_space_state.intersect_point(global_position + Vector2(point.x * transform.get_scale().x, point.y * transform.get_scale().y), 32, [], 0x7FFFFFFF, true, true)
		for hit in hits:
			if typeof(hit.collider) == TYPE_OBJECT and hit.collider.get_node("..") == get_node(".."):
				_neighbors.push_back(hit.collider)

func _input_event(viewport, event, shape_idx):
	if clickable and _main.clickable and event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		flip_all()
		_main.check_solution(index)
			
func set_color(c):
	if c != color:
		flip()
		
func flip_all():
	flip()
	for neighbor in _neighbors:
		neighbor.flip()
			
func flip():
	if color == ButtonColor.RED:
		$AnimatedSprite.play("red-to-blue")
		color = ButtonColor.BLUE
	else:
		$AnimatedSprite.play("blue-to-red")
		color = ButtonColor.RED

#func _mouse_enter():
#	if !clickable:
#		return
#	_main.highlight(self)
