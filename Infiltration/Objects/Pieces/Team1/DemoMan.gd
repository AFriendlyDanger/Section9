extends "res://Objects/Pieces/Piece.gd"

func _ready():
	classType = Global.Class.Demoman
	
func Attack():
	mapNode.attackHit([boardpos+facing*3],self)
	ActionUsed()

func Interact():
	if rpc("UploadVirus",int(boardpos+facing)):
		ActionUsed()
	else:
		rpc("destroyWall",int(boardpos+facing))

remotesync func destroyWall(wallpos):
	if wallpos>Global.BOARDWIDTH && wallpos<mapNode.tiles.size()-Global.BOARDWIDTH \
	&& !(wallpos%Global.BOARDWIDTH == 0 || wallpos%Global.BOARDWIDTH == Global.BOARDWIDTH-1):
		var tile = mapNode.tiles[wallpos]
		if tile.wall && !tile.console:
			tile.intact = false
			tile.frame = 8
			tile.z_index = -1
			mapNode.RecalcLOS()
			ActionUsed()
