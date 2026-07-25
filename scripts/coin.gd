extends Area2D

signal collected(pos)

var bob_height := 6.0
var bob_speed := 2.6
var base_y := 0.0
var audio_player: AudioStreamPlayer = null

func _ready() -> void:
    base_y = global_position.y
    body_entered.connect(_on_body_entered)
    audio_player = AudioStreamPlayer.new()
    add_child(audio_player)

func _process(delta: float) -> void:
    global_position.y = base_y + sin(Time.get_ticks_msec() * 0.003 * bob_speed) * bob_height

func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        play_collect_sound()
        emit_signal("collected", global_position)
        queue_free()

func play_collect_sound() -> void:
    if audio_player == null:
        return
    if not AudioUtil.is_sfx_enabled(get_tree().current_scene):
        return

    audio_player.stream = AudioUtil.create_tone(1320.0, 0.08, 0.18)
    audio_player.volume_db = -4.0
    audio_player.play()
