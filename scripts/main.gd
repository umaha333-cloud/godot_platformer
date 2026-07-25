extends Node2D

var coin_count = 0
var goal_coins = 4
var active_checkpoint_position = Vector2.ZERO
var elapsed_time = 0.0
var score = 0
var game_over = false
var paused = false
var won = false
var best_score = 0
var selected_level = 1
@onready var coin_label = $CanvasLayer/Label
var status_label = null
var timer_label = null
var lives_label = null
var combo_label = null
var combo_count = 0
var combo_timer = 0.0
var music_player = null
var overlay = null
var restart_button = null
var resume_button = null
var quit_button = null
var pause_label = null
var game_over_title = null
var music_enabled = true
var sfx_enabled = true
var shop_open = false
var move_speed_level = 0
var extra_lives = 0
var player_node = null
var shop_panel = null
var shop_button = null
var speed_buy_button = null
var life_buy_button = null
var shop_label = null
var flash_overlay = null
var flash_timer = 0.0
@onready var _camera = $Camera2D

func _ready():
    load_audio_settings()
    load_best_score()
    load_selected_level()
    create_status_label()
    create_timer_label()
    create_lives_label()
    create_combo_label()
    create_overlay()
    create_shop_ui()
    create_floor()
    create_platforms()
    create_player()
    create_coins()
    create_enemy()
    create_checkpoints()
    create_goal()
    create_background_music()
    update_status()

func create_status_label():
    status_label = Label.new()
    status_label.position = Vector2(20, 80)
    status_label.size = Vector2(420, 60)
    status_label.text = "Collect the glowing coins and reach the portal."
    $CanvasLayer.add_child(status_label)

func create_timer_label():
    timer_label = Label.new()
    timer_label.position = Vector2(20, 112)
    timer_label.size = Vector2(420, 80)
    timer_label.text = "Time: 0.0s"
    $CanvasLayer.add_child(timer_label)

func create_lives_label():
    lives_label = Label.new()
    lives_label.position = Vector2(20, 160)
    lives_label.size = Vector2(420, 40)
    lives_label.text = "Lives: 1"
    $CanvasLayer.add_child(lives_label)

func create_combo_label():
    combo_label = Label.new()
    combo_label.position = Vector2(20, 200)
    combo_label.size = Vector2(420, 40)
    combo_label.text = "Combo: 0"
    $CanvasLayer.add_child(combo_label)

func create_overlay():
    overlay = ColorRect.new()
    overlay.color = Color(0.0, 0.0, 0.0, 0.75)
    overlay.size = Vector2(960, 540)
    overlay.position = Vector2(0, 0)
    overlay.visible = false
    $CanvasLayer.add_child(overlay)

    flash_overlay = ColorRect.new()
    flash_overlay.color = Color(1.0, 1.0, 1.0, 0.0)
    flash_overlay.size = Vector2(960, 540)
    flash_overlay.position = Vector2(0, 0)
    flash_overlay.visible = false
    $CanvasLayer.add_child(flash_overlay)

    game_over_title = Label.new()
    game_over_title.text = "Game Over"
    game_over_title.position = Vector2(380, 180)
    game_over_title.size = Vector2(200, 40)
    game_over_title.add_theme_font_size_override("font_size", 32)
    overlay.add_child(game_over_title)

    restart_button = Button.new()
    restart_button.text = "Restart"
    restart_button.position = Vector2(400, 260)
    restart_button.size = Vector2(120, 40)
    restart_button.pressed.connect(_on_restart_pressed)
    overlay.add_child(restart_button)

    resume_button = Button.new()
    resume_button.text = "Resume"
    resume_button.position = Vector2(400, 220)
    resume_button.size = Vector2(120, 40)
    resume_button.pressed.connect(_on_resume_pressed)
    resume_button.visible = false
    overlay.add_child(resume_button)

    quit_button = Button.new()
    quit_button.text = "Quit to Title"
    quit_button.position = Vector2(400, 280)
    quit_button.size = Vector2(120, 40)
    quit_button.pressed.connect(_on_quit_pressed)
    quit_button.visible = false
    overlay.add_child(quit_button)

    pause_label = Label.new()
    pause_label.text = "Paused"
    pause_label.position = Vector2(420, 180)
    pause_label.size = Vector2(120, 40)
    pause_label.visible = false
    pause_label.add_theme_font_size_override("font_size", 24)
    $CanvasLayer.add_child(pause_label)

