extends Area2D
@export var speed = 800
var direction = Vector2.ZERO
var damage = 25
var piercing = false
var hit_enemies: Array[Node] = []

func _ready() -> void:
	connect("body_entered", self._on_body_entered)

func _process(delta):
	position += direction * speed * delta
	
	# Remove arrow if it goes too far off screen
	#if global_position.distance_to(Vector2.ZERO) > 2000:
		#queue_free()

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
