extends Node3D

enum GameState { ENEMY_PHASE, PLAYER_ROLLING, PLAYER_ACTIONS, ENEMY_EXECUTE }

@onready var camera_3d: Camera3D = $Camera3D
@onready var dice_container: Node3D = $dice_container
@onready var button: Button = $UI/Button
@export var actions_container: VBoxContainer
@export var party_container: HBoxContainer
@export var mana_label: Label
@export var enemy_container: HBoxContainer
@export var rerolls_remaining: int = 2
@export var phase_button: Button

var dice_scene = preload("res://SCENES/DICE/dice.tscn")
var hero_templates = preload("res://hero_templates/hero_templates.gd")
var enemy_templates = preload("res://enemy_templates/enemy_templates.gd")
var character_panel_scene = preload("res://SCENES/CHARACTER STUFF/character_ui.tscn")

var party: Array[Character] = []
var all_dice = []
var dice_to_character = {}
var party_mana: int = 0
var current_enemies: Array[Enemy] = []
var current_enemy_attacks: Array[Dictionary] = []
var current_state: GameState = GameState.ENEMY_PHASE

func _ready() -> void:
	setup_with_party(GameManager.selected_party)
	setup_party_display()
	spawn_dice()
	setup_encounter()
	create_placeholder_buttons()
	start_enemy_phase()

func setup_party_display():
	for Character in party:
		var panel = character_panel_scene.instantiate()
		party_container.add_child(panel)
		panel.setup(Character)

func update_party_display():
	for panel in party_container.get_children():
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
			update_dice_results()

func _process(delta: float) -> void:
	update_dice_results()
	var all_settled = all_dice.all(func(d): return d.is_settled)
	
	if current_state == GameState.PLAYER_ROLLING:
		button.disabled = not all_settled
		if button.disabled:
			button.modulate = Color.GRAY
		else:
			button.modulate = Color.WHITE

func update_button_text():
	if current_state == GameState.PLAYER_ROLLING:
		if rerolls_remaining >= 0:
			button.text = "%s REROLLS" % [rerolls_remaining]
		phase_button.text = "END ROLLS"
	else:
		button.text = "..."
		phase_button.text = "END TURN"
	
func create_placeholder_buttons() -> void:
	for i in range(all_dice.size()):
		var placeholder = Button.new()
		placeholder.name = "DieButton%d" % i
		placeholder.text = "Die %d" % (i + 1)
		placeholder.disabled = true
		placeholder.modulate = Color.GRAY
		placeholder.toggle_mode = true
		actions_container.add_child(placeholder)

func update_dice_results():
	for i in range(all_dice.size()):
		var dice = all_dice[i]
		var button = actions_container.get_child(i)
		var character = dice_to_character[dice]
		
		if dice.is_settled:
			var top_face = dice.get_top_face()
			var face_data = dice.sides_data[top_face]
			
			button.text = "%s: %d %s" % [character.character_name, face_data["value"], ", ".join(face_data["effects"])]
			button.disabled = false
			button.modulate = Color.WHITE
			
			for sig in button.pressed.get_connections():
				button.pressed.disconnect(sig.callable)
			
			button.pressed.connect(func(): on_action_selected(face_data, dice, character))
		else:
			button.text = "Die %d" % (i + 1)
			button.disabled = true
			button.modulate = Color.GRAY

func on_action_selected(face_data: Dictionary, dice, character: Character) -> void:
	if current_state != GameState.PLAYER_ACTIONS:
		return
	
	print("Selected from %s: " % character.character_name, face_data)
	
	var effects = face_data["effects"]
	var value = face_data["value"]
	
	# Process each effect
	for effect in effects:
		match effect:
			"attack":
				apply_attack(value)
			"shield":
				show_ally_targeting("shield", value)
			"heal":
				show_ally_targeting("heal", value)
			"poison":
				apply_poison(value)
			"mana":
				apply_mana(value)
			"cleave":
				apply_cleave(value)
			"self_shield":
				apply_self_shield(character, value)
	
	print("Selected from %s: " % character.character_name, face_data)
	# TODO: Apply effects
func apply_attack(damage: int):
	# Attack random enemy
	var random_enemy = current_enemies[randi() % current_enemies.size()]
	random_enemy.take_damage(damage)
	print("Dealt %d damage to %s" % [damage, random_enemy.name])
	update_enemy_ui()
	check_enemy_deaths()

func apply_cleave(damage: int):
	# Attack all enemies
	for enemy in current_enemies:
		if enemy.is_alive:
			enemy.take_damage(damage)
	print("Cleaved all enemies for %d damage" % [damage])
	update_enemy_ui()
	check_enemy_deaths()

func apply_poison(amount: int):
	# For now, just deal damage (poison mechanic can be expanded later)
	var random_enemy = current_enemies[randi() % current_enemies.size()]
	random_enemy.take_damage(amount)
	print("Poisoned %s for %d damage" % [random_enemy.name, amount])
	update_enemy_ui()
	check_enemy_deaths()

