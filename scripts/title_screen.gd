extends Control

@onready var start_button: Button = $MenuPanel/StartButton
@onready var help_button: Button = $MenuPanel/HelpButton
@onready var settings_button: Button = $MenuPanel/SettingsButton
@onready var credits_button: Button = $MenuPanel/CreditsButton
@onready var help_panel: Panel = $HelpPanel
@onready var settings_panel: Panel = $SettingsPanel
@onready var credits_panel: Panel = $CreditsPanel
@onready var music_toggle: CheckBox = $SettingsPanel/MusicToggle
@onready var sfx_toggle: CheckBox = $SettingsPanel/SfxToggle

func _ready() -> void:
    start_button.pressed.connect(_on_start_pressed)
    help_button.pressed.connect(_on_help_pressed)
    settings_button.pressed.connect(_on_settings_pressed)
    credits_button.pressed.connect(_on_credits_pressed)
    music_toggle.toggled.connect(_on_music_toggled)
    sfx_toggle.toggled.connect(_on_sfx_toggled)

    help_panel.visible = false
    settings_panel.visible = false
    credits_panel.visible = false

    var config := ConfigFile.new()
    if config.load("user://settings.cfg") == OK:
        music_toggle.button_pressed = config.get_value("audio", "music", true)
        sfx_toggle.button_pressed = config.get_value("audio", "sfx", true)
    else:
        music_toggle.button_pressed = true
        sfx_toggle.button_pressed = true

func _on_start_pressed() -> void:
    get_tree().change_scene_to_file("res://scenes/level_select.tscn")

func _on_help_pressed() -> void:
    help_panel.visible = not help_panel.visible

func _on_settings_pressed() -> void:
    settings_panel.visible = not settings_panel.visible

func _on_credits_pressed() -> void:
    credits_panel.visible = not credits_panel.visible

func _on_music_toggled(enabled: bool) -> void:
    var config := ConfigFile.new()
    config.set_value("audio", "music", enabled)
    config.save("user://settings.cfg")

func _on_sfx_toggled(enabled: bool) -> void:
    var config := ConfigFile.new()
    config.set_value("audio", "sfx", enabled)
    config.save("user://settings.cfg")

