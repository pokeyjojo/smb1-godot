extends Area2D

@onready var timer: Timer = $Timer
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer2D
#@onready var anim: AnimatedSprite2D = $root/mario/AnimatedSprite2D

func _on_body_entered(body: Node2D) -> void:
	print(" you died")
	
	body.get_node("CollisionShape2D").queue_free()
	timer.start()
	audio_stream_player.play()
	body.die()
		 # Replace with function body.


func _on_timer_timeout() -> void:
	get_tree().reload_current_scene() # Replace with function body.
