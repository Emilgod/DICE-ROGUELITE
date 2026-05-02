extends Resource
class_name Character

@export var character_name: String = ""
@export var class_type: String = ""
@export var max_hp: int = 20
@export var class_color: Color = Color.WHITE
@export var dice_pool: Array = []

var current_hp: int

func _init(p_name = "", p_class = "", p_hp = 20, p_dice = [], p_color = Color.WHITE):
	character_name = p_name
	class_type = p_class
	max_hp = p_hp
	current_hp = p_hp
	dice_pool = p_dice
	class_color = p_color

func take_damage(amount: int):
	current_hp -= amount
	if current_hp <= 0:
		current_hp = 0
