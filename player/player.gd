extends CharacterBody2D
var ArrowScene = preload("res://player/Arrow.tscn")
var SlimeBomb = preload("res://Slimeball.tscn")
@onready var hurtbox = $hurtbox
@onready var camera = $Camera2D

@onready var ui = get_tree().current_scene.get_node("Ui")
@onready var health: int
@onready var max_health: int
@onready var stamina: int
@onready var max_stam: int
@onready var level = 1
@onready var exp = 0
@onready var req_exp = 100

var SPEED: int
var damage: int
var shoot_cooldown: float
var shoot_cooldown_timer = 0.0
var damage_cooldown = 0.5
var damage_timer = 0.0
var touching_enemies: Array[Node] = []

var auto_attack = false
var player_class: PlayerClass

# Ability system
var ability_cooldowns: Array[float] = [0.0, 0.0, 0.0]  # Cooldown timers for abilities 1, 2, 3

# Health Regeneration variables
var health_regen_timer = 0.0
var health_regen_rate = 1.0  # Regenerate 1 HP per second

# Stamina Regeneration variables
var stamina_regen_timer = 0.0
var stamina_regen_rate = 1.0

# Dash variables
var dash_cooldown = 2.0
var dash_timer = 0.0
var dash_speed = 1500
var dash_duration = 0.2
var is_dashing = false
var dash_duration_timer = 0.0

@onready var ray = $RayCast2D

# Perk system integration
var perk_manager: PerkManager
var level_up_ui: Control

func _ready():
	add_to_group("player")
	hurtbox.body_entered.connect(_on_HurtBox_body_entered)
	hurtbox.body_exited.connect(_on_HurtBox_body_exited)
	setup_vampire_survivors_camera()
	$Camera2D.position_smoothing_enabled = true
	$Camera2D.position_smoothing_speed = 5.0
	
	# Initialize perk system
	setup_perk_system()
	
	# Apply class stats
	apply_class_stats()

func setup_perk_system():
	# Create perk manager
	perk_manager = PerkManager.new()
	add_child.call_deferred(perk_manager)
	
	# Create simple level up UI directly in player script
	level_up_ui = create_simple_level_up_ui()
	get_tree().current_scene.add_child.call_deferred(level_up_ui)
	print("Level up UI creation deferred")

func create_simple_level_up_ui() -> Control:
	var ui = Control.new()
	ui.name = "LevelUpUI"
	ui.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	# Don't use preset - we'll position it manually at player location
	ui.visible = false
	ui.z_index = 1000  # Very high z-index to ensure it's on top
	ui.scale = Vector2(2.5,2.5)
	
	# Create a very visible overlay first
	var overlay = ColorRect.new()
	overlay.size = Vector2(800, 600)  # Fixed size instead of full screen
	overlay.position = Vector2(-400, -300)  # Center the overlay
	overlay.color = Color(1, 0, 0, 0.5)  # RED overlay so we can definitely see it
	ui.add_child(overlay)
	
	# Create background panel centered on the overlay
	var background = Panel.new()
	background.size = Vector2(600, 300)
	background.position = Vector2(-300, -150)  # Center it on the UI
	ui.add_child(background)
	
	# Add a bright background color to make it super visible
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0, 1, 0, 0)
	background.add_theme_stylebox_override("panel", style_box)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 20)
	background.add_child(vbox)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	vbox.add_child(margin)
	
	var content_vbox = VBoxContainer.new()
	margin.add_child(content_vbox)
	
	var level_label = Label.new()
	level_label.name = "LevelLabel"
	level_label.text = "Level Up!"
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_label.add_theme_font_size_override("font_size", 32)
	level_label.add_theme_color_override("font_color", Color.BLACK)  # Black text on green background
	content_vbox.add_child(level_label)
	
	var title_label = Label.new()
	title_label.name = "TitleLabel"
	title_label.text = "Choose Your Perk"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 20)
	title_label.add_theme_color_override("font_color", Color.BLACK)
	content_vbox.add_child(title_label)
	
	var separator = HSeparator.new()
	content_vbox.add_child(separator)
	
	var perk_container = HBoxContainer.new()
	perk_container.name = "PerkContainer"
	perk_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	perk_container.alignment = BoxContainer.ALIGNMENT_CENTER
	perk_container.add_theme_constant_override("separation", 20)
	content_vbox.add_child(perk_container)
	
	print("UI structure created with BRIGHT COLORS - will be positioned at player location!")
	return ui

