extends MarginContainer

@export var hp_label: Label
@export var sprite_rect: TextureRect
@export var name_label: Label
@export var ability_button: Button
@export var highlight: ColorRect
@export var incoming: Label

var character: Character
var board:Node3D
var incoming_damage: int = 0

func _process(delta: float) -> void:
	if not is_node_valid(ability_button):
		return
	
	if character.ability:
		if character.ability.ability_type == "passive":
			ability_button.disabled = true
		else:
			# Disable if taunt was used, not enough mana, or not in action phase
			if character.taunt_used_this_phase:
				ability_button.disabled = true
			elif GameManager.current_mana < character.ability.mana_cost:
				ability_button.disabled = true
			elif GameManager.is_state(GameManager.GameState.PLAYER_ACTIONS):
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
	
func show_incoming_damage(damage: int) -> void:
	incoming_damage += damage
	incoming.text = "-%d" % incoming_damage

func update_hp():
	var shield_text = ""
	if character.shield > 0:
		shield_text = " +%d" % character.shield
	hp_label.text = "%d/%d%s" % [character.current_hp, character.max_hp, shield_text]
	
	
	


func unhighlight() -> void:
	modulate = Color.WHITE
	incoming_damage = 0
	incoming.text = ""


func _on_ability_button_pressed() -> void:
	if not GameManager.is_state(GameManager.GameState.PLAYER_ACTIONS):
		ability_button.button_pressed = false
		return
	
	# Check if already used
	if character.taunt_used_this_phase:
		print("Taunt already used this phase")
		ability_button.button_pressed = false
		ability_button.disabled = true
		return
	
	# Check mana cost
	if GameManager.current_mana < character.ability.mana_cost:
		print("Not enough mana! Need %d, have %d" % [character.ability.mana_cost, GameManager.current_mana])
		ability_button.button_pressed = false
		return
	
	# Deselect all other action buttons
	var buttons = get_tree().get_nodes_in_group("action_button")
	for button in buttons:
		button.button_pressed = false
	
	# Deselect all OTHER ability buttons
	var ability_buttons = get_tree().get_nodes_in_group("ability_button")
	for button in ability_buttons:
		if button != ability_button:
			button.button_pressed = false
	
	ability_button.button_pressed = true
	
	board.find_action_targeting(character.ability.effect["effects"])
	print("Selected ability: %s" % character.ability.name)
	
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
		
func reset_ability_button() -> void:
	if character.ability and character.ability.ability_type == "active":
		ability_button.disabled = false
		ability_button.button_pressed = false

func is_node_valid(node) -> bool:
	return is_instance_valid(node) and not node.is_queued_for_deletion()
