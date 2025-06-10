extends Area2D
@export var speed = 800
var direction = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("body_entered", self._on_body_entered)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body is Enemy:
		body.take_damage(25)
		queue_free()  # Destroy the arrow