# Handle level up UI directly in player script
func show_level_up_ui():
	print("show_level_up_ui called")
	
	if not level_up_ui:
		print("ERROR: level_up_ui is null!")
		handle_level_up_without_ui()
		return
		
	if not perk_manager:
		print("ERROR: perk_manager is null!")
		handle_level_up_without_ui()
		return
	
	# Position the UI at the player's world position
	level_up_ui.global_position = global_position
	print("Positioned UI at player location: ", global_position)
	
	var available_perks = perk_manager.generate_random_perks(level, 3)
	print("Generated %d perks for level %d" % [available_perks.size(), level])
	
	if available_perks.is_empty():
		print("No perks available for level ", level)
		handle_level_up_without_ui()
		return
	
	# Update labels
	var level_label = level_up_ui.find_child("LevelLabel", true, false)
	var title_label = level_up_ui.find_child("TitleLabel", true, false)
	
	print("Found level_label: ", level_label)
	print("Found title_label: ", title_label)
	
	if level_label:
		level_label.text = "Level %d Reached!" % level
	if title_label:
		title_label.text = "Choose Your Perk"
	
	# Create perk buttons
	var perk_container = level_up_ui.find_child("PerkContainer", true, false)
	print("Found perk_container: ", perk_container)
	
	if not perk_container:
		print("Could not find perk container!")
		handle_level_up_without_ui()
		return
	
	# Clear existing buttons
	for child in perk_container.get_children():
		child.queue_free()
	
	print("Creating %d perk buttons..." % available_perks.size())
	
	# Create buttons for each perk
	for i in range(available_perks.size()):
		var perk = available_perks[i]
		var button = Button.new()
		button.text = "%s\n%s\n(%s)" % [perk.perk_name, perk.description, perk.get_rarity_name()]
		button.custom_minimum_size = Vector2(200, 120)
		button.modulate = perk.get_rarity_color()
		
		# Connect button to selection
		button.pressed.connect(_on_perk_selected.bind(perk))
		
		perk_container.add_child(button)
		print("Created button for: ", perk.perk_name)
	
	# Show UI and pause
	print("Setting UI visible and pausing game...")
	print("UI visible before: ", level_up_ui.visible)
	print("UI global position: ", level_up_ui.global_position)
	print("UI size: ", level_up_ui.size)
	
	level_up_ui.visible = true
	get_tree().paused = true
	
	print("UI visible after: ", level_up_ui.visible)
	print("Game paused: ", get_tree().paused)
	print("Level up UI shown with %d perk options at player position" % available_perks.size())

func _on_perk_selected(perk: Perk):
	# Add perk to manager
	if perk_manager.add_perk(perk):
		apply_perk_multipliers()
		print("Selected perk: %s (%s)" % [perk.perk_name, perk.get_rarity_name()])
	
	# Hide UI and unpause
	if level_up_ui:
		level_up_ui.visible = false
	get_tree().paused = false

func apply_class_stats():
	player_class = GameManager.selected_player_class
	if not player_class:
		player_class = PlayerClass.create_slug()  # Default fallback
	
	# Apply base stats with class multipliers AND perk multipliers
	apply_perk_multipliers()

