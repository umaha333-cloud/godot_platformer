extends Control

func _ready():
    get_node("Level1Button").pressed.connect(_on_level1_pressed)
    get_node("Level2Button").pressed.connect(_on_level2_pressed)
    get_node("BackButton").pressed.connect(_on_back_pressed)

func save_selected_level(level_id: int):
    var config = ConfigFile.new()
    config.set_value("level", "selected", level_id)
    config.save("user://selected_level.cfg")

func _on_level1_pressed():
    save_selected_level(1)
    get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_level2_pressed():
    save_selected_level(2)
    get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_back_pressed():
    get_tree().change_scene_to_file("res://scenes/title_screen.tscn")
