extends Node2D
class_name CombatManager

enum GameState { ENEMY_PHASE, PLAYER_ROLLING, PLAYER_ACTIONS, ENEMY_EXECUTE }

var current_state: GameState = GameState.ENEMY_PHASE
var party: Array[Character] = []
var current_enemies: Array[Enemy] = []
var current_enemy_attacks: Array[Dictionary] = []
var party_mana: int = 0
var rerolls_remaining: int = 2
