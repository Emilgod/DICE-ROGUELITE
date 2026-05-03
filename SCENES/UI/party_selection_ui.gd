extends Control

@export var starting_ui: Control
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_back_pressed() -> void:
	starting_ui.show()
	hide()
func start_game():
	get_tree().change_scene_to_file("res://SCENES/MAIN/main.tscn")

func _on_classic_button_pressed() -> void:
	GameManager.selected_party = "classic"
	start_game()
	pass # Replace with function body.


func _on_crazy_button_pressed() -> void:
	GameManager.selected_party = "crazy"
	start_game()
	pass # Replace with function body.
