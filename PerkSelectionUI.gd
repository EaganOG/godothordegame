# PerkSelectionUI.gd
extends Control

@onready var perk_button_1 = $CenterContainer/PanelContainer/VBoxContainer/MarginContainer/VBoxContainer/PerkChoices/PerkChoice1/PerkButton1
@onready var perk_button_2 = $CenterContainer/PanelContainer/VBoxContainer/MarginContainer/VBoxContainer/PerkChoices/PerkChoice2/PerkButton2
@onready var perk_button_3 = $CenterContainer/PanelContainer/VBoxContainer/MarginContainer/VBoxContainer/PerkChoices/PerkChoice3/PerkButton3

@onready var perk_name_1 = $CenterContainer/PanelContainer/VBoxContainer/MarginContainer/VBoxContainer/PerkChoices/PerkChoice1/PerkName1
@onready var perk_name_2 = $CenterContainer/PanelContainer/VBoxContainer/MarginContainer/VBoxContainer/PerkChoices/PerkChoice2/PerkName2
@onready var perk_name_3 = $CenterContainer/PanelContainer/VBoxContainer/MarginContainer/VBoxContainer/PerkChoices/PerkChoice3/PerkName3

@onready var perk_desc_1 = $CenterContainer/PanelContainer/VBoxContainer/MarginContainer/VBoxContainer/PerkChoices/PerkChoice1/PerkDesc1
@onready var perk_desc_2 = $CenterContainer/PanelContainer/VBoxContainer/MarginContainer/VBoxContainer/PerkChoices/PerkChoice2/PerkDesc2
@onready var perk_desc_3 = $CenterContainer/PanelContainer/VBoxContainer/MarginContainer/VBoxContainer/PerkChoices/PerkChoice3/PerkDesc3

@onready var perk_rarity_1 = $CenterContainer/PanelContainer/VBoxContainer/MarginContainer/VBoxContainer/PerkChoices/PerkChoice1/PerkRarity1
@onready var perk_rarity_2 = $CenterContainer/PanelContainer/VBoxContainer/MarginContainer/VBoxContainer/PerkChoices/PerkChoice2/PerkRarity2
@onready var perk_rarity_3 = $CenterContainer/PanelContainer/VBoxContainer/MarginContainer/VBoxContainer/PerkChoices/PerkChoice3/PerkRarity3

var current_perk_choices: Array[Perk] = []
var player_reference

signal perk_chosen(perk: Perk)

func _ready():
	# Connect button signals
	perk_button_1.pressed.connect(_on_perk_1_selected)
	perk_button_2.pressed.connect(_on_perk_2_selected)
	perk_button_3.pressed.connect(_on_perk_3_selected)
	
	# Hide initially
	visible = false
	
	# Debug: Check if all nodes are found
	var missing_nodes = []
	if not perk_button_1: missing_nodes.append("perk_button_1")
	if not perk_button_2: missing_nodes.append("perk_button_2")
	if not perk_button_3: missing_nodes.append("perk_button_3")
	if not perk_name_1: missing_nodes.append("perk_name_1")
	if not perk_name_2: missing_nodes.append("perk_name_2")
	if not perk_name_3: missing_nodes.append("perk_name_3")
	if not perk_desc_1: missing_nodes.append("perk_desc_1")
	if not perk_desc_2: missing_nodes.append("perk_desc_2")
	if not perk_desc_3: missing_nodes.append("perk_desc_3")
	if not perk_rarity_1: missing_nodes.append("perk_rarity_1")
	if not perk_rarity_2: missing_nodes.append("perk_rarity_2")
	if not perk_rarity_3: missing_nodes.append("perk_rarity_3")
	
	if missing_nodes.size() > 0:
		print("WARNING: Missing UI nodes: ", missing_nodes)

func show_perk_selection(perks: Array[Perk], player):
	current_perk_choices = perks
	player_reference = player
	
	# Ensure we're in the scene tree before pausing
	if not is_inside_tree():
		await tree_entered
	
	# Pause the game
	get_tree().paused = true
	
	# Show the UI
	visible = true
	
	# Update the UI with perk information
	update_perk_display()

