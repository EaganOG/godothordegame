# GameManager.gd - Add as Autoload/Singleton in Project Settings
extends Node

var selected_player_class: PlayerClass

func _ready():
	# Default to archer if no class selected
	if not selected_player_class:
		selected_player_class = PlayerClass.create_archer()
