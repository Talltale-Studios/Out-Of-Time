extends Node


var loader
var wait_frames
var time_max = 100 # msec
var current_scene


func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() -1)


func _process(_time):
	# No need to process anymore
	if loader == null:
		set_process(false)
		return

	# Wait for frames to let the "loading" animation show up
	if wait_frames > 0:
		wait_frames -= 1
		return

	var t = OS.get_ticks_msec()
	# Use "time_max" to control for how long we block this thread
	while OS.get_ticks_msec() < t + time_max:
		# Poll your loader
		var err = loader.poll()

		if err == ERR_FILE_EOF: # Finished loading
			var resource = loader.get_resource()
			loader = null
			_set_new_scene(resource)
			break
		elif err == OK:
			_update_progress()
		else: # Error during loading
			# show_error()
			loader = null
			break


func _update_progress():
	var progress = float(loader.get_stage()) / loader.get_stage_count()

	# Update your progress bar
	get_node("Control/ProgressBar").max_value = loader.get_stage_count()
	get_node("Control/ProgressBar").value = progress

	# ...or update a progress animation
	# var length = get_node("Animation").get_current_aniamtion_length()

	# Call this on a paused animation. Use "true" as the second argument to force the animation to update.
	# get_node("Animation").seek(progress * length, true)


func _set_new_scene(scene_resource):
	current_scene = scene_resource.instance()
	get_node("/root").add_child(current_scene)
	$Control/ProgressBar.hide()


func go_to(path): # Game requests to switch to this scene
	current_scene.queue_free() # Get rid of the old scene
	loader = ResourceLoader.load_interactive(path)
	if loader == null: # Check for errors
		# show_error()
		return
	set_process(true)



	# Start your loading animation here
	get_node("Control/ProgressBar").show()

	wait_frames = 1
