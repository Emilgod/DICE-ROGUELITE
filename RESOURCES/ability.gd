extends Resource
class_name Ability

@export var name: String = ""
@export var description: String = ""
@export var ability_type: String = ""  # "active" or "passive"
@export var mana_cost: int = 0
@export var cooldown: int = 0

func execute(source: Character, target) -> void:
	match ability_type:
		"active":
			# Player must click to use
			pass
		"passive":
			# Always active
			pass
