extends Sprite2D
@export var speed = 800
var direction = Vector2.ZERO
var damage = 25
var piercing = false
var hit_enemies: Array[Node] = []
var spawn_position: Vector2  # Track where the arrow was created

func _ready() -> void:
	$AnimationPlayer.play("shoot")
	
	# Connect to the Area2D's body_entered signal instead
	var area = $Area2D  # Assuming you have an Area2D child node
	if area:
		area.body_entered.connect(_on_body_entered)
	else:
		print("Warning: No Area2D found on slimeball!")
	
	spawn_position = global_position  # Remember where we started

func _process(delta):
	position += direction * speed * delta
	
	# Remove arrow if it's far from the camera/player
	var player = get_tree().get_first_node_in_group("player")
	if player and global_position.distance_to(player.global_position) > 3000:
		queue_free()

func _on_body_entered(body):
	if body is Enemy:
		body.take_damage(damage)
		queue_free()  # Destroy non-piercing arrows
