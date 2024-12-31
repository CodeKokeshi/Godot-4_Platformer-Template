extends TextureRect
@onready var timer = $Timer

@export var prefab: PackedScene

var count = 0

func spawn():
	if count < 5:
		var instance = prefab.instantiate()  # Create an instance of the PackedScene
		add_child(instance)  # Add the instance to the scene tree
		count += 1  # Increment the count
		timer.start()

# A timer timeout signal, assumed to be connected
func _on_timer_timeout():
	spawn()
	count += 1
