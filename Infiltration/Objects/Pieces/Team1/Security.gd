extends "res://Objects/Pieces/Piece.gd"
var defending = false
remotesync var sight = []
onready var sprite = $Sprite
var attack_switch = false

func _ready():
	classType = Global.Class.Security
	action_text = "Stance"
	
func inputCheck() :
	if !attack_switch || Input.is_action_just_pressed("attack") || Input.is_action_just_pressed("ui_cancel"):
		.inputCheck()
	
func Attack():
	if !defending:
		sight = mapNode.LineOfSight(boardpos,facing)
		mapNode.attackHit(sight,self)
		attack_switch = false
		ActionUsed()

func Interact():
	if rpc("UploadVirus",int(boardpos+facing)):
		ActionUsed()
	else:
		if !attack_switch:
			mapNode.attack_ui.visible = defending
			rpc("Reposition")
	

remotesync func Reposition():
	defending = !defending
	var rect = sprite.region_rect
	if defending:
		sprite.region_rect =  Rect2(Vector2(64,rect.position.y),Vector2(16,16))
		sight = []
		ActionUsed()
	else:
		sprite.region_rect =  Rect2(Vector2(32,rect.position.y),Vector2(16,16))
		attack_switch = true

func NewTurn():
	attack_switch = false
	.NewTurn()

func set_ui():
	mapNode.attack_ui.LabelText("Shoot")
	mapNode.attack_ui.visible = !defending
	.set_ui()
