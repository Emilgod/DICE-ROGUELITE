extends Control
@export var starting_ui: Control
@export var party_selection: Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_play_pressed() -> void:
	starting_ui.hide()
	party_selection.show()
