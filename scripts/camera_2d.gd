extends Camera2D

@export var player: Node2D
@export var x_offset: float = 0.0   # how far Mario is from center horizontally
var base_y: float                   # fixed vertical position

func _ready() -> void:
	base_y = global_position.y      # whatever Y you set in the editor

func _process(delta: float) -> void:
	if player:
		global_position.x = player.global_position.x + x_offset
		global_position.y = base_y  # never moves vertically
