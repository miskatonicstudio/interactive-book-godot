extends Control

export (bool) var textured = false

onready var text = $Background/Text
onready var number = $Background/Number
onready var texture = $Background/Texture


func _ready():
	texture.visible = textured
	text.visible = not textured
	number.visible = not textured


func set_number(value):
	if textured:
		var page_file = "res://books/outer_space_01/%d.jpg" % value
		if ResourceLoader.exists(page_file):
			texture.texture = load(page_file)
			texture.show()
		else:
			texture.hide()
	else:
		number.text = str(value) + "\n"
