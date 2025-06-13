# enemies/enemy.gd
extends CharacterBody2D
class_name Enemy

var health := 100
var speed := 100
var target: Node = null
var exp_reward := 25

func _ready():
	add_to_group("enemies")  # Add to enemies group for targeting
	if not target:
		target = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	if target:
		var direction = (target.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()

func take_damage(amount: int):
	health -= amount
	if health <= 0:
		die()

func die():
	# Give experience to player
	if target and target.has_method("gain_exp"):
		target.gain_exp(exp_reward)
	queue_free()