func apply_mana(amount: int):
	party_mana = min(party_mana + amount, 10)  # Max 10 mana
	print("Gained %d mana. Total: %d" % [amount, party_mana])
	update_mana_label()

func apply_self_shield(character: Character, shield_value: int):
	# For now, just add to HP (proper shield mechanic can be added later)
	character.current_hp = min(character.current_hp + shield_value, character.max_hp)
	print("%s gained %d shield" % [character.character_name, shield_value])
	update_party_display()

func show_ally_targeting(effect: String, value: int):
	# Show buttons to select which ally to target
	var panels = party_container.get_children()
	for i in range(panels.size()):
		var panel = panels[i]
		var target_button = Button.new()
		target_button.text = "%s (%s: %d)" % [party[i].character_name, effect.to_upper(), value]
		target_button.pressed.connect(func(): apply_ally_effect(effect, value, party[i]))
		actions_container.add_child(target_button)

func apply_ally_effect(effect: String, value: int, target: Character):
	match effect:
		"shield":
			target.current_hp = min(target.current_hp + value, target.max_hp)
			print("%s gained %d shield" % [target.character_name, value])
		"heal":
			target.current_hp = min(target.current_hp + value, target.max_hp)
			print("%s healed for %d" % [target.character_name, value])
	update_party_display()

func update_enemy_ui():
	for enemy_ui in enemy_container.get_children():
		enemy_ui.update_hp()

func update_mana_label():
	mana_label.text = "Mana: %d/10" % [party_mana]

func check_enemy_deaths():
	var all_dead = current_enemies.all(func(e): return not e.is_alive)
	if all_dead:
		print("ALL ENEMIES DEFEATED!")
		# TODO: Victory condition
func reroll_dice():
	if current_state != GameState.PLAYER_ROLLING:
		return
	if rerolls_remaining <= 0:
		end_rolls()
		return
	rerolls_remaining -= 1
	for dice in all_dice:
		if not dice.is_locked:
			dice.reset_and_reroll()
	update_button_text()



func setup_encounter():
	current_enemies = [
		enemy_templates.get_goblin(),
		enemy_templates.get_goblin(),
		enemy_templates.get_skeleton()
	]
	
	for enemy in current_enemies:
		var enemy_ui = load("res://enemy_templates/enemy_ui.tscn").instantiate()
		enemy_container.add_child(enemy_ui)
		enemy_ui.setup(enemy)

func start_enemy_phase():
	current_state = GameState.ENEMY_PHASE
	print("=== ENEMY PHASE ===")
	
	current_enemy_attacks.clear()
	var enemy_uis = enemy_container.get_children()
	
	for i in range(current_enemies.size()):
		var enemy = current_enemies[i]
		var attack = enemy.roll_dice(party.size())
		current_enemy_attacks.append(attack)
		
		var enemy_ui = enemy_uis[i]
		enemy_ui.set_next_action("Attack %s: %d damage" % [party[attack["target"]].character_name, attack["damage"]])
	
	var panels = party_container.get_children()
	for i in range(panels.size()):
		panels[i].unhighlight()
	
	for attack in current_enemy_attacks:
		panels[attack["target"]].highlight_as_target()
	
	start_player_rolling_phase()

func start_player_rolling_phase():
	current_state = GameState.PLAYER_ROLLING
	print("=== PLAYER ROLLING PHASE ===")
	for dice in all_dice:
		if not dice.is_locked:
			dice.reset_and_reroll()
	rerolls_remaining = 2
	
	for dice in all_dice:
		dice.is_settled = false
		dice.is_locked = false
	
	update_button_text()

func end_rolls():
	if current_state != GameState.PLAYER_ROLLING:
		return
	
	current_state = GameState.PLAYER_ACTIONS
	print("=== PLAYER ACTIONS PHASE ===")
	update_button_text()

func end_turn():
	current_state = GameState.ENEMY_EXECUTE
	print("=== ENEMY EXECUTES ===")
	for dice in all_dice:
		dice.is_locked = false
	execute_enemy_turn()
	update_button_text()

func execute_enemy_turn():
	for i in range(current_enemies.size()):
		var attack = current_enemy_attacks[i]
		var target = party[attack["target"]]
		var damage = attack["damage"]
		
		target.take_damage(damage)
		print("Enemy %d dealt %d damage to %s" % [i, damage, target.character_name])
	
	update_party_display()
	
	var all_dead = party.all(func(c): return c.current_hp <= 0)
	if all_dead:
		print("PARTY DEFEATED!")
		return
	
	var all_enemies_dead = current_enemies.all(func(e): return not e.is_alive)
	if all_enemies_dead:
		print("ENEMIES DEFEATED!")
		return
	
	start_enemy_phase()

func _on_phase_button_pressed() -> void:
	if current_state == GameState.PLAYER_ROLLING:
		end_rolls()
	elif current_state == GameState.PLAYER_ACTIONS:
		end_turn()
	


func _on_button_pressed() -> void:
	reroll_dice()
