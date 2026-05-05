extends Resource
class_name Enemy

@export var name: String = ""
@export var max_hp: int = 10
@export var enemy_type: String = ""  # "goblin", "skeleton", etc.
@export var dice: DiceData

var current_hp: int
var is_alive: bool = true
var target: int
func _init(p_name = "", p_type = "", p_hp = 10, p_dice = null):
	name = p_name
	enemy_type = p_type
	max_hp = p_hp
	current_hp = p_hp
	dice = p_dice
	
func roll_dice(party_size: int) -> Dictionary:
	var random_side = dice.sides[randi() % dice.sides.size()]
	target = randi() % party_size
	return{
		"damage": random_side["value"],
		"target": target
	}
func take_damage(amount: int):
	current_hp -= amount
	if current_hp <= 0:
		current_hp = 0
		is_alive = false
