extends Node

static func get_goblin() -> Enemy:
	return Enemy.new(
		"Goblin",
		"goblin",
		10
	)

static func get_skeleton() -> Enemy:
	return Enemy.new(
		"Skeleton",
		"skeleton",
		15
	)

static func get_troll() -> Enemy:
	return Enemy.new(
		"Troll",
		"troll",
		25
	)
