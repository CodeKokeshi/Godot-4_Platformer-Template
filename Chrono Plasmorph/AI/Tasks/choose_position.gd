extends BTAction

@export var minimum_direction: float = 40.0
@export var maximum_direction: float = 100.0

@export var position_variable: StringName = &"pos"
@export var direction_variable: StringName = &"dir"

func _tick(_delta: float) -> Status:
	var pos: Vector2
	var dir = random_direction()
	pos = random_position(dir)
	blackboard.set_var(position_variable, pos)
	return SUCCESS

func random_position(dir):
	var vector: Vector2
	var distance = randi_range(minimum_direction, maximum_direction) * dir
	var final_position = (distance + agent.global_position.x)
	vector.x = final_position
	return vector
	
func random_direction():
	var dir = randi_range(-2,1)
	if abs(dir) != 1:
		dir = -1
	else:
		dir = 1
	blackboard.set_var(direction_variable, dir)
	return dir
