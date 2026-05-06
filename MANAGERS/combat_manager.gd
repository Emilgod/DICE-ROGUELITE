extends Node2D
class_name CombatManager

enum GameState { ENEMY_PHASE, PLAYER_ROLLING, PLAYER_ACTIONS, ENEMY_EXECUTE }

var current_state: GameState = GameState.ENEMY_PHASE
var party: Array[Character] = []
var current_enemies: Array[Enemy] = []
var current_enemy_attacks: Array[Dictionary] = []
var party_mana: int = 0
var rerolls_remaining: int = 2

func apply_attack(damage: int, target: Enemy) -> void:
	target.take_damage(damage)
	print("Dealt %d damage to %s" % [damage, target.name])

func apply_cleave(damage: int) -> void:
	for enemy in current_enemies:
		if enemy.is_alive:
			enemy.take_damage(damage)
	print("Cleaved all enemies for %d damage" % [damage])

func apply_poison(damage: int, target: Enemy) -> void:
	target.take_damage(damage)
	print("Poisoned %s for %d damage" % [target.name, damage])

func apply_mana(amount: int) -> void:
	party_mana = min(party_mana + amount, 10)
	print("Gained %d mana. Total: %d" % [amount, party_mana])

func apply_self_shield(character: Character, shield_value: int) -> void:
	character.current_hp = min(character.current_hp + shield_value, character.max_hp)
	print("%s gained %d shield" % [character.character_name, shield_value])

func apply_heal(character: Character, heal_value: int) -> void:
	character.current_hp = min(character.current_hp + heal_value, character.max_hp)
	print("%s healed for %d" % [character.character_name, heal_value])

func apply_shield(character: Character, shield_value: int) -> void:
	character.current_hp = min(character.current_hp + shield_value, character.max_hp)
	print("%s gained %d shield" % [character.character_name, shield_value])

func check_enemy_deaths() -> bool:
	var all_dead = current_enemies.all(func(e): return not e.is_alive)
	if all_dead:
		print("ALL ENEMIES DEFEATED!")
	return all_dead

func check_party_deaths() -> bool:
	var all_dead = party.all(func(c): return c.current_hp <= 0)
	if all_dead:
		print("PARTY DEFEATED!")
	return all_dead
