extends Button


var face_data: Dictionary
var dice: Node3D
var character: Character
var on_action_callback: Callable
var board:Node3D

func _process(delta: float) -> void:
	if GameManager.is_state(GameManager.GameState.PLAYER_ACTIONS):
		disabled = false
	else:
		disabled = true
		
func setup(p_face_data: Dictionary, p_dice: Node3D, p_character: Character, callback: Callable):
	face_data = p_face_data
	dice = p_dice
	character = p_character
	on_action_callback = callback
	
	# Display the dice info
	text = "%s: %d %s" % [character.character_name, face_data["value"], ", ".join(face_data["effects"])]

func _on_pressed() -> void:
	if not GameManager.is_state(GameManager.GameState.PLAYER_ACTIONS):
		button_pressed = false
		return
	var buttons = get_tree().get_nodes_in_group("action button")
	for button in buttons:
		button.button_pressed = false
	button_pressed = true
	
	board.selected_action = {
		"type": "dice",
		"face_data": face_data,
		"character": character
	}
	print("Selected dice action: ", board.selected_action)