func create_shop_ui():
    shop_panel = ColorRect.new()
    shop_panel.color = Color(0.15, 0.15, 0.2, 0.9)
    shop_panel.size = Vector2(320, 220)
    shop_panel.position = Vector2(320, 160)
    shop_panel.visible = false
    $CanvasLayer.add_child(shop_panel)

    shop_label = Label.new()
    shop_label.text = "Shop"
    shop_label.position = Vector2(20, 16)
    shop_label.size = Vector2(280, 30)
    shop_label.add_theme_font_size_override("font_size", 24)
    shop_panel.add_child(shop_label)

    speed_buy_button = Button.new()
    speed_buy_button.text = "Speed +1 (5 coins)"
    speed_buy_button.position = Vector2(20, 60)
    speed_buy_button.size = Vector2(280, 40)
    speed_buy_button.pressed.connect(_on_buy_speed_pressed)
    shop_panel.add_child(speed_buy_button)

    life_buy_button = Button.new()
    life_buy_button.text = "Extra Life (8 coins)"
    life_buy_button.position = Vector2(20, 120)
    life_buy_button.size = Vector2(280, 40)
    life_buy_button.pressed.connect(_on_buy_life_pressed)
    shop_panel.add_child(life_buy_button)

    shop_button = Button.new()
    shop_button.text = "Shop"
    shop_button.position = Vector2(760, 20)
    shop_button.size = Vector2(100, 40)
    shop_button.pressed.connect(_toggle_shop)
    $CanvasLayer.add_child(shop_button)

func _toggle_shop():
    if game_over or won:
        return
    shop_open = not shop_open
    shop_panel.visible = shop_open
    update_shop_text()

func update_shop_text():
    if shop_panel == null:
        return
    shop_label.text = "Shop - Coins: %d | Speed Lv: %d | Lives: %d" % [coin_count, move_speed_level, extra_lives]

func show_status_message(message: String):
    if status_label != null:
        status_label.text = message

func _on_buy_speed_pressed():
    if coin_count >= 5:
        coin_count -= 5
        move_speed_level += 1
        apply_player_upgrades()
        update_status()
        update_shop_text()
        show_flash(Color(0.2, 0.9, 0.4, 0.25))
        status_label.text = "Speed upgrade purchased!"

func _on_buy_life_pressed():
    if coin_count >= 8:
        coin_count -= 8
        extra_lives += 1
        apply_player_upgrades()
        update_status()
        update_shop_text()
        show_flash(Color(0.2, 0.7, 1.0, 0.25))
        status_label.text = "Extra life purchased!"

func apply_player_upgrades():
    if player_node != null and player_node.has_method("apply_upgrades"):
        player_node.apply_upgrades(move_speed_level, extra_lives)

func show_flash(color: Color):
    if flash_overlay == null:
        return
    flash_overlay.color = color
    flash_overlay.visible = true
    flash_timer = 0.12

func _on_player_life_used():
    if extra_lives > 0:
        extra_lives -= 1
        apply_player_upgrades()
        update_shop_text()
    show_flash(Color(1.0, 0.2, 0.2, 0.25))
    shake_camera(5.0, 0.2)
    status_label.text = "Ouch! You lost a life."

func create_floor():
    var floor = StaticBody2D.new()
    floor.position = Vector2(480, 500)
    add_child(floor)

    var shape = CollisionShape2D.new()
    var rectangle = RectangleShape2D.new()
    rectangle.size = Vector2(960, 40)
    shape.shape = rectangle
    floor.add_child(shape)

    var visual = ColorRect.new()
    visual.size = Vector2(960, 40)
    visual.position = Vector2(-480, -20)
    visual.color = Color(0.2, 0.2, 0.2)
    floor.add_child(visual)

func create_platforms():
    var platform_positions = [Vector2(260, 395), Vector2(690, 360)]
    if selected_level == 2:
        platform_positions = [Vector2(220, 385), Vector2(520, 320), Vector2(760, 360)]

    for position in platform_positions:
        var platform = StaticBody2D.new()
        platform.position = position
        add_child(platform)

        var shape = CollisionShape2D.new()
        var rectangle = RectangleShape2D.new()
        rectangle.size = Vector2(180, 20)
        shape.shape = rectangle
        platform.add_child(shape)

        var visual = ColorRect.new()
        visual.size = Vector2(180, 20)
        visual.position = Vector2(-90, -10)
        visual.color = Color(0.35, 0.2, 0.15)
        platform.add_child(visual)

func create_player():
    var player_scene = preload("res://scenes/player.tscn")
    var player = player_scene.instantiate()
    player.position = Vector2(120, 300)
    player.add_to_group("player")
    player.set_script(load("res://scripts/player.gd"))

    var collision = CollisionShape2D.new()
    var rectangle = RectangleShape2D.new()
    rectangle.size = Vector2(28, 28)
    collision.shape = rectangle
    player.add_child(collision)

    var visual = ColorRect.new()
    visual.size = Vector2(28, 28)
    visual.position = Vector2(-14, -14)
    visual.color = Color(0.2, 0.6, 1.0)
    player.add_child(visual)

    player.set_respawn_position(player.position)
    player.life_used.connect(_on_player_life_used)
    player.apply_upgrades(move_speed_level, extra_lives)
    player_node = player
    add_child(player)

