extends StaticBody2D

@export var Bullet: PackedScene
@onready var marker_2d = $Marker2D

var cooldown = 2

func _process(delta):
	if Bullet != null:
		cooldown -= delta
		
		if cooldown <= delta:
			var instance = Bullet.instantiate()
			instance.position = marker_2d.position
			add_child(instance)
			cooldown = 2
