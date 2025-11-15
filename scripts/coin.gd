extends Area2D

@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
var coin_count = 0

func _on_body_entered(body: Node2D) -> void:
	print("+1 coin")
	coin_count += 1 
	print("total coin count is " + str(coin_count))
	collision_shape.set_deferred("disabled", true)
	sprite.visible = false

	# Play sound
	audio_stream_player_2d.play()

	# Wait for sfx to finish, THEN free the node
	await audio_stream_player_2d.finished
	queue_free()
