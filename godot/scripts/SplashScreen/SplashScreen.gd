extends Control


export(String, FILE, "*.tscn, *.scn") var _target_scene: = ""


var transition : bool = false


func _physics_process(_delta) -> void:
	pass


func _input(event):
	if not event is InputEventMouse:
		$AnimationPlayer.play("Fade")


func _on_AnimationPlayer_animation_finished(anim_name) -> void:
	if anim_name == "Fade" or "Splash_Screen":
		InteractiveLoader.go_to(_target_scene)
