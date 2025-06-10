extends CharacterBody2D
class_name Enemy

var health := 100
var speed := 100
var target: Node = null  # Usually the player

func _ready():
	if not target:
		target = get_tree().get_first_node_in_group("playerNode")  # Make sure your player is in the "player" group

func _physics_process(delta):
	if target:
		var direction = (target.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()

func take_damage(amount: int):
	health -= amount
	modulate = Color(1, 0.3, 0.3)  # Flash red
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1)

	if health <= 0:
		die()


func die():
	# Get reference to player and give exp
	var player = get_tree().get_first_node_in_group("playerNode")
	if player and player.has_method("gain_exp"):
		player.gain_exp(35)
	queue_free()
