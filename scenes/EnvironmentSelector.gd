extends Control

onready var environments = $ScrollContainer/Environments
onready var environment_node = $ScrollContainer/Environments/Environment


func _ready():
	var env_dirs = []
	var dir = Directory.new()
	if dir.open("res://resources/environments") == OK:
		dir.list_dir_begin()
		var dir_name = dir.get_next()
		while dir_name != "":
			if dir_name.find(".") < 0 and dir.current_is_dir():
				env_dirs.append("res://resources/environments/" + dir_name)
			dir_name = dir.get_next()
	
	env_dirs.sort()
	for env_dir in env_dirs:
		var new_env = environment_node.duplicate()
		new_env.texture_normal = load(env_dir + "/cover.jpg")
		new_env.connect(
			"pressed", self, "_on_Environment_button_pressed", [env_dir]
		)
		environments.add_child(new_env)
	environments.remove_child(environment_node)


func _on_Environment_button_pressed(environment_name):
	global.emit_signal("switch_environment", environment_name)
