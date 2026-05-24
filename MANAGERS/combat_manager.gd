extends Node2D
class_name CombatManager

@export var board:Node3D
var pending_action: Dictionary = {}


func execute_instant_action(face_data: Dictionary, character: Character, button) -> void:
	var effects = face_data["effects"]
	var value = face_data["value"]
	
	for effect in effects:
		match effect:
			"mana":
				GameManager.add_mana(value)
				print("Gained %d mana (total: %d)" % [value, GameManager.current_mana])
			
			"self_shield":
				character.add_shield(value)
				print("%s gained %d shield" % [character.character_name, value])
			
			"cleave":
				for enemy in board.current_enemies:
					enemy.take_damage(value)
				print("%s cleaved all enemies for %d damage" % [character.character_name, value])

	button.queue_free()
	board.update_party_display()
	board.update_enemy_display()

func execute_targeted_action(target, target_is_enemy: bool) -> void:
	if board.pending_action.is_empty():
		return
	
	var action = board.pending_action
	var face_data = action["face_data"]
	var acting_character = action["character"]
	var value = face_data["value"]
	var effects = face_data["effects"]
	
	# Spend mana if it's an ability
	if action.get("is_ability", false):
		GameManager.current_mana -= action["mana_cost"]
		print("Spent %d mana" % action["mana_cost"])
	
	# Execute effects
	for effect in effects:
		match effect:
			"attack":
				target.take_damage(value)
				print("%s attacked %s for %d damage" % [acting_character.character_name, target.character_name, value])
			
			"shield":
				target.add_shield(value)
				print("%s shielded %s for %d" % [acting_character.character_name, target.character_name, value])
			
			"taunt":
				target.target_override = acting_character
				acting_character.taunt_used_this_phase = true
				
				# Find and update the current attack for this enemy
				for attack in board.current_enemy_attacks:
					if attack.get("enemy_index") == board.current_enemies.find(target):
						attack["target"] = board.party.find(acting_character)
						break
				
				print("%s taunted %s to target them" % [acting_character.character_name, target.character_name])
				var panels = board.party_container.get_children()
				for panel in panels:
					panel.unhighlight()
				
				for attack in board.current_enemy_attacks:
					if attack["target"] >= 0 and attack["target"] < panels.size():
						var target_panel = panels[attack["target"]]
						target_panel.show_incoming_damage(attack["damage"])
	
	if not action["button"].is_in_group("ability_button"):
		action["button"].queue_free()
	board.pending_action = {}
	board.update_party_display()
