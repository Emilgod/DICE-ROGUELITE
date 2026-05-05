extends Node

static func get_goblin() -> Enemy:
	return Enemy.new(
		"Goblin",
		"goblin",
		10,
		get_goblin_dice()
	)
static func get_goblin_dice() -> DiceData:
	return DiceData.new(
		"Goblin Attack Die",
		[
			{"value": 1, "effects": ["attack"]},
			{"value": 1, "effects": ["attack"]},
			{"value": 2, "effects": ["attack"]},
			{"value": 2, "effects": ["attack"]},
			{"value": 3, "effects": ["attack"]},
			{"value": 0, "effects": []}
		]
	)


static func get_skeleton() -> Enemy:
	return Enemy.new(
		"Skeleton",
		"skeleton",
		15,
		get_skeleton_dice()
	)
static func get_skeleton_dice() -> DiceData:
	return DiceData.new(
		"Skeleton Attack Die",
		[
			{"value": 1, "effects": ["attack"]},
			{"value": 1, "effects": ["attack"]},
			{"value": 2, "effects": ["attack"]},
			{"value": 2, "effects": ["attack"]},
			{"value": 3, "effects": ["attack"]},
			{"value": 0, "effects": []}
		]
	)
static func get_troll() -> Enemy:
	return Enemy.new(
		"Troll",
		"troll",
		25,
		get_troll_dice()
	)
static func get_troll_dice() -> DiceData:
	return DiceData.new(
		"Troll dice",
		[
			{"value": 1, "effects": ["attack"]},
			{"value": 1, "effects": ["attack"]},
			{"value": 2, "effects": ["attack"]},
			{"value": 2, "effects": ["attack"]},
			{"value": 3, "effects": ["attack"]},
			{"value": 0, "effects": []}
		]
	)