func create_coins():
    var coin_scene = preload("res://scenes/coin.tscn")
    var coin_positions = [Vector2(400, 300), Vector2(640, 250), Vector2(860, 300), Vector2(260, 340)]

    for position in coin_positions:
        var coin = coin_scene.instantiate()
        coin.position = position
        coin.set_script(load("res://scripts/coin.gd"))
        coin.connect("collected", Callable(self, "_on_coin_collected"))

        var collision = CollisionShape2D.new()
        var circle = CircleShape2D.new()
        circle.radius = 12.0
        collision.shape = circle
        coin.add_child(collision)

        var visual = ColorRect.new()
        visual.size = Vector2(24, 24)
        visual.position = Vector2(-12, -12)
        visual.color = Color(1.0, 0.85, 0.2)
        coin.add_child(visual)

        add_child(coin)

func create_enemy():
    var enemy_scene = preload("res://scenes/enemy.tscn")
    var enemy = enemy_scene.instantiate()
    enemy.position = Vector2(640, 445)
    enemy.set_script(load("res://scripts/enemy.gd"))

    var collision = CollisionShape2D.new()
    var rectangle = RectangleShape2D.new()
    rectangle.size = Vector2(28, 28)
    collision.shape = rectangle
    enemy.add_child(collision)

    var visual = ColorRect.new()
    visual.size = Vector2(28, 28)
    visual.position = Vector2(-14, -14)
    visual.color = Color(0.9, 0.2, 0.2)
    enemy.add_child(visual)

    add_child(enemy)

func create_checkpoints():
    var checkpoint_positions = [Vector2(330, 360), Vector2(740, 310)]
    for position in checkpoint_positions:
        var checkpoint = Area2D.new()
        checkpoint.position = position
        checkpoint.set_script(load("res://scripts/checkpoint.gd"))
        checkpoint.connect("activated", Callable(self, "_on_checkpoint_activated"))
        add_child(checkpoint)

func create_goal():
    var goal_position = Vector2(900, 250)
    if selected_level == 2:
        goal_position = Vector2(840, 300)

    var goal = Area2D.new()
    goal.position = goal_position
    goal.set_script(load("res://scripts/goal.gd"))
    goal.connect("reached", Callable(self, "_on_goal_reached"))
    add_child(goal)

func load_audio_settings():
    var config = ConfigFile.new()
    if config.load("user://settings.cfg") == OK:
        music_enabled = config.get_value("audio", "music", true)
        sfx_enabled = config.get_value("audio", "sfx", true)

func create_background_music():
    music_player = AudioStreamPlayer.new()
    music_player.stream = create_music_stream()
    music_player.volume_db = -12.0
    music_player.autoplay = true
    add_child(music_player)
    if music_enabled:
        music_player.play()
    else:
        music_player.stop()

func create_music_stream() -> AudioStreamWAV:
    var stream = AudioStreamWAV.new()
    var sample_rate = 22050
    var duration = 2.0
    var total_samples = int(sample_rate * duration)
    var data = PackedByteArray()
    data.resize(total_samples * 2)

    var notes = [196.0, 261.0, 330.0, 392.0]
    var note_length = int(sample_rate * 0.35)

    for i in range(total_samples):
        var note_index = int(i / note_length) % notes.size()
        var frequency = notes[note_index]
        var t = i / float(sample_rate)
        var sample = sin(t * frequency * TAU) * 0.06 + sin(t * frequency * 2.0 * TAU) * 0.03
        var sample_value = int(sample * 20000.0)
        data[i * 2] = sample_value & 0xFF
        data[i * 2 + 1] = (sample_value >> 8) & 0xFF

    stream.mix_rate = sample_rate
    stream.format = AudioStreamWAV.FORMAT_16_BITS
    stream.stereo = false
    stream.data = data
    stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
    return stream

func _process(delta):
    if flash_timer > 0.0:
        flash_timer -= delta
        if flash_timer <= 0.0 and flash_overlay != null:
            flash_overlay.visible = false
            flash_overlay.color = Color(1.0, 1.0, 1.0, 0.0)

    if combo_timer > 0.0:
        combo_timer -= delta
        if combo_timer <= 0.0:
            combo_count = 0
            update_combo_label()

    if Input.is_action_just_pressed("ui_cancel"):
        toggle_pause()

    if Input.is_key_pressed(KEY_B):
        _toggle_shop()

    if game_over or paused or won:
        return

    elapsed_time += delta
    timer_label.text = "Time: %.1fs" % elapsed_time

