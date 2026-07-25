extends Control

var help_panel = null
var settings_panel = null
var credits_panel = null
var music_toggle = null
var sfx_toggle = null

func _ready():
    var start_button = get_node("StartButton")
    start_button.pressed.connect(_on_start_pressed)

    var help_button = get_node("HelpButton")
    help_button.pressed.connect(_on_help_pressed)

    var settings_button = get_node("SettingsButton")
    settings_button.pressed.connect(_on_settings_pressed)

    var credits_button = get_node("CreditsButton")
    credits_button.pressed.connect(_on_credits_pressed)

    help_panel = get_node("HelpPanel")
    help_panel.visible = false

    settings_panel = get_node("SettingsPanel")
    settings_panel.visible = false

    credits_panel = get_node("CreditsPanel")
    credits_panel.visible = false

    music_toggle = get_node("SettingsPanel/MusicToggle")
    sfx_toggle = get_node("SettingsPanel/SfxToggle")

    music_toggle.toggled.connect(_on_music_toggled)
    sfx_toggle.toggled.connect(_on_sfx_toggled)

    var config = ConfigFile.new()
    if config.load("user://settings.cfg") == OK:
        music_toggle.button_pressed = config.get_value("audio", "music", true)
        sfx_toggle.button_pressed = config.get_value("audio", "sfx", true)
    else:
        music_toggle.button_pressed = true
        sfx_toggle.button_pressed = true

func _on_start_pressed():
    var config = ConfigFile.new()
    config.set_value("audio", "music", music_toggle.button_pressed)
    config.set_value("audio", "sfx", sfx_toggle.button_pressed)
    config.save("user://settings.cfg")
    get_tree().change_scene_to_file("res://scenes/level_select.tscn")

func _on_help_pressed():
    help_panel.visible = not help_panel.visible

func _on_settings_pressed():
    settings_panel.visible = not settings_panel.visible

func _on_credits_pressed():
    credits_panel.visible = not credits_panel.visible

func _on_music_toggled(enabled):
    var config = ConfigFile.new()
    config.set_value("audio", "music", enabled)
    config.save("user://settings.cfg")

func _on_sfx_toggled(enabled):
    var config = ConfigFile.new()
    config.set_value("audio", "sfx", enabled)
    config.save("user://settings.cfg")