func apply_perk_multipliers():
	if not perk_manager:
		print("WARNING: No perk manager found")
		return
	
	# Wait a frame to ensure perk manager is ready
	if not perk_manager.is_node_ready():
		await get_tree().process_frame
	
	# Get perk multipliers
	var health_mult = perk_manager.get_stat_multiplier(Perk.PerkType.HEALTH)
	var stamina_mult = perk_manager.get_stat_multiplier(Perk.PerkType.STAMINA)
	var damage_mult = perk_manager.get_stat_multiplier(Perk.PerkType.DAMAGE)
	var attack_speed_mult = perk_manager.get_stat_multiplier(Perk.PerkType.ATTACK_SPEED)
	var movement_speed_mult = perk_manager.get_stat_multiplier(Perk.PerkType.MOVEMENT_SPEED)
	var health_regen_mult = perk_manager.get_stat_multiplier(Perk.PerkType.HEALTH_REGEN)
	var stamina_regen_mult = perk_manager.get_stat_multiplier(Perk.PerkType.STAMINA_REGEN)
	var ability_cooldown_mult = perk_manager.get_stat_multiplier(Perk.PerkType.ABILITY_COOLDOWN)
	
	print("Applying perk multipliers - Health: %.2f, Damage: %.2f, Speed: %.2f" % [health_mult, damage_mult, movement_speed_mult])
	
	# Calculate old health percentage to maintain after stat changes
	var health_percentage = float(health) / float(max_health) if max_health > 0 else 1.0
	var stamina_percentage = float(stamina) / float(max_stam) if max_stam > 0 else 1.0
	
	# Apply all multipliers (class stats * perk multipliers)
	max_health = int(player_class.base_health * player_class.health_multiplier * health_mult)
	max_stam = int(player_class.base_stamina * player_class.stamina_multiplier * stamina_mult)
	SPEED = int(player_class.base_speed * player_class.speed_multiplier * movement_speed_mult)
	damage = int(player_class.base_damage * player_class.damage_multiplier * damage_mult)
	shoot_cooldown = (0.5 / player_class.attack_speed_multiplier) / attack_speed_mult
	
	# Update regeneration rates
	health_regen_rate = 1.0 / health_regen_mult  # Lower = faster regen
	stamina_regen_rate = 1.0 / stamina_regen_mult  # Lower = faster regen
	
	# Update ability cooldowns (this affects new cooldowns, existing ones continue)
	var base_ability_cooldowns = [3.0, 4.0, 5.0]  # Base cooldowns for abilities
	for i in range(ability_cooldowns.size()):
		# Only apply to abilities that aren't currently on cooldown
		if ability_cooldowns[i] <= 0:
			if player_class.ability_1 and i == 0:
				player_class.ability_1.cooldown = player_class.ability_1.cooldown * ability_cooldown_mult
			elif player_class.ability_2 and i == 1:
				player_class.ability_2.cooldown = player_class.ability_2.cooldown * ability_cooldown_mult
			elif player_class.ability_3 and i == 2:
				player_class.ability_3.cooldown = player_class.ability_3.cooldown * ability_cooldown_mult
	
	# Maintain health/stamina percentages after stat changes
	health = int(max_health * health_percentage)
	stamina = int(max_stam * stamina_percentage)
	
	# Ensure we don't exceed maximums
	health = min(health, max_health)
	stamina = min(stamina, max_stam)
	
	print("Stats updated - Health: %d/%d, Damage: %d, Speed: %d" % [health, max_health, damage, SPEED])

func _physics_process(delta: float) -> void:
	ui.update_ui(self)
	
	# Update dash timer
	if dash_timer > 0:
		dash_timer -= delta
	
	# Handle dash duration
	if is_dashing:
		dash_duration_timer -= delta
		if dash_duration_timer <= 0:
			is_dashing = false
	
	# Movement
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var current_speed = dash_speed if is_dashing else SPEED
	velocity = direction * current_speed
	
	var collision = move_and_collide(velocity * delta)
	if collision and collision.get_collider() is Enemy:
		take_damage(10)

	# Get global mouse position
	var mouse_pos = get_global_mouse_position()

	# Point the RayCast2D towards the mouse
	var to_mouse = mouse_pos - global_position
	ray.target_position = to_mouse

	# Rotate the player to face the mouse
	rotation = to_mouse.angle() + deg_to_rad(90)

	# Toggle auto attack
	if Input.is_action_just_pressed("auto_toggle"):
		auto_attack = !auto_attack
		print("Auto attack: ", "ON" if auto_attack else "OFF")

	# Update cooldown timers
	if shoot_cooldown_timer > 0:
		shoot_cooldown_timer -= delta
	
	if damage_timer > 0:
		damage_timer -= delta
	elif touching_enemies.size() > 0:
		take_damage(10)
	
	# Update ability cooldowns
	for i in range(ability_cooldowns.size()):
		if ability_cooldowns[i] > 0:
			ability_cooldowns[i] -= delta
	
	# Handle abilities
	if Input.is_action_just_pressed("ability_1") and player_class.ability_1:
		use_ability(0)
	elif Input.is_action_just_pressed("ability_2") and player_class.ability_2:
		use_ability(1)
	elif Input.is_action_just_pressed("ability_3") and player_class.ability_3:
		use_ability(2)

	# Auto or manual attack
	if auto_attack and shoot_cooldown_timer <= 0:
		shoot()
		shoot_cooldown_timer = shoot_cooldown
	elif Input.is_action_pressed("attack") and shoot_cooldown_timer <= 0:
		shoot()
		shoot_cooldown_timer = shoot_cooldown
	
	# Handle regeneration
	if player_class.has_regeneration:
		health_regen_timer += delta
		if health_regen_timer >= health_regen_rate and health < max_health:
			health = min(health + 1, max_health)
			health_regen_timer = 0.0
	
	# Stamina regeneration
	if player_class.has_stamina_regen:
		stamina_regen_timer += delta
		if stamina_regen_timer >= stamina_regen_rate and stamina < max_stam:
			stamina = min(stamina + 1, max_stam)
			stamina_regen_timer = 0.0

