extends CharacterBody2D
var ArrowScene = preload("res://player/Arrow.tscn")
@onready var hurtbox = $hurtbox

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

func _ready():
	add_to_group("player")
	hurtbox.body_entered.connect(_on_HurtBox_body_entered)
	hurtbox.body_exited.connect(_on_HurtBox_body_exited)
	
	# Apply class stats
	apply_class_stats()

func apply_class_stats():
	player_class = GameManager.selected_player_class
	if not player_class:
		player_class = PlayerClass.create_slug()  # Default fallback
	
	# Apply base stats with class multipliers
	max_health = int(player_class.base_health * player_class.health_multiplier)
	health = max_health
	max_stam = int(player_class.base_stamina * player_class.stamina_multiplier)
	stamina = max_stam
	SPEED = int(player_class.base_speed * player_class.speed_multiplier)
	damage = int(player_class.base_damage * player_class.damage_multiplier)
	shoot_cooldown = 0.5 / player_class.attack_speed_multiplier

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
			health = max(health + 1, max_health)
			health_regen_timer = 0.0
	
	# Replace the stamina regeneration section in your _physics_process function:

	if player_class.has_stamina_regen:
		stamina_regen_timer += delta
		if stamina_regen_timer >= stamina_regen_rate and stamina < max_stam:
			stamina = min(stamina + 1, max_stam)  # Also changed max() to min()
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
	var slime = ArrowScene.instantiate()  # Reuse arrow for now
	get_tree().current_scene.add_child(slime)
	slime.global_position = global_position + ray.target_position.normalized() * 30
	slime.direction = ray.target_position.normalized()
	slime.damage = damage * 0.5  # Less damage but applies slow effect
	slime.speed = 400  # Slower than arrows
	slime.modulate = Color.GREEN  # Make it green
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
	ui.update_ui(self)
	
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
