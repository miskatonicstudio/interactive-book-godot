extends Control

export (bool) var textured = false

onready var text = $Background/Text
onready var number = $Background/Number
onready var texture = $Background/Texture


func _ready():
	texture.visible = textured
	text.visible = not textured
	number.visible = not textured


func set_number(page_number):
	if textured:
		var page_file = "%s/%d.jpg" % [
			global.book_name, page_number
		]
		if File.new().file_exists(page_file):
			texture.texture = global.load_image_texture(page_file)
			texture.show()
		else:
			texture.hide()
	else:
		number.text = str(page_number) + "\n"
