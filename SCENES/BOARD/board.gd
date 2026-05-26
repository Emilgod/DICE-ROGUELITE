extends Node3D

@onready var camera_3d: Camera3D = $Camera3D
@onready var dice_container: Node3D = $dice_container
@onready var button: Button = $UI/Button
@export var actions_container: VBoxContainer
@export var party_container: HBoxContainer
@export var enemy_container: HBoxContainer
@export var phase_button: Button
@export var combat_manager: CombatManager
@export var mana_label: Label

var dice_scene = preload("res://SCENES/DICE/dice.tscn")
var hero_templates = preload("res://hero_templates/hero_templates.gd")
var enemy_templates = preload("res://enemy_templates/enemy_templates.gd")
var character_panel_scene = preload("res://SCENES/CHARACTER STUFF/character_ui.tscn")
var dice_action_button_scene = preload("res://SCENES/UI/dice_action_button.tscn")
var active_action_button: Button = null
var party: Array[Character] = []
var all_dice = []
var dice_to_character = {}
var current_enemies: Array[Enemy] = []
var current_enemy_attacks: Array[Dictionary] = []
var rerolls_remaining: int = 2
var dice_results_updated: bool = false
var action_targeting
enum targeting_types { INSTANT, ENEMY_TARGETED, ALLY_TARGETED }
var pending_action: Dictionary = {}
func _ready() -> void:
	setup_with_party(GameManager.selected_party)
	setup_party_display()
	spawn_dice()
	setup_encounter()
	start_enemy_phase()

func setup_party_display():
	for character in party:
		var panel = character_panel_scene.instantiate()
		panel.board = self
		party_container.add_child(panel)
		panel.setup(character)

func update_party_display():
	for panel in party_container.get_children():
		panel.update_hp()
	mana_label.text = "MANA : %s" % GameManager.current_mana
	
func update_enemy_display():
	for panel in enemy_container.get_children():
		panel.update_hp()

func setup_with_party(party_name: String):
	match party_name:
		"classic":
			party = hero_templates.get_classic_party()
		"crazy":
			party = hero_templates.get_crazy_party()
	
	for character in party:
		print("Added: ", character.character_name)

func spawn_dice():
	for character in party:
		for dice_template in character.dice_pool:
			spawn_single_die(dice_template, character)

func spawn_single_die(template: DiceData, character: Character):
	var dice = dice_scene.instantiate()
	dice_container.add_child(dice)
	
	dice.set_sides(template.sides)
	dice.set_class_tint(character.class_color)
	dice.position = Vector3(randf_range(0, 0.1), -1, randf_range(0, 0.1))
	dice.apply_central_impulse(Vector3(randf_range(-10, 10), 0, randf_range(-10, 10)))
	dice.apply_torque_impulse(Vector3(randf_range(-0.05, 0.05), randf_range(-0.05, 0.05), randf_range(-0.05, 0.05)))
	
	all_dice.append(dice)
	dice_to_character[dice] = character

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		# Only allow locking during rolling phase
		if not GameManager.is_state(GameManager.GameState.PLAYER_ROLLING):
			return
		
		var mouse_pos = get_viewport().get_mouse_position()
		var from = camera_3d.project_ray_origin(mouse_pos)
		var normal = camera_3d.project_ray_normal(mouse_pos)
		
		var query = PhysicsRayQueryParameters3D.create(from, from + normal * 1000)
		query.collide_with_areas = false
		query.collision_mask = 0
		query.collision_mask |= 1
		
		var result = get_world_3d().direct_space_state.intersect_ray(query)
		
		if result and result.collider.is_in_group("dice"):
			result.collider.toggle_lock()

func _process(delta: float) -> void:
	var all_settled = all_dice.all(func(d): return d.is_settled)
	
	if GameManager.is_state(GameManager.GameState.PLAYER_ROLLING):
		button.disabled = not all_settled
		button.modulate = Color.GRAY if button.disabled else Color.WHITE

		if all_settled and not dice_results_updated:
			update_dice_results()
			dice_results_updated = true
	
	elif GameManager.is_state(GameManager.GameState.PLAYER_ACTIONS):
		if all_settled and not dice_results_updated:
			update_dice_results()
			dice_results_updated = true
		
		for dice in all_dice:
			dice.is_locked = false
			dice.update_outline()


