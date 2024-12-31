extends BTAction

@export var target_position_variable := &"pos"
@export var direction_variable := &"dir"

@export var speed_variable = 100
@export var tolerance = 10

func _tick(_delta: float) -> Status:
	var target_position = blackboard.get_var(target_position_variable, Vector2.ZERO)
	var direction = blackboard.get_var(direction_variable)
	
	if abs(agent.global_position.x - target_position.x) < tolerance:
		agent.move(direction, 0)
		return SUCCESS
	else:
		agent.move(direction, speed_variable)
		return SUCCESS
