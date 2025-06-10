extends CharacterBody2D

@export var max_health: int = 100
@export var health: int = 100
@export var max_stam: int = 100
@export var stamina: int = 100
@export var SPEED: int = 600
@export var damage: int = 25

var regen_timer: float = 0.0
var regen_rate: float = 1.0

@export var level: int = 1
@export var exp: int = 0
@export var req_exp: int = 100

@export var selected_class: PlayerClass
var combat_type: PlayerClass.CombatType = PlayerClass.CombatType.RANGED

@onready var melee_weapon_scene = preload("res://player/MeleeWeapon.tscn")
var current_melee_weapon: MeleeWeapon
var melee_attack_timer: float = 0.0
var melee_cooldown: float = 0.8
var is_melee_attacking: bool = false

@onready var arrow_scene = preload("res://player/Arrow.tscn")
var shoot_timer: float = 0.0
var shoot_cooldown: float = 0.5

func _ready():
	if not selected_class:
		selected_class = PlayerClass.create_archer()
		print("No class selected, defaulting to Archer")
	
	apply_class_stats()
	setup_combat_type()
	
	if combat_type == PlayerClass.CombatType.MELEE or combat_type == PlayerClass.CombatType.HYBRID:
		setup_melee_weapon()
	
	print("Player initialized with class: ", selected_class.player_class_name)

func set_player_class(new_class: PlayerClass):
	if not new_class:
		print("Warning: Attempted to set null class")
		return
	
	selected_class = new_class
	apply_class_stats()
	setup_combat_type()
	
	if combat_type == PlayerClass.CombatType.MELEE or combat_type == PlayerClass.CombatType.HYBRID:
		setup_melee_weapon()
	
	print("Class changed to: ", selected_class.player_class_name)

func apply_class_stats():
	if not selected_class:
		print("Warning: apply_class_stats called with no class")
		return
	
	max_health = int(selected_class.base_health * selected_class.health_multiplier)
	health = max_health
	max_stam = int(selected_class.base_stamina * selected_class.stamina_multiplier)
	stamina = max_stam
	SPEED = int(selected_class.base_speed * selected_class.speed_multiplier)
	damage = int(selected_class.base_damage * selected_class.damage_multiplier)
	
	if selected_class.attack_speed_multiplier > 0:
		shoot_cooldown = 0.5 / selected_class.attack_speed_multiplier
		melee_cooldown = 0.8 / selected_class.attack_speed_multiplier

func setup_combat_type():
	if selected_class:
		combat_type = selected_class.combat_type
	else:
		combat_type = PlayerClass.CombatType.RANGED

func setup_melee_weapon():
	if current_melee_weapon and is_instance_valid(current_melee_weapon):
		current_melee_weapon.queue_free()
	
	current_melee_weapon = melee_weapon_scene.instantiate()
	add_child(current_melee_weapon)
	
	current_melee_weapon.damage = damage
	
	if selected_class:
		current_melee_weapon.attack_range = selected_class.melee_range
		current_melee_weapon.knockback_force = selected_class.melee_knockback
		current_melee_weapon.aoe_radius = selected_class.melee_aoe_radius
		
		if selected_class.has_life_steal:
			current_melee_weapon.life_steal_percent = 0.15
	else:
		current_melee_weapon.attack_range = 100.0
		current_melee_weapon.knockback_force = 200.0
		current_melee_weapon.aoe_radius = 0.0
	
	current_melee_weapon.enemy_hit.connect(_on_melee_enemy_hit)
	current_melee_weapon.attack_finished.connect(_on_melee_attack_finished)

func _physics_process(delta):
	handle_movement(delta)
	handle_rotation()
	
	if shoot_timer > 0:
		shoot_timer -= delta
	if melee_attack_timer > 0:
		melee_attack_timer -= delta
	
	handle_regeneration(delta)
	
	if PerkManager:
		PerkManager.process_perk_ticks(self, delta)
	
	move_and_slide()

func handle_movement(delta):
	# Use custom input mappings for movement
	var input_dir = Vector2.ZERO
	
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1
	if Input.is_action_pressed("move_up"):
		input_dir.y -= 1
	if Input.is_action_pressed("move_down"):
		input_dir.y += 1
	
	# Normalize diagonal movement
	input_dir = input_dir.normalized()
	
	if input_dir != Vector2.ZERO:
		velocity = input_dir * SPEED
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)

func handle_rotation():
	# Point player towards mouse cursor
	var mouse_pos = get_global_mouse_position()
	var direction = (mouse_pos - global_position).normalized()
	
	# Set rotation to face mouse
	rotation = direction.angle() + deg_to_rad(90)

