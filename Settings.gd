extends Control

@onready var resolution_option = $VBoxContainer/SettingsContainer/ResolutionContainer/ResolutionOption
@onready var fullscreen_check = $VBoxContainer/SettingsContainer/FullscreenContainer/FullscreenCheck
@onready var back_button = $VBoxContainer/ButtonContainer/BackButton
@onready var apply_button = $VBoxContainer/ButtonContainer/ApplyButton

# Available resolutions
var resolutions = [
	Vector2i(1280, 720),
	Vector2i(1366, 768),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440),
	Vector2i(3840, 2160)
]

var current_resolution_index = 0
var current_fullscreen = false

func _ready():
	setup_resolution_options()
	load_current_settings()

func setup_resolution_options():
	# Add resolution options to the dropdown
	for res in resolutions:
		resolution_option.add_item(str(res.x) + " x " + str(res.y))

func load_current_settings():
	# Get current window settings
	var current_size = DisplayServer.window_get_size()
	current_fullscreen = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	
	# Find matching resolution
	for i in range(resolutions.size()):
		if resolutions[i] == current_size:
			current_resolution_index = i
			break
	
	# Set UI to current settings
	resolution_option.selected = current_resolution_index
	fullscreen_check.button_pressed = current_fullscreen

func _on_resolution_option_item_selected(index: int):
	current_resolution_index = index

func _on_fullscreen_check_toggled(button_pressed: bool):
	current_fullscreen = button_pressed

func _on_apply_button_pressed():
	# Apply resolution changes
	var new_resolution = resolutions[current_resolution_index]
	
	if current_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(new_resolution)
		
		# Center the window
		var screen_size = DisplayServer.screen_get_size()
		var window_pos = (screen_size - new_resolution) / 2
		DisplayServer.window_set_position(window_pos)
	
	# Save settings (optional - you can add this to persist settings)
	save_settings()

func save_settings():
	# Save settings to a config file
	var config = ConfigFile.new()
	config.set_value("display", "resolution_width", resolutions[current_resolution_index].x)
	config.set_value("display", "resolution_height", resolutions[current_resolution_index].y)
	config.set_value("display", "fullscreen", current_fullscreen)
	config.save("user://settings.cfg")

func load_saved_settings():
	# Load settings from config file
	var config = ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		var width = config.get_value("display", "resolution_width", 1920)
		var height = config.get_value("display", "resolution_height", 1080)
		current_fullscreen = config.get_value("display", "fullscreen", false)
		
		# Find matching resolution
		var saved_res = Vector2i(width, height)
		for i in range(resolutions.size()):
			if resolutions[i] == saved_res:
				current_resolution_index = i
				break

func _on_back_button_pressed():
	# Return to main menu
	get_tree().change_scene_to_file("res://Mainmenu.tscn")
