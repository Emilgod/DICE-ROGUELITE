extends Node

static func get_warrior() -> Character:
	return Character.new(
		"Warrior",
		"warrior",
		12,
		[get_warrior_die()],
		Color.RED,
		get_warrior_ability()
	)
	
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
static func get_warrior_ability() -> Ability:
	var ability = Ability.new()
	ability.name = "taunt"
	ability.description = "make an enemy target you"
	ability.ability_type = "active"
	ability.mana_cost = 0
	return ability
	
	

static func get_mage() -> Character:
	return Character.new(
		"Mage",
		"mage",
		6,
		[get_mage_die()],
		Color.BLUE,
		get_mage_ability()
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
	
static func get_mage_ability() -> Ability:
	var ability = Ability.new()
	ability.name = "Fireball"
	ability.description = "Deal 2 damage, costs 2 mana"
	ability.ability_type = "active"
	ability.mana_cost = 2
	return ability




static func get_archer() -> Character:
	return Character.new(
		"Archer",
		"archer",
		8,
		[get_archer_die()],
		Color.GREEN,
		get_archer_ability()
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
	
static func get_archer_ability() -> Ability:
	var ability = Ability.new()
	ability.name = "Focused"
	ability.description = "Passive: Double damage vs furthest enemy"
	ability.ability_type = "passive"
	ability.mana_cost = 0
	return ability
	
static func get_priest() -> Character:
	return Character.new(
		"Priest",
		"priest",
		5,
		[get_priest_die()],
		Color.GHOST_WHITE,
		get_priest_ability()
	)

static func get_priest_die() -> DiceData:
	return DiceData.new(
		"Priest Die",
		[
			{"value": 1, "effects": ["attack"]},
			{"value": 1, "effects": ["attack"]},
			{"value": 2, "effects": ["mana"]},
			{"value": 2, "effects": ["mana"]},
			{"value": 1, "effects": ["mana"]},
			{"value": 0, "effects": []}
		]
	)

static func get_priest_ability() -> Ability:
	var ability = Ability.new()
	ability.name = "Dispel"
	ability.description = "Remove random enemy buff or debuff, costs 1 mana"
	ability.ability_type = "active"
	ability.mana_cost = 1
	return ability





	
	# Party presets
static func get_classic_party() -> Array[Character]:
	return[get_warrior(), get_mage(), get_archer()]
	
static func get_crazy_party() -> Array[Character]:
	return[get_warrior(), get_warrior(), get_archer()]
