extends Area2D

var speed = 110.0
var direction = 1
var start_x = 0.0
var start_y = 0.0
var move_range = 170.0
var warning_timer = 0.0
var warning_flash = false
var warning_color = Color(1.0, 0.2, 0.2)

func _ready():
    start_x = global_position.x
    start_y = global_position.y
    body_entered.connect(_on_body_entered)

func _process(delta):
    warning_timer -= delta
    if warning_timer <= 0.0:
        warning_flash = false
        if get_child_count() > 1:
            get_child(1).modulate = Color(1.0, 1.0, 1.0)

    var new_x = global_position.x + direction * speed * delta
    if abs(new_x - start_x) > move_range:
        direction *= -1
        new_x = global_position.x + direction * speed * delta
    global_position.x = new_x
    global_position.y = start_y + sin(Time.get_ticks_msec() * 0.003) * 4.0

    if abs(global_position.x - start_x) > move_range * 0.75 and not warning_flash:
        warning_flash = true
        warning_timer = 0.35
        if get_child_count() > 1:
            get_child(1).modulate = warning_color
        var main = get_tree().current_scene
        if main != null and main.has_method("show_status_message"):
            main.show_status_message("Enemy patrol warning!")

func _on_body_entered(body):
    if body.is_in_group("player") and body.has_method("handle_enemy_hit"):
        body.handle_enemy_hit()
