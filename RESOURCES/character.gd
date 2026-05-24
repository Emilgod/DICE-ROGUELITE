extends Resource
class_name Character

@export var character_name: String = ""
@export var class_type: String = ""
@export var max_hp: int = 20
@export var class_color: Color = Color.WHITE
@export var dice_pool: Array = []

var current_hp: int
var is_alive: bool = true
var ability: Ability
var shield: int
var taunt_used_this_phase: bool = false

func _init(p_name = "", p_class = "", p_hp = 20, p_dice = [], p_color = Color.WHITE, p_ability = null):
	character_name = p_name
	class_type = p_class
	max_hp = p_hp
	current_hp = p_hp
	dice_pool = p_dice
	class_color = p_color
	ability = p_ability

func add_shield(amount: int) -> void:
	shield += amount
	print("%s now has %d shield" % [character_name, shield])
func heal(amount:int ) -> void:
	current_hp = min(current_hp + amount, max_hp)
	
func take_damage(amount: int):
	if shield > 0:
		var shield_absorbed = min(shield, amount)
		shield -= shield_absorbed
		amount -= shield_absorbed
	
	current_hp -= amount
	if current_hp <= 0:
		current_hp = 0
