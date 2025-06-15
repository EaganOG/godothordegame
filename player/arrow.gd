extends Area2D
@export var speed = 800
var direction = Vector2.ZERO
var damage = 25
var piercing = false
var hit_enemies: Array[Node] = []
var spawn_position: Vector2  # Track where the arrow was created

func _ready() -> void:
	connect("body_entered", self._on_body_entered)
	spawn_position = global_position  # Remember where we started

func _process(delta):
	position += direction * speed * delta
	
	# Remove arrow if it's far from the camera/player
	var player = get_tree().get_first_node_in_group("player")
	if player and global_position.distance_to(player.global_position) > 3000:
		queue_free()

func _on_body_entered(body):
	if body is Enemy:
		# Check if we already hit this enemy (for piercing arrows)
		if piercing and hit_enemies.has(body):
			return
		
		body.take_damage(damage)
		
		if piercing:
			hit_enemies.append(body)
		else:
			queue_free()  # Destroy non-piercing arrows
