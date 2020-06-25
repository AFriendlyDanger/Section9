extends Node2D

const pathTiles = preload("res://Objects/path.tscn")
var path = []
onready var mapNode = $"../../"


func _ready():
	
	#var maxint = 9223372036854775807
	var mask = -1 << 3 | 15
	print(mask)
	var booltest = true
	print((1 << 2) | (int(booltest) << 1))
	var test = 1 << 2
	createTile(Vector2(24,104),0,true)
	if(test & (1<<2)):
		print("2nd bit set")

func createTile(location, rtn, first = false):
	if(first || !mapNode.tiles[(location.x-8)/16+(location.y-8)*2].wall):
		var tileInstance = pathTiles.instance()
		tileInstance.position = location
		#tileInstance.rotation = rotation
		if path.back() != null:
			if path.size() == 1:
				path[0].frame = 4
				path[0].rotation_degrees = rtn
			elif path.back().rotation_degrees == rtn:
				path.back().frame = 1
			else:
				path.back().frame = 3
				var prevRtn = path.back().rotation_degrees
				if (rtn > prevRtn && rtn*prevRtn + rtn != 270):
					path.back().flip_h = true
				elif rtn == 0 && prevRtn == 270:
					path.back().flip_h = true
			tileInstance.rotation_degrees = rtn
			tileInstance.frame = 2
		self.add_child(tileInstance)
		path.append(tileInstance)

func _process(_delta):
	if Input.is_action_just_pressed("ui_right"):
		createTile(path.back().position + Vector2.RIGHT*16,90)
	elif Input.is_action_just_pressed("ui_left"):
		createTile(path.back().position + Vector2.LEFT*16,270)
	elif Input.is_action_just_pressed("ui_up"):
		createTile(path.back().position + Vector2.UP*16,0)
	elif Input.is_action_just_pressed("ui_down"):
		createTile(path.back().position + Vector2.DOWN*16,180)

