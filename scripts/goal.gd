extends Area2D

signal reached
var audio_player = null

func _ready():
    body_entered.connect(_on_body_entered)
    audio_player = AudioStreamPlayer.new()
    add_child(audio_player)

    var shape = CollisionShape2D.new()
    var rectangle = RectangleShape2D.new()
    rectangle.size = Vector2(40, 60)
    shape.shape = rectangle
    add_child(shape)

    var visual = ColorRect.new()
    visual.size = Vector2(40, 60)
    visual.position = Vector2(-20, -30)
    visual.color = Color(0.7, 0.2, 1.0)
    add_child(visual)

func _on_body_entered(body):
    if body.is_in_group("player"):
        play_goal_sound()
        emit_signal("reached")

func play_goal_sound():
    if audio_player == null:
        return
    if not AudioUtil.is_sfx_enabled(get_tree().current_scene):
        return

    audio_player.stream = AudioUtil.create_tone(440.0, 0.16, 0.20)
    audio_player.volume_db = -2.0
    audio_player.play()