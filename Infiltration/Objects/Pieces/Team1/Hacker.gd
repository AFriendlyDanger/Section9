extends "res://Objects/Pieces/Piece.gd"

onready var hackSelector = get_node("HackSelector")
var hacking = false
remotesync var selectorpos = 0
remotesync var hackpos = 0

func _ready():
	classType = Global.Class.Hacker
	
func Attack():
	print("Hacker has no attack")

func Interact():
	if rpc("UploadVirus",int(boardpos+facing)):
		ActionUsed()
	else:
		hack(int(boardpos+facing))

func hack(terminalPos):
	if mapNode.tiles[terminalPos].console && mapNode.tiles[terminalPos].intact:
		hacking = true
		hackSelector.position = Vector2(sign(facing) * int(abs(facing)==1) * 16,int(facing/Global.BOARDWIDTH)*16)
		hackSelector.visible = true
		selectorpos = int(boardpos + facing)
		print("hacking")

func inputCheck():
	if !hacking:
		.inputCheck()
	else:
		hackingInput()

func hackingInput():
	if Input.is_action_just_pressed("interact"):
		rset("selectorpos",selectorpos)
		rset("hackpos",hackSelector.global_position)
		rpc("Disable")
	elif Input.is_action_just_pressed("ui_cancel"):
		HackOver()
		mapNode.camera.position = Vector2(global_position.x-Global.BOARDWIDTH*4,0)
		mapNode.FixCamera()
	elif Input.is_action_just_pressed("ui_right"):
		MoveSelector(Global.RIGHT,Vector2.RIGHT*16)
	elif Input.is_action_just_pressed("ui_left"):
		MoveSelector(Global.LEFT,Vector2.LEFT*16)
	elif Input.is_action_just_pressed("ui_up"):
		MoveSelector(Global.UP,Vector2.UP*16)
	elif Input.is_action_just_pressed("ui_down"):
		MoveSelector(Global.DOWN,Vector2.DOWN*16)


func MoveSelector(direction,movement):
	if !(selectorpos%Global.BOARDWIDTH == 0 && direction == Global.LEFT) &&\
		!((selectorpos+1)%Global.BOARDWIDTH == 0 && direction == Global.RIGHT) &&\
		(selectorpos + direction >= 0) && (selectorpos + direction < mapNode.tiles.size()):
		hackSelector.position += movement
		selectorpos += direction
		mapNode.camera.position = Vector2(hackSelector.global_position.x-Global.BOARDWIDTH*4,0)
		mapNode.FixCamera()


func HackOver():
	hacking = false
	hackSelector.visible = false

remotesync func Disable():
	if(mapNode.tiles[selectorpos].OpenDoor()):
		if mapNode.attackHit([selectorpos],self):
			var tile = mapNode.tiles[selectorpos]
			tile.intact = false
			tile.frame = 8
			tile.z_index = -1
		mapNode.RecalcLOS()
		HackOver()
		ActionUsed()
	else:
		var space_state = get_world_2d().direct_space_state
		var layer_mask = 1|1<<2 
		var result = space_state.intersect_point(hackpos,1,[self],layer_mask,true,true)
		if !result.empty():
			var SecCam = result[0]["collider"]
			var visibleRes = SecCam.visible
			SecCam.visible = !visibleRes
			SecCam.position += Vector2.ONE*-100
			SecCam.collision_layer = (int(!visibleRes)<<0)|(1<<2)
			SecCam.position += Vector2.ONE*100
			HackOver()
			ActionUsed()
