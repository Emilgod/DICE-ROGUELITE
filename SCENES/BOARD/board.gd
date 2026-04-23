extends Node3D

@onready var camera_3d: Camera3D = $Camera3D
@onready var dice_container: Node3D = $dice_container
@onready var button: Button = $UI/Button

@export var actions_container: VBoxContainer
var rerolls_remaining:int  = 2
var player_data: PlayerData
var dice_scene = preload("res://SCENES/DICE/dice.tscn")
var all_dice = []
var dice_templates = preload("res://DICE_TEMPLATES/dice_templates.gd")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button.disabled
	player_data = dice_templates.get_character_1()
	spawn_dice()
	update_button_text()
	create_placeholder_buttons()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		# Raycast to find which dice was clicked
		var mouse_pos = get_viewport().get_mouse_position()
		var from = camera_3d.project_ray_origin(mouse_pos)
		var normal = camera_3d.project_ray_normal(mouse_pos)
		
		var query = PhysicsRayQueryParameters3D.create(from, from + normal * 1000)
		var result = get_world_3d().direct_space_state.intersect_ray(query)
		
		if result and result.collider.is_in_group("dice"):
			result.collider.toggle_lock()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_dice_results()
	var all_settled = all_dice.all(func(d): return d.is_settled)
	button.disabled = not all_settled
	
	# Update button text color or appearance if disabled
	if button.disabled:
		button.modulate = Color.GRAY
	else:
		button.modulate = Color.WHITE

func spawn_dice():
	for dice_template in player_data.dice_pool:
		spawn_die(dice_template)
	
func spawn_die(template: DiceData):
	var dice = dice_scene.instantiate()
	dice_container.add_child(dice)
	
	dice.set_sides(template.sides)
	dice.reset_and_reroll()
	all_dice.append(dice)


func update_button_text():
	if rerolls_remaining == 1:
		button.text = "1 REROLL"
	elif rerolls_remaining == 0:
		button.text = "0 REROLLS"
	else:
		button.text = "%d REROLLS" % [rerolls_remaining]

func create_placeholder_buttons() -> void:
	# Create 5 placeholder buttons (one for each die)
	for i in range(3):
		var placeholder = Button.new()
		placeholder.text = "Die %d" % (i + 1)
		placeholder.disabled = true
		placeholder.modulate = Color.GRAY
		actions_container.add_child(placeholder)

func update_dice_results():
	# Update existing buttons instead of recreating them
	for i in range(all_dice.size()):
		var dice = all_dice[i]
		var button = actions_container.get_child(i)
		
		if dice.is_settled:
			var top_face = dice.get_top_face()
			var face_data = dice.sides_data[top_face]
			
			button.text = "Die %d: %d %s" % [i + 1, face_data["value"], ", ".join(face_data["effects"])]
			button.disabled = false
			button.modulate = Color.WHITE
			
			# Disconnect ALL previous signals
			for sig in button.pressed.get_connections():
				button.pressed.disconnect(sig.callable)
			
			# Connect new signal
			button.pressed.connect(func(): on_action_selected(face_data, dice))
		else:
			button.text = "Die %d" % (i + 1)
			button.disabled = true
			button.modulate = Color.GRAY

func on_action_selected(face_data: Dictionary, dice: Node3D) -> void:
	print("Selected: ", face_data, " from dice: ", dice)
	# TODO: Target enemy with this action

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
