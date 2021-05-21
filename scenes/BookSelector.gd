extends Control

onready var books = $ScrollContainer/Books
onready var book_node = $ScrollContainer/Books/Book


func _ready():
	var book_dirs = []
	var dir = Directory.new()
	if dir.open("res://books") == OK:
		dir.list_dir_begin()
		var dir_name = dir.get_next()
		while dir_name != "":
			if dir_name.find(".") < 0:
				book_dirs.append("res://books/" + dir_name)
			dir_name = dir.get_next()
	
	book_dirs.sort()
	for book_dir in book_dirs:
		var new_book = book_node.duplicate()
		new_book.texture_normal = load(book_dir + "/0.jpg")
		new_book.connect("pressed", self, "_on_Book_button_pressed", [book_dir])
		books.add_child(new_book)
	books.remove_child(book_node)


func _on_Book_button_pressed(book_name):
	global.emit_signal("switch_book", book_name)
