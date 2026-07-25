extends Area2D

signal activated(position)

func _ready():
    body_entered.connect(_on_body_entered)

    var shape = CollisionShape2D.new()
    var rectangle = RectangleShape2D.new()
    rectangle.size = Vector2(28, 60)
    shape.shape = rectangle
    add_child(shape)

    var visual = ColorRect.new()
    visual.size = Vector2(28, 60)
    visual.position = Vector2(-14, -30)
    visual.color = Color(0.2, 0.8, 0.3)
    add_child(visual)

func _on_body_entered(body):
    if body.is_in_group("player"):
        emit_signal("activated", global_position)
