extends Node

const BOOKS_DIR = "user://books"
# TODO: remove this from global
var book_name = "user://books/test"

signal switch_book (book_name)
signal switch_environment (environment_name)


func load_image_texture(path):
	var img = Image.new()
	img.load(path)
	var img_tex = ImageTexture.new()
	img_tex.create_from_image(img, 4)
	return img_tex
