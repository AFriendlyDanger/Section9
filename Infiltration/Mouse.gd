extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position = get_global_mouse_position() *  (get_tree().root.get_viewport().size.x/get_viewport().get_visible_rect().size.x)

func _input(event):
	if event is InputEventMouseButton && event.is_pressed():
		#print("Viewport size: ", get_viewport_rect().size)
		print(get_tree().root.get_viewport().size)
		print("OS window size: ", OS.get_real_window_size())
		print("mouse pos: ", get_viewport().get_mouse_position())
