extends Node3D

@onready var camera_3d: Camera3D = $Camera3D
@onready var dice_container: Node3D = $dice_container

var dice_scene = preload("res://SCENES/DICE/dice.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in 5:
		spawn_dice()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func spawn_dice():
	var dice = dice_scene.instantiate()
	dice_container.add_child(dice)
	dice.position = Vector3(randf_range(0, 0.5), 0.2, randf_range(0, 0.5))
	dice.apply_central_impulse(Vector3(randf_range(-0.5, 0.5), 0, randf_range(-0.5, 0.5)))
	dice.apply_torque_impulse(Vector3(randf_range(-5, 5), randf_range(-5, 5), randf_range(-5, 5)))
