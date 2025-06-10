extends CharacterBody2D
var ArrowScene = preload("res://player/Arrow.tscn")
@onready var hurtbox = $hurtbox

@onready var ui = get_tree().current_scene.get_node("Ui")
@onready var health = 100
@onready var max_health = 100
@onready var stamina = 100
@onready var max_stam = 100
@onready var level = 1
@onready var exp = 0
@onready var req_exp = 100
const SPEED = 600
var shoot_cooldown = 0.5
var shoot_cooldown_timer = 0.0
var damage_cooldown = 0.5
var damage_timer = 0.0
var touching_enemies: Array[Node] = []

var auto_attack = false

@onready var ray = $RayCast2D


func _ready():
	hurtbox.body_entered.connect(_on_HurtBox_body_entered)
	hurtbox.body_exited.connect(_on_HurtBox_body_exited)


func _physics_process(delta: float) -> void:
	ui.update_ui(self)
	# Movement
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * SPEED
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
		if auto_attack == false:
			print("toggled auto attack off")
		elif auto_attack == true:
			print("toggled auto attack on")

	# Update cooldown timer
	if shoot_cooldown_timer > 0:
		shoot_cooldown_timer -= delta
	
	if damage_timer > 0:
		damage_timer -= delta
	elif touching_enemies.size() >0:
		take_damage(10)

	# Auto or manual attack
	if auto_attack and shoot_cooldown_timer <= 0:
		shoot()
		shoot_cooldown_timer = shoot_cooldown
	elif Input.is_action_pressed("attack") and shoot_cooldown_timer <= 0:
		shoot()
		shoot_cooldown_timer = shoot_cooldown

func _on_HurtBox_body_entered(body):
	if body is Enemy and not touching_enemies.has(body):
		touching_enemies.append(body)

func _on_HurtBox_body_exited(body):
	if body is Enemy:
		touching_enemies.erase(body)


func shoot():
	var arrow = ArrowScene.instantiate()
	get_tree().current_scene.add_child(arrow)

	# Position it at the player
	arrow.global_position = global_position + ray.target_position.normalized() * 20

	# Set direction based on raycast
	var dir = (ray.target_position).normalized()
	arrow.direction = dir

	# Rotate arrow to match direction
	arrow.rotation = dir.angle()

func gain_exp(amount: int):
	exp += amount
	if exp >= req_exp:
		level_up()
	ui.update_ui(self)  # Update UI only when exp changes

func level_up():
	exp -= req_exp
	level += 1
	req_exp = int(req_exp * 1.5)  # Scale difficulty
	ui.update_ui(self)  # Update UI after level change
	
func take_damage(amount: int):
	if damage_timer > 0:
		return  # Still in cooldown

	health -= amount
	damage_timer = damage_cooldown

	if health <= 0:
		die()

	ui.update_ui(self)

func die():
	queue_free()
