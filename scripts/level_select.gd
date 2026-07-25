extends Control

@onready var level_1_button: Button = $Level1Button
@onready var level_2_button: Button = $Level2Button
@onready var back_button: Button = $BackButton

func _ready() -> void:
    level_1_button.pressed.connect(_on_level1_pressed)
    level_2_button.pressed.connect(_on_level2_pressed)
    back_button.pressed.connect(_on_back_pressed)

func save_selected_level(level_id: int) -> void:
    var config := ConfigFile.new()
    config.set_value("level", "selected", level_id)
    config.save("user://selected_level.cfg")

func _on_level1_pressed() -> void:
    save_selected_level(1)
    get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_level2_pressed() -> void:
    save_selected_level(2)
    get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_back_pressed() -> void:
    get_tree().change_scene_to_file("res://scenes/title_screen.tscn")
