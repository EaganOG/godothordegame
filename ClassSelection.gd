# ClassSelection.gd
extends Control

@onready var class_container = $VBoxContainer/MainContainer/ClassContainer
@onready var class_name_label = $VBoxContainer/MainContainer/InfoPanel/ClassInfo/ClassName
@onready var class_description = $VBoxContainer/MainContainer/InfoPanel/ClassInfo/Description
@onready var stats_label = $VBoxContainer/MainContainer/InfoPanel/ClassInfo/Stats
@onready var abilities_label = $VBoxContainer/MainContainer/InfoPanel/ClassInfo/Abilities
@onready var select_button = $VBoxContainer/MainContainer/InfoPanel/SelectButton
@onready var back_button = $Button

var available_classes: Array[PlayerClass]
var selected_class: PlayerClass
var class_buttons: Array[Button] = []

signal class_selected(player_class: PlayerClass)

func _ready():
	# Check if PlayerClass exists, if not create a simple fallback
	if PlayerClass == null:
		push_error("PlayerClass not found! Make sure PlayerClass.gd is created.")
		return
	
	available_classes = PlayerClass.get_all_classes()
	create_class_buttons()
	
	if available_classes.size() > 0:
		select_class(available_classes[0])  # Select first class by default
		
	back_button.pressed.connect(_on_back_pressed)

func create_class_buttons():
	# Clear existing buttons
	for child in class_container.get_children():
		child.queue_free()
	
	class_buttons.clear()
	
	# Create buttons for each class
	for i in range(available_classes.size()):
		var player_class = available_classes[i]
		var button = Button.new()
		button.text = player_class.player_class_name
		button.custom_minimum_size = Vector2(150, 80)
		button.pressed.connect(_on_class_button_pressed.bind(i))
		
		class_container.add_child(button)
		class_buttons.append(button)

func _on_class_button_pressed(class_index: int):
	select_class(available_classes[class_index])

func select_class(player_class: PlayerClass):
	selected_class = player_class
	update_class_info()
	update_button_states()

func update_class_info():
	if not selected_class:
		return
	
	class_name_label.text = selected_class.player_class_name
	class_description.text = selected_class.description
	
	# Display stats
	var stats_text = "Stats:\n"
	stats_text += "Health: %d%%\n" % int(selected_class.health_multiplier * 100)
	stats_text += "Stamina: %d%%\n" % int(selected_class.stamina_multiplier * 100)
	stats_text += "Speed: %d%%\n" % int(selected_class.speed_multiplier * 100)
	stats_text += "Damage: %d%%\n" % int(selected_class.damage_multiplier * 100)
	stats_text += "Attack Speed: %d%%" % int(selected_class.attack_speed_multiplier * 100)
	stats_label.text = stats_text
	
	# Display abilities
	var abilities_text = "Special Abilities:\n"
	if selected_class.has_double_shot:
		abilities_text += "• Double Shot\n"
	if selected_class.has_piercing_arrows:
		abilities_text += "• Piercing Arrows\n"
	if selected_class.has_regeneration:
		abilities_text += "• Health Regeneration\n"
	if selected_class.has_dash:
		abilities_text += "• Dash Ability\n"
	
	abilities_text += "\nActive Abilities:\n"
	if selected_class.ability_1:
		abilities_text += "1: " + selected_class.ability_1.ability_name + "\n"
	if selected_class.ability_2:
		abilities_text += "2: " + selected_class.ability_2.ability_name + "\n"
	if selected_class.ability_3:
		abilities_text += "3: " + selected_class.ability_3.ability_name + "\n"
	
	if abilities_text == "Special Abilities:\n\nActive Abilities:\n":
		abilities_text += "• None"
	
	abilities_label.text = abilities_text

func update_button_states():
	for i in range(class_buttons.size()):
		var button = class_buttons[i]
		if available_classes[i] == selected_class:
			button.modulate = Color(1.2, 1.2, 1.2)  # Highlight selected
		else:
			button.modulate = Color(1, 1, 1)  # Normal

func _on_select_button_pressed():
	if selected_class:
		# Check if GameManager exists
		if not has_node("/root/GameManager"):
			push_error("GameManager not found! Make sure it's added as an Autoload.")
			return
		
		# Store the selected class globally
		GameManager.selected_player_class = selected_class
		# Change to main game scene (adjust path as needed)
		if ResourceLoader.exists("res://levels/testlevel.tscn"):
			get_tree().change_scene_to_file("res://levels/testlevel.tscn")
		else:
			print("main.tscn not found - replace with your main game scene path")
			print("Selected class: ", selected_class.player_class_name)

func _on_back_pressed():
	get_tree().change_scene_to_file("res://MainMenu.tscn")
