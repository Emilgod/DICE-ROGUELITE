extends Resource
class_name PlayerData

@export var name: String = "Player"
@export var dice_pool: Array = []

func _init(p_name = "", p_dice = []):
	name = p_name
	dice_pool = p_dice