func use_ability(ability_slot: int):
	var ability: Ability = null
	
	match ability_slot:
		0: ability = player_class.ability_1
		1: ability = player_class.ability_2
		2: ability = player_class.ability_3
	
	if not ability:
		return
	
	# Check cooldown
	if ability_cooldowns[ability_slot] > 0:
		print("Ability on cooldown: ", ability_cooldowns[ability_slot])
		return
	
	# Check if can use (stamina, etc.)
	if not ability.can_use(self):
		print("Cannot use ability: Not enough stamina")
		return
	
	# Execute the ability based on its name
	var success = false
	match ability.ability_name:
		"Dash":
			success = execute_dash(ability)
		"Slime Bomb":
			success = execute_slime_bomb(ability)
		"Blood Squirt":
			success = execute_blood_squirt(ability)
		"Mud Wallow":
			success = execute_mud_wallow(ability)
		"Charge":
			success = execute_charge(ability)
		"Double Jump":
			success = execute_double_jump(ability)
		_:
			print("Unknown ability: ", ability.ability_name)
			return
	
	if success:
		stamina -= ability.stamina_cost
		ability_cooldowns[ability_slot] = ability.cooldown
		print("Used ability: ", ability.ability_name)

# Individual ability execution functions
func execute_dash(ability: Ability) -> bool:
	start_dash()
	return true

func execute_slime_bomb(ability: Ability) -> bool:
	throw_slime_bomb()
	return true

func execute_blood_squirt(ability: Ability) -> bool:
	blood_squirt()
	return true

func execute_mud_wallow(ability: Ability) -> bool:
	start_mud_wallow()
	return true

func execute_charge(ability: Ability) -> bool:
	start_charge()
	return true

func execute_double_jump(ability: Ability) -> bool:
	double_jump()
	return true

# Ability implementations
func start_dash():
	is_dashing = true
	dash_timer = dash_cooldown
	dash_duration_timer = dash_duration

func throw_slime_bomb():
	# Create a slime projectile that slows enemies
	var slime = SlimeBomb.instantiate()  # Reuse arrow for now
	get_tree().current_scene.add_child(slime)
	slime.global_position = global_position + ray.target_position.normalized() * 30
	slime.direction = ray.target_position.normalized()
	slime.damage = damage * 0.5  # Less damage but applies slow effect
	slime.speed = 400  # Slower than arrows
	slime.piercing = false
	print("Slime bomb thrown!")

func blood_squirt():
	# Create multiple projectiles in a cone
	var projectile_count = 5
	var spread_angle = PI / 3  # 60 degrees spread
	
	for i in range(projectile_count):
		var blood_drop = ArrowScene.instantiate()
		get_tree().current_scene.add_child(blood_drop)
		blood_drop.global_position = global_position
		
		var angle_offset = spread_angle * (i - 2) / 2  # Center the spread
		var direction = ray.target_position.normalized().rotated(angle_offset)
		blood_drop.direction = direction
		blood_drop.damage = damage * 0.8
		blood_drop.speed = 600
		blood_drop.modulate = Color.RED
	
	print("Blood squirt activated!")

