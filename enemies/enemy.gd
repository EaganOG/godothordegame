extends CharacterBody2D
class_name Enemy

var health := 100
var speed := 100
var target: Node = null  # Usually the player

func _ready():
	if not target:
		target = get_tree().get_first_node_in_group("player")  # Make sure your player is in the "player" group

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
	queue_free()
