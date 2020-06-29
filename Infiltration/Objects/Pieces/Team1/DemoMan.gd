extends "res://Objects/Pieces/Piece.gd"

func _ready():
	classType = Global.Class.Demoman
	
func Attack():
	mapNode.attackHit([boardpos+facing*3],self)

func Interact():
	print("interact")
	destroyWall(int(boardpos+facing))

func destroyWall(wallpos):
	if wallpos>Global.BOARDWIDTH && wallpos<mapNode.tiles.size()-Global.BOARDWIDTH \
	&& !(wallpos%Global.BOARDWIDTH == 0 || wallpos%Global.BOARDWIDTH == Global.BOARDWIDTH-1):
		var tile = mapNode.tiles[wallpos]
		if tile.wall:
			tile.intact = false
			tile.frame = 8
			tile.z_index = -1
			mapNode.RecalcLOS()
