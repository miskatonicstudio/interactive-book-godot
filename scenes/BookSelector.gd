extends Control

onready var books = $VBoxContainer/ScrollContainer/Books
onready var book_template = $VBoxContainer/ScrollContainer/Books/Book


func _ready():
	var dir = Directory.new()
	dir.make_dir_recursive(global.BOOKS_DIR + "/test")
	dir.copy("res://books/test/0.jpg", global.BOOKS_DIR + "/test/0.jpg")
	refresh_books()


func refresh_books():
	for book in books.get_children():
		if book != book_template:
			books.remove_child(book)
	book_template.show()
	
	var book_names = []
	var books_dir = Directory.new()
	if books_dir.open(global.BOOKS_DIR) == OK:
		books_dir.list_dir_begin(true, true)
		var book_name = books_dir.get_next()
		while book_name != "":
			book_names.append(book_name)
			book_name = books_dir.get_next()
	
	book_names.sort()
	for book_name in book_names:
		create_book_node(book_name)
	# Hide the template node
	book_template.hide()


func create_book_node(book_name):
	var book_path = global.BOOKS_DIR + "/" + book_name
	var new_book = book_template.duplicate()
	new_book.get_node(
		"VBoxContainer/TextureRect"
	).texture = global.load_image_texture(book_path + "/0.jpg")
	new_book.get_node(
		"VBoxContainer/Label"
	).text = book_name.capitalize()
	new_book.connect("pressed", self, "_on_Book_button_pressed", [book_path])
	books.add_child(new_book)


func _on_Book_button_pressed(book_path):
	global.emit_signal("switch_book", book_path)


func _on_Clear_pressed():
	var books_dir = Directory.new()
	if books_dir.open(global.BOOKS_DIR) == OK:
		books_dir.list_dir_begin(true, true)
		var book_name = books_dir.get_next()
		while book_name != "" and book_name != "test":
			# Remove the files first
			var single_book_dir = Directory.new()
			if single_book_dir.open(
				global.BOOKS_DIR + "/" + book_name
			) == OK:
				single_book_dir.list_dir_begin(true, true)
				var page_name = single_book_dir.get_next()
				while page_name != "":
					single_book_dir.remove(page_name)
					page_name = single_book_dir.get_next()
			# Remove empty directory
			books_dir.remove(book_name)
			book_name = books_dir.get_next()
	refresh_books()


func _on_Refresh_pressed():
	refresh_books()
