extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var play_button = $HFlowContainer/Play
	var settings_button = $HFlowContainer/Settings
	var exit_button = $HFlowContainer/Exit
	
	exit_button.pressed.connect(_on_exit_pressed)
	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(_on_settings_pressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_exit_pressed():
	get_tree().quit()

func _on_play_pressed():
	get_tree().change_scene_to_file("res://ClassSelection.tscn")

func _on_settings_pressed():
	pass