func handle_regeneration(delta):
	if not selected_class:
		return
	
	if selected_class.has_regeneration:
		regen_timer += delta
		if regen_timer >= regen_rate and health < max_health:
			health = min(health + 1, max_health)
			regen_timer = 0.0

func _input(event):
	# Use mouse click for attacking
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("attack"):
		attempt_attack()
	
	# Debug class switching
	if event.is_action_pressed("ui_select"):
		cycle_test_class()

func attempt_attack():
	match combat_type:
		PlayerClass.CombatType.RANGED:
			attempt_ranged_attack()
		PlayerClass.CombatType.MELEE:
			attempt_melee_attack()
		PlayerClass.CombatType.HYBRID:
			if selected_class and (selected_class.has_double_shot or selected_class.has_piercing_arrows):
				attempt_ranged_attack()
			else:
				attempt_melee_attack()

func attempt_ranged_attack():
	if shoot_timer <= 0:
		shoot_arrow()
		shoot_timer = shoot_cooldown

func attempt_melee_attack():
	if melee_attack_timer <= 0 and not is_melee_attacking and current_melee_weapon:
		perform_melee_attack()
		melee_attack_timer = melee_cooldown

func perform_melee_attack():
	if not current_melee_weapon:
		print("Warning: Attempting melee attack with no weapon")
		return
	
	is_melee_attacking = true
	var attack_direction = get_attack_direction()
	
	if selected_class:
		if selected_class.has_whirlwind and randf() < 0.3:
			current_melee_weapon.whirlwind_attack(global_position)
		elif selected_class.has_charge_attack and Input.is_action_pressed("ui_cancel"):
			current_melee_weapon.charge_attack(attack_direction, global_position, 2.5)
		else:
			current_melee_weapon.start_attack(attack_direction, global_position)
	else:
		current_melee_weapon.start_attack(attack_direction, global_position)

func get_attack_direction() -> Vector2:
	# Attack in the direction the player is facing (towards mouse)
	var mouse_pos = get_global_mouse_position()
	return (mouse_pos - global_position).normalized()

func shoot_arrow():
	if not arrow_scene:
		print("Warning: No arrow scene loaded")
		return
	
	var arrow = arrow_scene.instantiate()
	get_parent().add_child(arrow)
	arrow.global_position = global_position
	
	# Shoot towards mouse cursor
	var mouse_pos = get_global_mouse_position()
	arrow.direction = (mouse_pos - global_position).normalized()
	arrow.damage = damage
	
	if selected_class:
		arrow.speed = selected_class.projectile_speed
		arrow.piercing = selected_class.has_piercing_arrows
		
		if selected_class.has_double_shot:
			create_double_shot(arrow.direction)
	else:
		arrow.speed = 800
		arrow.piercing = false

func create_double_shot(base_direction: Vector2):
	if not arrow_scene:
		return
	
	for i in range(2):
		var arrow = arrow_scene.instantiate()
		get_parent().add_child(arrow)
		arrow.global_position = global_position
		
		var angle_offset = (i - 0.5) * 0.3
		arrow.direction = base_direction.rotated(angle_offset)
		arrow.damage = damage
		
		if selected_class:
			arrow.speed = selected_class.projectile_speed
			arrow.piercing = selected_class.has_piercing_arrows
		else:
			arrow.speed = 800
			arrow.piercing = false

func _on_melee_enemy_hit(enemy: Node, heal_amount: int):
	if heal_amount > 0:
		health = min(health + heal_amount, max_health)
	
	if PerkManager:
		PerkManager.trigger_enemy_killed(self, enemy)

func _on_melee_attack_finished():
	is_melee_attacking = false

func cycle_test_class():
	var classes = ["Archer", "Warrior", "Mage", "Berserker", "Paladin"]
	var current_index = 0
	
	if selected_class:
		for i in range(classes.size()):
			if classes[i] == selected_class.player_class_name:
				current_index = (i + 1) % classes.size()
				break
	
	select_class_by_name(classes[current_index])

func select_class_by_name(search_class_name: String):
	var all_classes = PlayerClass.get_all_classes()
	for player_class in all_classes:
		if player_class.player_class_name == search_class_name:
			set_player_class(player_class)
			return
	
	print("Class not found: ", search_class_name)

func take_damage(damage_amount: int):
	if PerkManager and PerkManager.trigger_damage_taken(self, damage_amount):
		return
	
	health -= damage_amount
	health = max(health, 0)
	
	if health <= 0:
		die()

func die():
	print("Player died!")

func level_up():
	level += 1
	exp = 0
	req_exp = int(req_exp * 1.5)
	print("Level up! Now level ", level)
