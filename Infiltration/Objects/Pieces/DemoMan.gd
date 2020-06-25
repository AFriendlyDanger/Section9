extends "res://Objects/Pieces/Piece.gd"

func _ready():
	pass
	
func Attack():
	print("attack")

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
