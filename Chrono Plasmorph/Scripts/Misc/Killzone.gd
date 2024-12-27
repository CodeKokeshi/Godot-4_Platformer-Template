extends Area2D

@onready var DelayRestart = %Timer

func _on_body_entered(body):
	DelayRestart.start()

func _on_timer_timeout():
	get_tree().reload_current_scene()
