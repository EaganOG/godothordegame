extends Control

@onready var play_button = $MarginContainer/VBoxContainer/Play
@onready var settings_button = $MarginContainer/VBoxContainer/Settings
@onready var exit_button = $MarginContainer/VBoxContainer/Exit

func _ready() -> void:
	# Connect button signals
	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	exit_button.pressed.connect(_on_exit_pressed)

func _on_play_pressed():
	# Go to class selection scene
	get_tree().change_scene_to_file("res://ClassSelection.tscn")

func _on_settings_pressed():
	# Go to settings scene
	get_tree().change_scene_to_file("res://Settings.tscn")

func _on_exit_pressed():
	# Quit the game
	get_tree().quit()