func start_mud_wallow():
	# Temporary health regen and damage reduction
	var wallow_duration = 5.0
	var regen_amount = max_health * 0.3  # Heal 30% of max health over duration
	
	# Start regeneration effect
	var tween = create_tween()
	tween.tween_method(_heal_over_time, 0.0, regen_amount, wallow_duration)
	
	# Visual effect
	modulate = Color.BROWN
	var reset_tween = create_tween()
	reset_tween.tween_delay(wallow_duration)
	reset_tween.tween_callback(func(): modulate = Color.WHITE)
	
	print("Mud wallow started!")

func _heal_over_time(amount: float):
	health = min(health + int(amount), max_health)

func start_charge():
	# Powerful forward movement with damage
	var charge_direction = ray.target_position.normalized()
	var charge_distance = 200
	
	# Create a charge effect
	velocity = charge_direction * dash_speed * 1.5
	
	# Deal damage to enemies in path (simplified)
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(
		global_position,
		global_position + charge_direction * charge_distance
	)
	
	print("Charge attack!")

func double_jump():
	# Quick upward movement (in 2D, this could be a quick dash)
	velocity.y -= 300  # Upward boost
	print("Double jump!")

func _on_HurtBox_body_entered(body):
	if body is Enemy and not touching_enemies.has(body):
		touching_enemies.append(body)

func _on_HurtBox_body_exited(body):
	if body is Enemy:
		touching_enemies.erase(body)

func shoot():
	var arrows_to_shoot = 2 if player_class.has_double_shot else 1
	
	for i in range(arrows_to_shoot):
		var arrow = ArrowScene.instantiate()
		get_tree().current_scene.add_child(arrow)

		# Position it at the player
		arrow.global_position = global_position + ray.target_position.normalized() * 20

		# Set direction based on raycast
		var dir = (ray.target_position).normalized()
		
		# For double shot, spread the arrows slightly
		if arrows_to_shoot == 2:
			var spread_angle = deg_to_rad(15)  # 15 degrees spread
			var angle_offset = spread_angle * (i - 0.5)
			dir = dir.rotated(angle_offset)
		
		arrow.direction = dir
		arrow.damage = damage
		
		# Set piercing if class has it
		if player_class.has_piercing_arrows:
			arrow.piercing = true

		# Rotate arrow to match direction
		arrow.rotation = dir.angle()

func gain_exp(amount: int):
	exp += amount
	if exp >= req_exp:
		level_up()
	ui.update_ui(self)

func level_up():
	exp -= req_exp
	level += 1
	req_exp = int(req_exp * 1.5)
	
	# Show level up UI for perk selection
	show_level_up_ui()
	
	ui.update_ui(self)

func handle_level_up_without_ui():
	# Simple fallback: automatically give a random perk
	if perk_manager:
		var random_perks = perk_manager.generate_random_perks(level, 1)
		if random_perks.size() > 0:
			perk_manager.add_perk(random_perks[0])
			apply_perk_multipliers()
			print("Auto-selected perk: ", random_perks[0].perk_name, " (", random_perks[0].get_rarity_name(), ")")
		else:
			print("No perks available for level ", level)
	
func take_damage(amount: int):
	if damage_timer > 0 or is_dashing:  # Dash makes you invulnerable
		return

	health -= amount
	damage_timer = damage_cooldown

	if health <= 0:
		die()

	ui.update_ui(self)

func die():
	queue_free()

func setup_vampire_survivors_camera():
	if camera:
		# Vampire Survivors style zoom - much more zoomed out
		camera.zoom = Vector2(0.3, 0.3)  # Try values between 0.2-0.4
		
		# Enable camera smoothing for smoother movement
		camera.enabled = true
		camera.position_smoothing_enabled = true
		camera.position_smoothing_speed = 5.0  # Adjust for responsiveness
		
		# Optional: Add camera limits if you have world boundaries
		# camera.limit_left = -5000
		# camera.limit_right = 5000
		# camera.limit_top = -5000
		# camera.limit_bottom = 5000
		
		# Make camera current
		camera.make_current()
		print("Vampire Survivors camera setup complete - Zoom: ", camera.zoom)
