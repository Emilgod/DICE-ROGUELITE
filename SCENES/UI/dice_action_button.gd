extends Button


var face_data: Dictionary
var dice: Node3D
var character: Character
var on_action_callback: Callable

func setup(p_face_data: Dictionary, p_dice: Node3D, p_character: Character, callback: Callable):
	face_data = p_face_data
	dice = p_dice
	character = p_character
	on_action_callback = callback
	
	# Display the dice info
	text = "%s: %d %s" % [character.character_name, face_data["value"], ", ".join(face_data["effects"])]

func _on_pressed() -> void:
	pass # Replace with function body.
