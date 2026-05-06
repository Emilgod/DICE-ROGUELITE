extends Node

var selected_party: String = "default"
enum GameState { PLAYER_EXPLORING, ENEMY_PHASE, PLAYER_ROLLING, PLAYER_ACTIONS, ENEMY_EXECUTE }

var current_state: GameState = GameState.ENEMY_PHASE

func set_state(new_state: GameState) -> void:
	current_state = new_state
	print("State changed to: ", GameState.keys()[current_state])

func is_state(state: GameState) -> bool:
	return current_state == state
