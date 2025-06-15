# GameManager.gd - Add as Autoload/Singleton in Project Settings
extends Node

var selected_player_class: PlayerClass

func _ready():
	# Default to slug if no class selected
	if not selected_player_class:
		selected_player_class = PlayerClass.create_slug()

# Debug function to give player experience (for testing)
func _input(event):
	if event.is_action_pressed("ui_accept"):  # Enter key
		var player = get_tree().get_first_node_in_group("player")
		if player and player.has_method("gain_exp"):
			player.gain_exp(5000)  # Give 50 exp for testing
			print("Gave 50 EXP to player (Level: %d, EXP: %d/%d)" % [player.level, player.exp, player.req_exp])

# Function to reset player perks (useful for testing)
func reset_player_perks():
	var player = get_tree().get_first_node_in_group("player")
	if player and player.perk_manager:
		player.perk_manager.reset_perks()
		player.apply_perk_multipliers()
		print("Reset all player perks")

# Function to get player's current perks (useful for debugging)
func get_player_perks() -> Array[String]:
	var player = get_tree().get_first_node_in_group("player")
	if player and player.perk_manager:
		return player.perk_manager.get_all_perks_summary()
	return []
