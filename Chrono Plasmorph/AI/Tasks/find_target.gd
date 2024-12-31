extends BTAction

@export var group: StringName
@export var target_variable: StringName = &"target"

var target

func _tick(_delta: float) -> Status:
	if group == "enemy":
		target = enemy_node()
		print("Enemy Found")
	elif group == "player":
		target = player_node()
		print("Player Found")
	blackboard.set_var(target_variable, target)
	return SUCCESS

func enemy_node():
	var nodes: Array[Node] = agent.get_tree().get_nodes_in_group(group)
	if nodes.size() >= 2:
		while !agent.check_for_self(nodes.front()):
			nodes.shuffle()
		return nodes.front()
	
	
func player_node():
	var nodes: Array[Node] = agent.get_tree().get_nodes_in_group(group)
	return nodes[0]
