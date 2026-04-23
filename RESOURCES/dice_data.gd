extends Resource
class_name DiceData

@export var name: String = "Basic Die"
@export var sides: Array = []

func _init(p_name = "", p_sides = []):
	name = p_name
	sides = p_sides
