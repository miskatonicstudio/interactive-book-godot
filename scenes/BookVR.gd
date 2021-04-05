extends Spatial

# The current page is the one on the left, 0 is the cover
var current_page_number = -1
# TODO: calculate this depending on book length
const MAX_PAGE = 35

# This is displayed when pages are not moving
onready var static_page = $Book/Static
# This is displayed when pages are moving
onready var turning_page = $Book/Turning
onready var turning_animation = $Book/Turning/Page/AnimationPlayer

# Pages when turning: left, animated side 1, animated side 2, right
onready var pf1 = $Book/Turning/PageLeft
onready var pf2 = $Book/Turning/Page/Front
onready var pf3 = $Book/Turning/Page/Back
onready var pf4 = $Book/Turning/PageRight

# Pages when static: left, right
onready var ps1 = $Book/Static/PageLeft
onready var ps2 = $Book/Static/PageRight

# There are 6 viewports. Current page (left) is v3, to its right is v4.
# Moreover, there are 2 pages before (v1, v2) and after (v5, v6)
onready var v1 = $Viewport1
onready var v2 = $Viewport2
onready var v3 = $Viewport3
onready var v4 = $Viewport4
onready var v5 = $Viewport5
onready var v6 = $Viewport6

onready var raycast = $ARVRCamera/RayCast


func _ready():
	var arvr_interface = ARVRServer.find_interface("Native mobile")
	if arvr_interface and arvr_interface.initialize():
		get_viewport().arvr = true
	update_page_number()
	set_texture(ps1, v3)
	set_texture(ps2, v4)


func _input(_event):
	if turning_animation.is_playing():
		return
	
	if Input.is_action_just_pressed("click"):
		var collider = raycast.get_collider()
		if collider:
			for group in collider.get_groups():
				if group.find("book_title:") >= 0:
					var book_name = group.replace("book_title:", "")
					global.book_name = book_name
					update_page_number()
					break
				if group.find("left") >= 0 and current_page_number > 0:
					turn_left()
					break
				if group.find("right") >= 0 and current_page_number < MAX_PAGE:
					turn_right()
					break


func turn_right():
	set_texture(pf1, v3)
	set_texture(pf2, v4)
	set_texture(pf3, v5)
	set_texture(pf4, v6)
	turning_page.show()
	static_page.hide()
	update_page_visibility(0)
	turning_animation.play("Turn1")


func turn_left():
	set_texture(pf1, v1)
	set_texture(pf2, v2)
	set_texture(pf3, v3)
	set_texture(pf4, v4)
	turning_page.show()
	static_page.hide()
	update_page_visibility(-2)
	turning_animation.play("Turn2")


func update_page_number(page_offset = 0):
	"""Changes current page's number by the offset and updates the viewports."""
	current_page_number += page_offset
	var number_offset = -2
	for v in [v1, v2, v3, v4, v5, v6]:
		v.get_node("Page").set_number(current_page_number + number_offset)
		number_offset += 1
	update_page_visibility(0)


func set_texture(page, viewport):
	"""Attaches a viewport texture to a page."""
	page.material_override.albedo_texture = viewport.get_texture()


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Turn1":
		update_page_number(2)
	if anim_name == "Turn2":
		update_page_number(-2)
	static_page.show()
	turning_page.hide()


func update_page_visibility(offset = 0):
	var future_page_number = current_page_number + offset
	if future_page_number < 0:
		ps1.hide()
		pf1.hide()
	else:
		ps1.show()
		pf1.show()
	if future_page_number >= MAX_PAGE:
		ps2.hide()
	else:
		ps2.show()
	if future_page_number + 3 >= MAX_PAGE:
		pf4.hide()
	else:
		pf4.show()
