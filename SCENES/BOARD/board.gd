extends Node3D

@onready var camera_3d: Camera3D = $Camera3D
@onready var dice_container: Node3D = $dice_container
@onready var button: Button = $UI/Button


@export var rerolls_remaining:int  = 2

var dice_scene = preload("res://SCENES/DICE/dice.tscn")
var all_dice = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_dice()
	update_button_text()
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

func spawn_dice():
	var dice = dice_scene.instantiate()
	dice_container.add_child(dice)
	
	var sides = [
		{"value": 2, "effects": ["attack"]},
		{"value": 1, "effects": ["shield"]},
		{"value": 3, "effects": ["poison"]},
		{"value": 1, "effects": ["attack", "poison"]},
		{"value": 0, "effects": []},
		{"value": 4, "effects": ["attack"]}
	]
	dice.set_sides(sides)
	dice.reset_and_reroll()
	all_dice.append(dice)


func update_button_text():
	if rerolls_remaining == 1:
		button.text = "1 REROLL"
	elif rerolls_remaining == 0:
		button.text = "0 REROLLS"
	else:
		button.text = "%d REROLLS" % [rerolls_remaining]
	
func reroll_dice():
	if rerolls_remaining <= 0:
		print("no rerolls")
		return
	rerolls_remaining -= 1
	for dice in all_dice:
		if not dice.is_locked:
			dice.reset_and_reroll()
	update_button_text()

func _on_button_pressed() -> void:
	reroll_dice()
