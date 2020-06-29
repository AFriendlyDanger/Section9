extends "res://Objects/Pieces/Piece.gd"
var defending = false
var sight = []
onready var sprite = $Sprite

func _ready():
	classType = Global.Class.Security
	
func Attack():
	if !defending:
		sight = mapNode.LineOfSight(boardpos,facing)
		mapNode.attackHit(sight,self)

func Interact():
	Reposition()

func Reposition():
	defending = !defending
	var rect = sprite.region_rect
	if defending:
		sprite.region_rect =  Rect2(Vector2(64,rect.position.y),Vector2(16,16))
		sight = []
	else:
		sprite.region_rect =  Rect2(Vector2(32,rect.position.y),Vector2(16,16))
	
