extends Resource
class_name Enemy

@export var name: String = ""
@export var max_hp: int = 10
@export var enemy_type: String = ""  # "goblin", "skeleton", etc.

var current_hp: int
var is_alive: bool = true

func _init(p_name = "", p_type = "", p_hp = 10):
	name = p_name
	enemy_type = p_type
	max_hp = p_hp
	current_hp = p_hp

func take_damage(amount: int):
	current_hp -= amount
	if current_hp <= 0:
		current_hp = 0
		is_alive = false
