extends Node3D


@onready var camera_3d: Camera3D = $Camera3D
@onready var dice_container: Node3D = $dice_container
@onready var button: Button = $UI/Button
@export var actions_container: VBoxContainer
@export var party_container: HBoxContainer
@export var mana_label: Label
@export var enemy_container: HBoxContainer
@export var rerolls_remaining: int = 2
var dice_scene = preload("res://SCENES/DICE/dice.tscn")
var hero_templates = preload("res://hero_templates/hero_templates.gd")
var enemy_templates = preload("res://enemy_templates/enemy_templates.gd")
var character_panel_scene = preload("res://SCENES/CHARACTER STUFF/character_ui.tscn")
var party: Array[Character] = []
var all_dice = []
var dice_to_character = {}
var party_mana: int = 0
var current_enemy: Enemy
func _ready() -> void:
	setup_with_party(GameManager.selected_party)
	setup_party_display()
	spawn_dice()
	setup_encounter()
	update_button_text()
	create_placeholder_buttons()
	button.pressed.connect(_on_button_pressed)
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
		
		# Only hit dice, ignore everything else
		query.collide_with_areas = false
		query.collision_mask = 0
		query.collision_mask |= 1  # Adjust this to match your dice collision layer
		
		var result = get_world_3d().direct_space_state.intersect_ray(query)
		
		if result and result.collider.is_in_group("dice"):
			result.collider.toggle_lock()
			update_dice_results()

func _process(delta: float) -> void:
	update_dice_results()
	var all_settled = all_dice.all(func(d): return d.is_settled)
	button.disabled = not all_settled
	
	if button.disabled:
		button.modulate = Color.GRAY
	else:
		button.modulate = Color.WHITE

func update_button_text():
	if rerolls_remaining == 1:
		button.text = "1 REROLL"
	elif rerolls_remaining == 0:
		button.text = "0 REROLLS"
	else:
		button.text = "%d REROLLS" % [rerolls_remaining]

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
	print("Selected from %s: " % character.character_name, face_data)

func reroll_dice():
	if rerolls_remaining <= 0:
		print("no rerolls")
		return
	rerolls_remaining -= 1
	for dice in all_dice:
		if not dice.is_locked:
			dice.reset_and_reroll()
	update_button_text()

func _on_button_pressed() -> void:
	reroll_dice()

func setup_encounter():
	current_enemy = enemy_templates.get_goblin()
	
	var enemy_ui = load("res://enemy_templates/enemy_ui.tscn").instantiate()
	enemy_container.add_child(enemy_ui)
	enemy_ui.setup(current_enemy)
