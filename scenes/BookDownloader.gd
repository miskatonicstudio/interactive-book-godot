extends Control

# TODO: make this configurable
const BOOKS_SERVER = "https://miskatonicstudio.com/downloads/books"

onready var books = $VBoxContainer/ScrollContainer/Books
onready var book_template = $VBoxContainer/ScrollContainer/Books/Book


func _ready():
	book_template.hide()
	refresh_books()


func refresh_books():
	for book in books.get_children():
		if book != book_template:
			books.remove_child(book)
	
	call(BOOKS_SERVER, {"type": "list_books"})


func create_book_node(book_name):
	if books.has_node(book_name):
		print("Book already exists")
		return
	var new_book = book_template.duplicate()
	new_book.name = book_name
	new_book.show()
	new_book.get_node(
		"VBoxContainer/Label"
	).text = book_name.capitalize()
	new_book.connect("pressed", self, "_on_Book_button_pressed", [book_name])
	books.add_child(new_book)


func _on_Book_button_pressed(book_name):
	var book_url = BOOKS_SERVER + "/" + book_name
	call(book_url, {"type": "download_book", "name": book_name})


func _on_Refresh_pressed():
	refresh_books()


func get_links_from_body(body):
	var links = []
	var html = body.get_string_from_utf8()
	var link_regex = RegEx.new()
	link_regex.compile("(?<=a href=\")\\w+[\\.\\w+]*")
	for link in link_regex.search_all(html):
		links.append(link.get_string())
	return links


func get_image_from_body(body):
	var img = Image.new()
	img.load_jpg_from_buffer(body)
	return img


func call(url, extra=null):
	if extra == null:
		extra = {}
	var http = HTTPRequest.new()
	http.use_threads = true
	extra["node"] = http
	add_child(http)
	http.connect("request_completed", self, "_on_request_completed", [extra])
	http.request(url)


func _on_request_completed(result, response_code, _headers, body, extra):
	# Remove HTTPRequest node that started this call
	var node = extra.get("node")
	if node:
		remove_child(node)
		node.queue_free()
	
	if result:
		print("Call failed: ", response_code)
		return
	
	var type = extra.get("type")
	if type == "list_books":
		var book_names = get_links_from_body(body)
		book_names.sort()
		for book_name in book_names:
			create_book_node(book_name)
			var book_cover_path = "{0}/{1}/0.jpg".format(
				[BOOKS_SERVER, book_name]
			)
			call(book_cover_path, {"type": "cover", "name": book_name})
	if type == "cover":
		var book_name = extra.get("name")
		var book_node = books.get_node(book_name)
		if not book_node:
			print("Book not found: ", book_name)
			return
		var img = get_image_from_body(body)
		var tex = ImageTexture.new()
		tex.create_from_image(img, 4)
		book_node.get_node("VBoxContainer/TextureRect").texture = tex
	if type == "download_book":
		var book_name = extra.get("name")
		var book_node = books.get_node(book_name)
		if not book_node:
			print("Book not found: ", book_name)
			return
		var books_dir = Directory.new()
		if books_dir.open(global.BOOKS_DIR) == OK:
			books_dir.make_dir(book_name)
		var pages = get_links_from_body(body)
		var progress_bar = book_node.get_node("ProgressBar")
		progress_bar.max_value = len(pages)
		progress_bar.value = 0
		progress_bar.show()
		for page in pages:
			var page_path = "{0}/{1}/{2}".format(
				[BOOKS_SERVER, book_name, page]
			)
			call(page_path, {
				"type": "download_page", "book": book_name,
				"page": page
			})
	if type == "download_page":
		var book_name = extra["book"]
		var page = extra["page"]
		var page_path = "{0}/{1}/{2}".format([
			global.BOOKS_DIR, book_name, page
		])
		var page_file = File.new()
		page_file.open(page_path, File.WRITE)
		page_file.store_buffer(body)
		page_file.close()
		
		var book_node = books.get_node(book_name)
		if not book_node:
			print("Book not found: ", book_name)
			return
		var progress_bar = book_node.get_node("ProgressBar")
		progress_bar.value += 1
		if progress_bar.value == progress_bar.max_value:
			progress_bar.hide()
