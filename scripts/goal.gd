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

    if not get_tree().current_scene.has_method("is_sfx_enabled") or not get_tree().current_scene.is_sfx_enabled():
        return

    audio_player.stream = create_tone(440.0, 0.16, 0.20)
    audio_player.volume_db = -2.0
    audio_player.play()

func create_tone(frequency: float, duration: float, volume: float) -> AudioStreamWAV:
    var stream = AudioStreamWAV.new()
    var sample_rate = 22050
    var total_samples = int(sample_rate * duration)
    var data = PackedByteArray()
    data.resize(total_samples * 2)

    for i in range(total_samples):
        var t = i / float(sample_rate)
        var sample = sin(t * frequency * TAU) * volume
        var sample_value = int(sample * 32767.0)
        data[i * 2] = sample_value & 0xFF
        data[i * 2 + 1] = (sample_value >> 8) & 0xFF

    stream.mix_rate = sample_rate
    stream.format = AudioStreamWAV.FORMAT_16_BITS
    stream.stereo = false
    stream.data = data
    stream.loop_mode = AudioStreamWAV.LOOP_DISABLED
    return stream