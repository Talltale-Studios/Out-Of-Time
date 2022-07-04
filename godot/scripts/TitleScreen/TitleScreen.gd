extends CanvasLayer


export(String, FILE, '*.tscn, *.scn') var _target_scene: = ""
export (float) var scroll_speed = 50


var _credits_screen = "res://scenes/credits_screen/CreditsScreen.tscn"


onready var parallax : ParallaxBackground = $MainMenu/Overlay/ParallaxBackground
onready var start_menu : Control = $MainMenu/Overlay/StartMenu
onready var quit_confirmation : Control = $MainMenu/Overlay/QuitConfirmation
onready var settings_menu : Control = $MainMenu/Overlay/SettingsMenu


func _process(delta) -> void:
	parallax.scroll_offset.x -= scroll_speed * delta


func _on_ContinueButton_pressed():
	pass


func _on_StartButton_pressed() -> void:
	InteractiveLoader.go_to(_target_scene)


func _on_OptionsButton_pressed() -> void:
	start_menu.hide()
	settings_menu.show()


func _on_BackButton_pressed() -> void:
	start_menu.show()
	settings_menu.hide()


func _on_CreditsButton_pressed() -> void:
	InteractiveLoader.go_to(_credits_screen)


func _on_QuitButton_pressed() -> void:
	start_menu.hide()
	quit_confirmation.show()


func _on_YesButton_pressed() -> void:
	get_tree().quit()


func _on_NoButton_pressed() -> void:
	start_menu.show()
	quit_confirmation.hide()
