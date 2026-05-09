extends MarginContainer

@export var hp_label: Label
@export var sprite_rect: TextureRect
@export var name_label: Label
@export var ability_button: Button

var character: Character
var board:Node3D

func _process(delta: float) -> void:
	if character.ability:
		if character.ability.ability_type == "passive":
			ability_button.disabled = true  # Always disabled
		else:
			# Only active abilities toggle based on state
			if GameManager.is_state(GameManager.GameState.PLAYER_ACTIONS):
				ability_button.disabled = false
			else:
				ability_button.disabled = true
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
	hp_label.text = "%d/%d" % [character.current_hp, character.max_hp]

func highlight_as_target():
	modulate = Color.RED

func unhighlight():
	modulate = Color.WHITE

func _on_ability_button_pressed() -> void:
	if not GameManager.is_state(GameManager.GameState.PLAYER_ACTIONS):
		ability_button.button_pressed = false
		return
	var buttons = get_tree().get_nodes_in_group("action button")
	for button in buttons:
		button.button_pressed = false
	ability_button.button_pressed = true
	
	board.selected_action = {
		"type": "ability",
		"ability": character.ability,
		"character": character
	}
	print("Selected dice action: ", board.selected_action)