func is_music_enabled():
    return music_enabled

func is_sfx_enabled():
    return sfx_enabled

func load_best_score():
    var config = ConfigFile.new()
    if config.load("user://highscore.cfg") == OK:
        best_score = config.get_value("score", "best", 0)

func load_selected_level():
    var config = ConfigFile.new()
    if config.load("user://selected_level.cfg") == OK:
        selected_level = config.get_value("level", "selected", 1)

func save_best_score():
    var config = ConfigFile.new()
    config.set_value("score", "best", best_score)
    config.save("user://highscore.cfg")

func update_combo_label():
    if combo_label != null:
        combo_label.text = "Combo: x%d" % combo_count if combo_count > 0 else "Combo: ready"

func update_status():
    coin_label.text = "Coins: %d / %d" % [coin_count, goal_coins]
    score = coin_count * 100 + combo_count * 25 + int(max(0.0, 60.0 - elapsed_time))
    if shop_panel != null:
        update_shop_text()
    if lives_label != null:
        lives_label.text = "Lives: %d" % [extra_lives + 1]
    update_combo_label()
    if score > best_score:
        best_score = score
        save_best_score()
    timer_label.text = "Time: %.1fs | Score: %d | Best: %d" % [elapsed_time, score, best_score]
    if coin_count >= goal_coins:
        status_label.text = "Portal unlocked! Reach the glowing gate."
    else:
        status_label.text = "Collect %d more coin(s) to unlock the portal." % [goal_coins - coin_count]

func _on_coin_collected(position):
    coin_count += 1
    if combo_timer > 0.0:
        combo_count += 1
    else:
        combo_count = 1
    combo_timer = 1.5
    update_status()
    spawn_floating_text("+%d" % (100 * combo_count), position)
    if combo_count > 1:
        status_label.text = "Combo x%d!" % combo_count

func _on_checkpoint_activated(position):
    active_checkpoint_position = position
    var player = get_tree().get_first_node_in_group("player")
    if player != null and player.has_method("set_respawn_position"):
        player.set_respawn_position(position)
    status_label.text = "Checkpoint saved!"

func _on_goal_reached():
    if coin_count >= goal_coins:
        trigger_win()
    else:
        status_label.text = "You still need %d more coin(s)." % [goal_coins - coin_count]

func trigger_game_over():
    if game_over:
        return

    game_over = true
    overlay.visible = true
    game_over_title.text = "Game Over"
    game_over_title.visible = true
    restart_button.visible = true
    resume_button.visible = false
    quit_button.visible = false
    pause_label.visible = false
    status_label.text = "You fell and need to restart."

func trigger_win():
    if won:
        return

    won = true
    overlay.visible = true
    game_over_title.text = "Level Complete!"
    game_over_title.visible = true
    restart_button.visible = true
    resume_button.visible = false
    quit_button.visible = false
    pause_label.visible = false
    status_label.text = "You escaped the level!"

func toggle_pause():
    if game_over or won:
        return

    paused = not paused
    get_tree().paused = paused

    if paused:
        overlay.visible = true
        game_over_title.visible = false
        restart_button.visible = false
        resume_button.visible = true
        quit_button.visible = true
        pause_label.visible = true
    else:
        overlay.visible = false
        game_over_title.visible = true
        restart_button.visible = true
        resume_button.visible = false
        quit_button.visible = false
        pause_label.visible = false

func _on_restart_pressed():
    get_tree().paused = false
    get_tree().reload_current_scene()

func _on_resume_pressed():
    toggle_pause()

func _on_quit_pressed():
    get_tree().paused = false
    get_tree().change_scene_to_file("res://scenes/title_screen.tscn")

func shake_camera(intensity: float, duration: float):
    if _camera == null:
        return
    var original_offset = _camera.offset
    var elapsed = 0.0
    while elapsed < duration:
        _camera.offset = original_offset + Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity))
        elapsed += get_process_delta_time()
        await get_tree().process_frame
    _camera.offset = original_offset

func spawn_floating_text(text: String, world_position: Vector2):
    if _camera == null:
        return
    var screen_pos = _camera.unproject_position(world_position)
    var label = Label.new()
    label.text = text
    label.position = screen_pos
    label.add_theme_font_size_override("font_size", 20)
    label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
    $CanvasLayer.add_child(label)
    var tween = create_tween()
    tween.tween_property(label, "position", screen_pos + Vector2(randf_range(-20, 20), -50), 0.8)
    tween.parallel().tween_property(label, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.8)
    tween.tween_callback(label.queue_free)
