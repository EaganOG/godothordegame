# MeleeWeapon.gd
extends Area2D
class_name MeleeWeapon

@export var damage: int = 25
@export var knockback_force: float = 200.0
@export var attack_range: float = 100.0
@export var aoe_radius: float = 0.0
@export var life_steal_percent: float = 0.0

var hit_enemies: Array[Node] = []
var is_attacking: bool = false
var attack_duration: float = 0.3
var attack_timer: float = 0.0

@onready var collision_shape = $CollisionShape2D
@onready var visual = $Visual

signal enemy_hit(enemy: Node, heal_amount: int)
signal attack_finished

func _ready() -> void:
	connect("body_entered", self._on_body_entered)
	set_monitoring(false)

func _process(delta):
	if is_attacking:
		attack_timer += delta
		if attack_timer >= attack_duration:
			finish_attack()

func start_attack(direction: Vector2, player_pos: Vector2) -> void:
	if is_attacking:
		return
	
	is_attacking = true
	attack_timer = 0.0
	hit_enemies.clear()
	
	# Position the weapon
	global_position = player_pos + direction * (attack_range * 0.5)
	
	# Set weapon size based on range and AoE
	if aoe_radius > 0.0:
		var shape = CircleShape2D.new()
		shape.radius = aoe_radius
		collision_shape.shape = shape
	else:
		var shape = RectangleShape2D.new()
		shape.size = Vector2(attack_range, 50)
		collision_shape.shape = shape
	
	# Rotate weapon to face attack direction
	rotation = direction.angle()
	
	# Enable collision detection
	set_monitoring(true)
	
	# Show visual effect
	if visual:
		visual.visible = true
		create_attack_tween()

func create_attack_tween() -> void:
	if not visual:
		return
		
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Scale animation
	visual.scale = Vector2.ZERO
	tween.tween_property(visual, "scale", Vector2.ONE, attack_duration * 0.5)
	tween.tween_property(visual, "scale", Vector2.ZERO, attack_duration * 0.5).set_delay(attack_duration * 0.5)
	
	# Rotation animation for spin attacks
	if aoe_radius > 0.0:
		tween.tween_property(visual, "rotation", visual.rotation + PI * 2, attack_duration)

func finish_attack() -> void:
	is_attacking = false
	set_monitoring(false)
	
	if visual:
		visual.visible = false
	
	attack_finished.emit()

func _on_body_entered(body):
	if not is_attacking or hit_enemies.has(body):
		return
	
	if body.has_method("take_damage"):
		hit_enemies.append(body)
		
		# Calculate knockback direction
		var knockback_dir = (body.global_position - global_position).normalized()
		
		# Apply damage
		body.take_damage(damage)
		
		# Apply knockback if the enemy has the method
		if body.has_method("apply_knockback"):
			body.apply_knockback(knockback_dir * knockback_force)
		
		# Life steal
		var heal_amount = 0
		if life_steal_percent > 0.0:
			heal_amount = int(damage * life_steal_percent)
		
		enemy_hit.emit(body, heal_amount)

func whirlwind_attack(player_pos: Vector2) -> void:
	aoe_radius = 120.0
	attack_duration = 0.8
	start_attack(Vector2.RIGHT, player_pos)

func charge_attack(direction: Vector2, player_pos: Vector2, charge_multiplier: float = 2.0) -> void:
	var original_damage = damage
	var original_knockback = knockback_force
	var original_range = attack_range
	
	damage = int(damage * charge_multiplier)
	knockback_force *= charge_multiplier
	attack_range *= 1.5
	attack_duration = 0.5
	
	start_attack(direction, player_pos)
	
	await attack_finished
	damage = original_damage
	knockback_force = original_knockback
	attack_range = original_range
