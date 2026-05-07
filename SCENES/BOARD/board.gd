extends Node3D

@onready var camera_3d: Camera3D = $Camera3D
@onready var dice_container: Node3D = $dice_container
@onready var button: Button = $UI/Button
@export var actions_container: VBoxContainer
@export var party_container: HBoxContainer
@export var enemy_container: HBoxContainer
@export var phase_button: Button

var dice_scene = preload("res://SCENES/DICE/dice.tscn")
var hero_templates = preload("res://hero_templates/hero_templates.gd")
var enemy_templates = preload("res://enemy_templates/enemy_templates.gd")
var character_panel_scene = preload("res://SCENES/CHARACTER STUFF/character_ui.tscn")
var dice_action_button_scene = preload("res://SCENES/UI/dice_action_button.tscn")

var party: Array[Character] = []
var all_dice = []
var dice_to_character = {}
var current_enemies: Array[Enemy] = []
var current_enemy_attacks: Array[Dictionary] = []
var rerolls_remaining: int = 2
var dice_results_updated: bool = false

func _ready() -> void:
	setup_with_party(GameManager.selected_party)
	setup_party_display()
	spawn_dice()
	setup_encounter()
	phase_button.pressed.connect(_on_phase_button_pressed)
	button.pressed.connect(_on_button_pressed)
	start_enemy_phase()

func setup_party_display():
	for character in party:
		var panel = character_panel_scene.instantiate()
		party_container.add_child(panel)
		panel.setup(character)

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
	elif GameManager.is_state(GameManager.GameState.PLAYER_ROLLING):
		dice_results_updated = false  # Reset when leaving rolling phase
	
	if GameManager.is_state(GameManager.GameState.PLAYER_ACTIONS):
		for dice in all_dice:
			dice.is_settled = false
			dice.is_locked = false
			dice.update_outline()
		if all_settled and not dice_results_updated:
			update_dice_results()
			dice_results_updated = true
			


func update_dice_results():
	for i in range(all_dice.size()):
		var dice = all_dice[i]
		var button = actions_container.get_child(i)
		var character = dice_to_character[dice]
		
		if dice.is_settled:
			var top_face = dice.get_top_face()
			var face_data = dice.sides_data[top_face]
			
			var action_button = dice_action_button_scene.instantiate()
			actions_container.add_child(action_button)
			action_button.setup(face_data, dice, character, Callable(self, "on_action_selected"))


func on_action_selected(face_data: Dictionary, dice, character: Character) -> void:
	if not GameManager.is_state(GameManager.GameState.PLAYER_ACTIONS):
		return
	
	print("Selected from %s: " % character.character_name, face_data)
	# TODO: Combat logic here

func reroll_dice():
	if not GameManager.is_state(GameManager.GameState.PLAYER_ROLLING):
		return
	if rerolls_remaining <= 0:
		end_rolls()
		return
	rerolls_remaining -= 1

	for child in actions_container.get_children():
		child.free()
		
	dice_results_updated = false
	
	for dice in all_dice:
		if not dice.is_locked:
			dice.reset_and_reroll()
	if rerolls_remaining == 0:
		
		end_rolls()

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
	GameManager.set_state(GameManager.GameState.ENEMY_PHASE)
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
	GameManager.set_state(GameManager.GameState.PLAYER_ROLLING)
	print("=== PLAYER ROLLING PHASE ===")
	rerolls_remaining = 2
	for child in actions_container.get_children():
		child.queue_free()
	dice_results_updated = false
	
	for dice in all_dice:
		dice.is_settled = false
		dice.is_locked = false
		dice.update_outline()
		dice.reset_and_reroll()
	update_button_text()

func end_rolls():
	if not GameManager.is_state(GameManager.GameState.PLAYER_ROLLING):
		return
	button.hide()
	
	GameManager.set_state(GameManager.GameState.PLAYER_ACTIONS)
	print("=== PLAYER ACTIONS PHASE ===")
	update_button_text()

func end_turn():
	if not GameManager.is_state(GameManager.GameState.PLAYER_ACTIONS):
		return
	button.show()
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
