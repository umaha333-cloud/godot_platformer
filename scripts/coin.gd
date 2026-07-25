extends Area2D

signal collected(pos)

var bob_height = 6.0
var bob_speed = 2.6
var base_y = 0.0
var audio_player = null

func _ready():
    base_y = global_position.y
    body_entered.connect(_on_body_entered)
    audio_player = AudioStreamPlayer.new()
    add_child(audio_player)

func _process(delta):
    global_position.y = base_y + sin(Time.get_ticks_msec() * 0.003 * bob_speed) * bob_height

func _on_body_entered(body):
    if body.is_in_group("player"):
        play_collect_sound()
        emit_signal("collected", global_position)
        queue_free()

func play_collect_sound():
    if audio_player == null:
        return

    if not get_tree().current_scene.has_method("is_sfx_enabled") or not get_tree().current_scene.is_sfx_enabled():
        return

    audio_player.stream = create_tone(1320.0, 0.08, 0.18)
    audio_player.volume_db = -4.0
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