func update_perk_display():
	var buttons = [perk_button_1, perk_button_2, perk_button_3]
	var names = [perk_name_1, perk_name_2, perk_name_3]
	var descriptions = [perk_desc_1, perk_desc_2, perk_desc_3]
	var rarities = [perk_rarity_1, perk_rarity_2, perk_rarity_3]
	
	for i in range(min(current_perk_choices.size(), 3)):
		var perk = current_perk_choices[i]
		
		# Safety checks before updating UI elements
		if names[i] != null:
			names[i].text = perk.name
		else:
			print("ERROR: perk_name_", i+1, " is null")
			
		if descriptions[i] != null:
			descriptions[i].text = perk.description
		else:
			print("ERROR: perk_desc_", i+1, " is null")
			
		if rarities[i] != null:
			rarities[i].text = get_rarity_text(perk.rarity)
			# Update rarity label color
			update_rarity_color(rarities[i], perk.rarity)
		else:
			print("ERROR: perk_rarity_", i+1, " is null")
		
		# Update button style based on rarity
		if buttons[i] != null:
			update_button_style(buttons[i], perk.rarity)
		else:
			print("ERROR: perk_button_", i+1, " is null")
		
		# Check if perk can be stacked
		var existing_perk = PerkManager.find_existing_perk(perk.name)
		if existing_perk and existing_perk.current_stacks < existing_perk.max_stacks and names[i] != null:
			var stack_text = " (" + str(existing_perk.current_stacks + 1) + "/" + str(existing_perk.max_stacks) + ")"
			names[i].text += stack_text

func update_button_style(button: Button, rarity: Perk.PerkRarity):
	var style_box = StyleBoxFlat.new()
	style_box.corner_radius_top_left = 10
	style_box.corner_radius_top_right = 10
	style_box.corner_radius_bottom_left = 10
	style_box.corner_radius_bottom_right = 10
	style_box.border_width_left = 3
	style_box.border_width_top = 3
	style_box.border_width_right = 3
	style_box.border_width_bottom = 3
	
	match rarity:
		Perk.PerkRarity.COMMON:
			style_box.bg_color = Color(0.8, 0.8, 0.8, 0.3)
			style_box.border_color = Color(0.9, 0.9, 0.9, 1.0)
		Perk.PerkRarity.UNCOMMON:
			style_box.bg_color = Color(0.3, 0.8, 0.3, 0.3)
			style_box.border_color = Color(0.4, 1.0, 0.4, 1.0)
		Perk.PerkRarity.RARE:
			style_box.bg_color = Color(0.3, 0.3, 0.8, 0.3)
			style_box.border_color = Color(0.4, 0.4, 1.0, 1.0)
		Perk.PerkRarity.EPIC:
			style_box.bg_color = Color(0.8, 0.3, 0.8, 0.3)
			style_box.border_color = Color(1.0, 0.4, 1.0, 1.0)
	
	button.add_theme_stylebox_override("normal", style_box)
	button.add_theme_stylebox_override("hover", style_box)
	button.add_theme_stylebox_override("pressed", style_box)

func update_rarity_color(label: Label, rarity: Perk.PerkRarity):
	match rarity:
		Perk.PerkRarity.COMMON:
			label.add_theme_color_override("font_color", Color.WHITE)
		Perk.PerkRarity.UNCOMMON:
			label.add_theme_color_override("font_color", Color.GREEN)
		Perk.PerkRarity.RARE:
			label.add_theme_color_override("font_color", Color.BLUE)
		Perk.PerkRarity.EPIC:
			label.add_theme_color_override("font_color", Color.MAGENTA)

func get_rarity_text(rarity: Perk.PerkRarity) -> String:
	match rarity:
		Perk.PerkRarity.COMMON:
			return "COMMON"
		Perk.PerkRarity.UNCOMMON:
			return "UNCOMMON"
		Perk.PerkRarity.RARE:
			return "RARE"
		Perk.PerkRarity.EPIC:
			return "EPIC"
		_:
			return "COMMON"

func _on_perk_1_selected():
	select_perk(0)

func _on_perk_2_selected():
	select_perk(1)

func _on_perk_3_selected():
	select_perk(2)

func select_perk(index: int):
	if index < current_perk_choices.size():
		var selected_perk = current_perk_choices[index]
		
		# Apply the perk to the player
		PerkManager.apply_perk(selected_perk, player_reference)
		
		# Emit signal for any listeners
		perk_chosen.emit(selected_perk)
		
		# Hide the UI and unpause the game
		visible = false
		
		# Ensure we're still in the scene tree before unpausing
		if is_inside_tree():
			get_tree().paused = false
		
		print("Selected perk: ", selected_perk.name)