func update_dice_results():
	# Clear old buttons
	for child in actions_container.get_children():
		child.free()
	
	# Create new ones
	for i in range(all_dice.size()):
		var dice = all_dice[i]
		var character = dice_to_character[dice]
		
		# Skip if character is dead
		if character.current_hp <= 0:
			continue
		
		if dice.is_settled:
			var top_face = dice.get_top_face()
			var face_data = dice.sides_data[top_face]
			
			# Skip blank faces
			if face_data["effects"].is_empty():
				continue
			
			var action_button = dice_action_button_scene.instantiate()
			action_button.board = self
			action_button.add_to_group("action_button")
			actions_container.add_child(action_button)
			action_button.setup(face_data, dice, character, Callable(self, "on_action_selected"))


func show_enemy_targeting(face_data: Dictionary, character: Character) -> void:
	print("Select enemy target...")
	# Show enemy selection UI

func show_ally_targeting(face_data: Dictionary, character: Character) -> void:
	print("Select ally target...")
	# Show ally selection UI
func reroll_dice():
	if not GameManager.is_state(GameManager.GameState.PLAYER_ROLLING):
		return
	if rerolls_remaining <= 0:
		end_rolls()
		return
	rerolls_remaining -= 1
	
	for child in actions_container.get_children():
		child.queue_free()
		
	for dice in all_dice:
		if not dice.is_locked:
			dice.is_settled = false
			dice.apply_central_impulse(Vector3(randf_range(-10, 10), randf_range(7, 10), randf_range(-10, 10)))
			dice.apply_torque_impulse(Vector3(randf_range(-0.2, 0.2), randf_range(-0.2, 0.2), randf_range(-0.2, 0.2)))
	# Reset flag so _process() will update buttons when dice settle
	dice_results_updated = false
	

	if rerolls_remaining == 0:
		end_rolls()
	update_button_text()

func setup_encounter():
	current_enemies = [
		enemy_templates.get_goblin(),
		enemy_templates.get_goblin(),
		enemy_templates.get_skeleton()
	]
	
	for i in range(current_enemies.size()):
		var enemy = current_enemies[i]
		# Last enemy is backline
		enemy.position_in_line = 0 if i < current_enemies.size() - 1 else 1
		
		var enemy_ui = load("res://enemy_templates/enemy_ui.tscn").instantiate()
		enemy_container.add_child(enemy_ui)
		enemy_ui.board = self
		enemy_ui.setup(enemy)
		
func update_enemy_positions():
	for i in range(current_enemies.size()):
		var enemy = current_enemies[i]
		enemy.position_in_line = 0 if i < current_enemies.size() - 1 else 1
		
func start_enemy_phase():
	GameManager.set_state(GameManager.GameState.ENEMY_PHASE)
	print("=== ENEMY PHASE ===")
	
	# Get list of alive party members
	var alive_party = []
	for character in party:
		if character.current_hp > 0:
			alive_party.append(character)
	
	# If no one is alive, game over
	if alive_party.is_empty():
		print("=== GAME OVER ===")
		return
	
	current_enemy_attacks.clear()
	var enemy_uis = enemy_container.get_children()
	
	for i in range(current_enemies.size()):
		var enemy = current_enemies[i]
		var attack = enemy.roll_dice(alive_party.size())  # Only target alive members
		attack["enemy_index"] = i  # Add this back
		# Convert alive_party index to actual party index
		var actual_target = party.find(alive_party[attack["target"]])
		attack["target"] = actual_target
		
		# If taunted, override the target
		if enemy.target_override and enemy.target_override.current_hp > 0:
			attack["target"] = party.find(enemy.target_override)
			enemy.target_override = null
		
		current_enemy_attacks.append(attack)
		
		var enemy_ui = enemy_uis[i]
		var effects = attack.get("effects", ["attack"])
		var action_name = effects[0].capitalize() if effects.size() > 0 else "Attack"
		enemy_ui.set_next_action("%s: %d" % [action_name, attack["damage"]])
		#color
		var target_character = party[attack["target"]]
		enemy_ui.color_action_label(target_character)
	# Clear old damage displays and show new ones
	var panels = party_container.get_children()
	for panel in panels:
		panel.unhighlight()
	
	for attack in current_enemy_attacks:
		if attack["target"] >= 0 and attack["target"] < panels.size():
			var target_panel = panels[attack["target"]]
			target_panel.show_incoming_damage(attack["damage"])
	
	start_player_rolling_phase()

