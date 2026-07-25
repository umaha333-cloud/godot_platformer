extends CharacterBody2D

signal life_used

const SPEED = 220.0
const JUMP_VELOCITY = -360.0
const DASH_SPEED = 620.0
const DASH_DURATION = 0.12
const DASH_COOLDOWN = 0.35
const WALL_SLIDE_SPEED = 80.0
const WALL_JUMP_X = 280.0
const WALL_JUMP_Y = -320.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var respawn_position = Vector2.ZERO
var dash_timer = 0.0
var dash_cooldown_timer = 0.0
var can_dash = true
var has_double_jumped = false
var audio_player = null
var move_speed_bonus = 0.0
var lives = 1

func _ready():
    respawn_position = global_position
    audio_player = AudioStreamPlayer.new()
    add_child(audio_player)

func _physics_process(delta):
    if dash_timer > 0.0:
        dash_timer -= delta
        move_and_slide()
        return

    if dash_cooldown_timer > 0.0:
        dash_cooldown_timer -= delta
        if dash_cooldown_timer <= 0.0:
            can_dash = true

    var wall_jumped = false
    if not is_on_floor() and is_on_wall() and velocity.y > 0:
        var wall_normal = get_wall_normal()
        var pushing_into_wall = (wall_normal.x > 0 and Input.is_action_pressed("ui_left")) or (wall_normal.x < 0 and Input.is_action_pressed("ui_right"))
        if pushing_into_wall:
            if velocity.y > WALL_SLIDE_SPEED:
                velocity.y = WALL_SLIDE_SPEED
            if Input.is_action_just_pressed("ui_accept"):
                velocity.x = wall_normal.x * WALL_JUMP_X
                velocity.y = WALL_JUMP_Y
                has_double_jumped = false
                play_jump_sound()
                wall_jumped = true

    if not is_on_floor():
        velocity.y += gravity * delta
    else:
        has_double_jumped = false

    var direction = Input.get_axis("ui_left", "ui_right")
    var effective_speed = SPEED + move_speed_bonus
    if direction:
        velocity.x = direction * effective_speed
    else:
        velocity.x = move_toward(velocity.x, 0, effective_speed)

    if Input.is_action_just_pressed("ui_accept"):
        if is_on_floor():
            velocity.y = JUMP_VELOCITY
            play_jump_sound()
        elif not has_double_jumped and not wall_jumped:
            velocity.y = JUMP_VELOCITY
            has_double_jumped = true
            play_jump_sound()

    if Input.is_key_pressed(KEY_SHIFT) and can_dash:
        start_dash(direction)

    if global_position.y > 650:
        handle_enemy_hit()

    move_and_slide()

func start_dash(direction):
    can_dash = false
    dash_timer = DASH_DURATION
    dash_cooldown_timer = DASH_COOLDOWN
    var dash_direction = 1.0
    if direction != 0.0:
        dash_direction = direction
    elif velocity.x != 0.0:
        dash_direction = sign(velocity.x)
    velocity.x = dash_direction * DASH_SPEED
    velocity.y = 0.0

func set_respawn_position(position):
    respawn_position = position

func apply_upgrades(speed_level: int, extra_lives: int):
    move_speed_bonus = speed_level * 36.0
    lives = 1 + extra_lives

func play_jump_sound():
    if audio_player == null:
        return

    if not get_tree().current_scene.has_method("is_sfx_enabled") or not get_tree().current_scene.is_sfx_enabled():
        return

    audio_player.stream = create_tone(880.0, 0.08, 0.18)
    audio_player.volume_db = -8.0
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

func handle_enemy_hit():
    if lives > 1:
        lives -= 1
        emit_signal("life_used")
        global_position = respawn_position
        velocity = Vector2.ZERO
        dash_timer = 0.0
        dash_cooldown_timer = 0.0
        can_dash = true
        has_double_jumped = false
        play_hit_sound()
        return

    global_position = respawn_position
    velocity = Vector2.ZERO
    dash_timer = 0.0
    dash_cooldown_timer = 0.0
    can_dash = true
    has_double_jumped = false
    play_hit_sound()
    var main = get_tree().current_scene
    if main != null and main.has_method("shake_camera"):
        main.shake_camera(8.0, 0.3)

func play_hit_sound():
    if audio_player == null:
        return

    if not get_tree().current_scene.has_method("is_sfx_enabled") or not get_tree().current_scene.is_sfx_enabled():
        return

    audio_player.stream = create_tone(220.0, 0.12, 0.12)
    audio_player.volume_db = -6.0
    audio_player.play()
