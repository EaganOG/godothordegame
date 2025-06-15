# LevelUpUI.gd
extends Control

var perk_container: HBoxContainer
var title_label: Label
var level_label: Label
var background: Panel

var available_perks: Array[Perk] = []
var perk_manager: PerkManager
var player: CharacterBody2D

signal perk_selected(perk: Perk)

func _ready():
	visible = false
	# Connect to our own signal to handle perk selection
	perk_selected.connect(_on_perk_selected)
	
	# Find UI components
	find_ui_components()

func find_ui_components():
	# Try to find the components with multiple possible paths
	perk_container = find_child("PerkContainer", true, false) as HBoxContainer
	title_label = find_child("TitleLabel", true, false) as Label
	level_label = find_child("LevelLabel", true, false) as Label
	background = find_child("Background", true, false) as Panel
	
	# Debug output
	print("Found UI components:")
	print("  PerkContainer: ", perk_container)
	print("  TitleLabel: ", title_label)
	print("  LevelLabel: ", level_label)
	print("  Background: ", background)

func show_level_up(player_ref: CharacterBody2D, perk_manager_ref: PerkManager):
	player = player_ref
	perk_manager = perk_manager_ref
	
	# Generate random perks for this level
	available_perks = perk_manager.generate_random_perks(player.level, 3)
	
	# Update UI - check if nodes exist first
	if level_label:
		level_label.text = "Level %d Reached!" % player.level
	if title_label:
		title_label.text = "Choose Your Perk"
	
	# Create perk buttons
	create_perk_buttons()
	
	# Show UI and pause game
	visible = true
	get_tree().paused = true

func create_perk_buttons():
	# Check if perk_container exists
	if not perk_container:
		print("Error: perk_container not found!")
		return
		
	# Clear existing buttons
	for child in perk_container.get_children():
		child.queue_free()
	
	# Create buttons for each available perk
	for i in range(available_perks.size()):
		var perk = available_perks[i]
		var perk_button = create_perk_button(perk, i)
		perk_container.add_child(perk_button)

func create_perk_button(perk: Perk, index: int) -> Control:
	# Create main container
	var perk_panel = Panel.new()
	perk_panel.custom_minimum_size = Vector2(300, 120)
	
	# Create VBox for layout
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 5)
	perk_panel.add_child(vbox)
	
	# Add margins
	var margin_container = MarginContainer.new()
	margin_container.add_theme_constant_override("margin_left", 10)
	margin_container.add_theme_constant_override("margin_right", 10)
	margin_container.add_theme_constant_override("margin_top", 10)
	margin_container.add_theme_constant_override("margin_bottom", 10)
	vbox.add_child(margin_container)
	
	var content_vbox = VBoxContainer.new()
	content_vbox.add_theme_constant_override("separation", 3)
	margin_container.add_child(content_vbox)
	
	# Perk name with rarity color
	var name_label = RichTextLabel.new()
	name_label.custom_minimum_size.y = 30
	name_label.fit_content = true
	name_label.scroll_active = false
	var color_hex = perk.get_rarity_color().to_html()
	name_label.text = "[color=%s][b]%s[/b][/color]" % [color_hex, perk.perk_name]
	content_vbox.add_child(name_label)
	
	# Rarity label
	var rarity_label = Label.new()
	rarity_label.text = perk.get_rarity_name()
	rarity_label.modulate = perk.get_rarity_color()
	rarity_label.add_theme_font_size_override("font_size", 12)
	content_vbox.add_child(rarity_label)
	
	# Description
	var desc_label = RichTextLabel.new()
	desc_label.custom_minimum_size.y = 40
	desc_label.fit_content = true
	desc_label.scroll_active = false
	desc_label.text = perk.description
	content_vbox.add_child(desc_label)
	
	# Current stacks info
	var current_stacks = perk_manager.get_perk_stacks(perk.perk_type, perk.rarity)
	var stacks_label = Label.new()
	stacks_label.text = "Current: %d/%d" % [current_stacks, perk.max_stacks]
	stacks_label.add_theme_font_size_override("font_size", 10)
	stacks_label.modulate = Color.GRAY
	content_vbox.add_child(stacks_label)
	
	# Make the panel clickable
	var button = Button.new()
	button.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	button.flat = true
	button.pressed.connect(_on_perk_button_pressed.bind(index))
	perk_panel.add_child(button)
	
	# Add hover effects
	button.mouse_entered.connect(_on_perk_hover.bind(perk_panel, true))
	button.mouse_exited.connect(_on_perk_hover.bind(perk_panel, false))
	
	return perk_panel

func _on_perk_button_pressed(perk_index: int):
	if perk_index < available_perks.size():
		var selected_perk = available_perks[perk_index]
		perk_selected.emit(selected_perk)

func _on_perk_hover(panel: Panel, is_hovering: bool):
	if is_hovering:
		panel.modulate = Color(1.1, 1.1, 1.1)
	else:
		panel.modulate = Color.WHITE

func _on_perk_selected(perk: Perk):
	# Add perk to manager
	perk_manager.add_perk(perk)
	
	# Apply perk effects to player
	player.apply_perk_multipliers()
	
	# Hide UI and unpause game
	visible = false
	get_tree().paused = false
	
	print("Selected perk: ", perk.perk_name, " (", perk.get_rarity_name(), ")")

# Handle ESC key to prevent accidental pausing during perk selection
func _input(event):
	if visible and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()  # Consume the input
