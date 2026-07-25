extends RefCounted
class_name AudioUtil

static func create_tone(frequency: float, duration: float, volume: float) -> AudioStreamWAV:
    var stream := AudioStreamWAV.new()
    var sample_rate := 22050
    var total_samples := int(sample_rate * duration)
    var data := PackedByteArray()
    data.resize(total_samples * 2)

    for i in range(total_samples):
        var t := i / float(sample_rate)
        var sample := sin(t * frequency * TAU) * volume
        var sample_value := int(sample * 32767.0)
        data[i * 2] = sample_value & 0xFF
        data[i * 2 + 1] = (sample_value >> 8) & 0xFF

    stream.mix_rate = sample_rate
    stream.format = AudioStreamWAV.FORMAT_16_BITS
    stream.stereo = false
    stream.data = data
    stream.loop_mode = AudioStreamWAV.LOOP_DISABLED
    return stream

static func is_sfx_enabled(scene: Node) -> bool:
    if scene == null:
        return true
    if scene.has_method("is_sfx_enabled"):
        return scene.is_sfx_enabled()
    return true