func start_player_rolling_phase():
	GameManager.set_state(GameManager.GameState.PLAYER_ROLLING)
	print("=== PLAYER ROLLING PHASE ===")
	for character in party:
		character.taunt_used_this_phase = false
	rerolls_remaining = 2
	for child in actions_container.get_children():
		child.free()
	dice_results_updated = false
	
	for dice in all_dice:
		var character = dice_to_character[dice]
		
		# Only roll if character is alive
		if character.current_hp > 0:
			dice.is_settled = false
			dice.is_locked = false
			dice.update_outline()
			dice.reset_and_reroll()
		else:
			# Dead character's dice stays still
			dice.is_settled = true
			dice.visible = false 
	update_button_text()

func end_rolls():
	if not GameManager.is_state(GameManager.GameState.PLAYER_ROLLING):
		return
	
	# Check if all dice are settled
	var all_settled = all_dice.all(func(d): return d.is_settled)
	if not all_settled:
		print("Wait for all dice to settle first")
		return
	
	# Check if action buttons have been created
	if not dice_results_updated:
		print("Wait for action buttons to appear")
		return
	
	button.hide()
	dice_results_updated = false
	GameManager.set_state(GameManager.GameState.PLAYER_ACTIONS)
	print("=== PLAYER ACTIONS PHASE ===")
	
	# Reset taunt usage for this action phase
	for character in party:
		character.taunt_used_this_phase = false
	
	update_button_text()

func end_turn():
	if not GameManager.is_state(GameManager.GameState.PLAYER_ACTIONS):
		return
	button.show()
	pending_action = {}
	GameManager.current_mana = 0
	GameManager.set_state(GameManager.GameState.ENEMY_EXECUTE)
	print("=== ENEMY EXECUTES ===")
	
	execute_enemy_turn()

func execute_enemy_turn():
	for i in range(current_enemies.size()):
		var attack = current_enemy_attacks[i]
		var target = party[attack["target"]]
		var damage = attack["damage"]
		
		target.take_damage(damage)
		print("Enemy %d dealt %d damage to %s" % [i, damage, target.character_name])
	
	for character in party:
		character.shield = 0
	
	update_party_display()
	start_enemy_phase()

func update_button_text():
	if GameManager.is_state(GameManager.GameState.PLAYER_ROLLING):
		phase_button.text = "END ROLLS"
		button.text = "%d REROLLS" % [rerolls_remaining]
	elif GameManager.is_state(GameManager.GameState.PLAYER_ACTIONS):
		phase_button.text = "END TURN"
	else:
		phase_button.text = "..."

func _on_phase_button_pressed() -> void:
	if GameManager.is_state(GameManager.GameState.PLAYER_ROLLING):
		end_rolls()
	elif GameManager.is_state(GameManager.GameState.PLAYER_ACTIONS):
		end_turn()

func _on_button_pressed() -> void:
	reroll_dice()

func find_action_targeting(effects: Array):
	for effect in effects:
		if effect in ["attack", "poison", "taunt"]:
			action_targeting = "ENEMY_TARGETED"
			return 
		if effect in ["shield"]:
			action_targeting = "ALLY_TARGETED"
			return 
	action_targeting = "INSTANT"
	return
	
func victory(): 
	print("=== YOU WIN ===")
