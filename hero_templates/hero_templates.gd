extends Node

static func get_warrior_die() -> DiceData:
	return DiceData.new(
		"Warrior Die",
		[
			{"value": 2, "effects": ["attack"]},
			{"value": 2, "effects": ["attack"]},
			{"value": 2, "effects": ["shield"]},
			{"value": 2, "effects": ["shield"]},
			{"value": 4, "effects": ["self_shield"]},
			{"value": 1, "effects": ["cleave"]}
		]
	)

static func get_mage_die() -> DiceData:
	return DiceData.new(
		"Mage Die",
		[
			{"value": 2, "effects": ["mana"]},
			{"value": 2, "effects": ["mana"]},
			{"value": 1, "effects": ["mana"]},
			{"value": 1, "effects": ["mana"]},
			{"value": 1, "effects": ["attack"]},
			{"value": 1, "effects": ["attack"]}
		]
	)

static func get_archer_die() -> DiceData:
	return DiceData.new(
		"Archer Die",
		[
			{"value": 2, "effects": ["attack"]},
			{"value": 2, "effects": ["attack"]},
			{"value": 3, "effects": ["attack"]},
			{"value": 3, "effects": ["attack"]},
			{"value": 0, "effects": []},
			{"value": 0, "effects": []}
		]
	)

static func get_warrior() -> Character:
	return Character.new(
		"Warrior",
		"warrior",
		12,
		[get_warrior_die()],
		Color.RED
	)

static func get_mage() -> Character:
	return Character.new(
		"Mage",
		"mage",
		6,
		[get_mage_die()],
		Color.BLUE
	)

static func get_archer() -> Character:
	return Character.new(
		"Archer",
		"archer",
		8,
		[get_archer_die()],
		Color.GREEN
	)
	
	
	# Party presets
static func get_classic_party() -> Array[Character]:
	return[get_warrior(), get_mage(), get_archer()]
	
static func get_crazy_party() -> Array[Character]:
	return[get_warrior(), get_warrior(), get_archer()]
