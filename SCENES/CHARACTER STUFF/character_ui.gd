extends MarginContainer

@export var hp_label: Label
@export var sprite_rect: TextureRect
@export var name_label: Label
@export var ability_button: Button
@export var highlight: ColorRect

var character: Character
var board:Node3D

func _process(delta: float) -> void:
	if not is_node_valid(ability_button):
		return
	if character.ability:
		if character.ability.ability_type == "passive":
			ability_button.disabled = true  # Always disabled
		else:
			# Only active abilities toggle based on state
			if GameManager.is_state(GameManager.GameState.PLAYER_ACTIONS):
				ability_button.disabled = false
			else:
				ability_button.disabled = true
				
	if board.action_targeting == "ALLY_TARGETED" and not board.pending_action.is_empty():
		highlight.show()
	else:
		highlight.hide()
func setup(char: Character):
	character = char
	name_label.text = char.character_name
	if char.ability:
		ability_button.text = char.ability.name
		ability_button.tooltip_text = char.ability.description
		if char.ability.ability_type == "passive":
			ability_button.disabled = true
	update_hp()

func update_hp():
	var shield_text = ""
	if character.shield > 0:
		shield_text = " +%d" % character.shield
	hp_label.text = "%d/%d%s" % [character.current_hp, character.max_hp, shield_text]
	
	
	
func highlight_as_target():
	modulate = Color.RED

func unhighlight():
	modulate = Color.WHITE

func _on_ability_button_pressed() -> void:
	if not GameManager.is_state(GameManager.GameState.PLAYER_ACTIONS):
		ability_button.button_pressed = false
		return
	
	# Check mana cost
	if GameManager.current_mana < character.ability.mana_cost:
		print("Not enough mana! Need %d, have %d" % [character.ability.mana_cost, GameManager.current_mana])
		ability_button.button_pressed = false
		return
	
	var buttons = get_tree().get_nodes_in_group("action_button")
	for button in buttons:
		button.button_pressed = false
	ability_button.button_pressed = true
	
	board.find_action_targeting(character.ability.effect["effects"])
	print("Selected ability: %s" % character.ability.name)
	print("targeting system :", board.action_targeting)
	
	board.pending_action = {
		"face_data": character.ability.effect,
		"character": character,
		"button": ability_button,
		"is_ability": true,
		"mana_cost": character.ability.mana_cost
	}


func _on_highlight_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		board.combat_manager.execute_targeted_action(character, false)
		update_hp()

func is_node_valid(node) -> bool:
	return is_instance_valid(node) and not node.is_queued_for_deletion()
