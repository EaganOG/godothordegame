# ui.gd
extends CanvasLayer

@onready var health_bar = $MarginContainer/VBoxContainer/Health
@onready var stamina_bar = $MarginContainer/VBoxContainer/Stamina
@onready var exp_bar = $MarginContainer/VBoxContainer/exp
@onready var level_label = $MarginContainer/VBoxContainer/Level

func update_ui(player):
	scale = Vector2(1.5, 1.5)
	health_bar.value = player.health
	health_bar.max_value = player.max_health
	
	stamina_bar.value = player.stamina
	stamina_bar.max_value = player.max_stam
	
	exp_bar.value = player.exp
	exp_bar.max_value = player.req_exp
	
	level_label.text = "Level: %d" % player.level
