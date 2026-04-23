extends Node

static func get_attack_die() -> DiceData:
	return DiceData.new(
		"Attack Die",
		[
			{"value": 0, "effects": []},
			{"value": 0, "effects": []},
			{"value": 1, "effects": ["attack"]},
			{"value": 1, "effects": ["attack"]},
			{"value": 2, "effects": ["attack"]},
			{"value": 2, "effects": ["attack"]}
		]
	)

static func get_defense_die() -> DiceData:
	return DiceData.new(
		"Defense Die",
		[
			{"value": 0, "effects": []},
			{"value": 0, "effects": []},
			{"value": 2, "effects": ["shield"]},
			{"value": 2, "effects": ["shield"]},
			{"value": 4, "effects": ["shield"]},
			{"value": 4, "effects": ["shield"]}
		]
	)

static func get_character_1() -> PlayerData:
	return PlayerData.new(
		"Character 1",
		[
			get_attack_die(),
			get_attack_die(),
			get_defense_die()
		]
	)
