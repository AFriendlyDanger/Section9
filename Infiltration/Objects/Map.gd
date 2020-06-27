extends Node2D
#tool

var tiles = []
var pieces = []
var players = []


func _ready():
	tiles.resize(self.get_node("Tiles").get_child_count())
	print(tiles.size())
	var tileNode = get_node("Tiles")
	for child in tileNode.get_children():
		var arrayNum = child.position.x/16 + child.position.y/16*Global.BOARDWIDTH
		tiles[arrayNum] = child
	#set Map.gd and Tile.gd as tool to automatically arrange tile sprites 
	if Engine.editor_hint:
		for t in range(tiles.size()):
			var tiledata = 0
			if !tiles[t].wall:
				SetGroundtile(t,tiledata)
			elif tiles[t].door:
				SetDoortile(t)
			elif !tiles[t].console:
				SetWalltile(t,tiledata)
	for child in self.get_children():
		if child.name != "Tiles":
			players.append(child)
			#for piece in child.get_children():
			#	pieces.append(piece)
	print(bool(0))
	pieces = get_tree().get_nodes_in_group("Piece")
	#SetWalltile(95+BOARDWIDTH,0)
			
			
			
			
func SetGroundtile(tileLoc,tiledata):
	var bordertile = tileLoc-Global.BOARDWIDTH-1
	#find tile topleft of target
	if !(bordertile<0||(bordertile+1)%Global.BOARDWIDTH==0):
		tiledata = (tiledata << 2) | tiles[bordertile].status()
	#find tile top of target
	bordertile += 1
	if !(bordertile<0):
		tiledata = (tiledata << 2) | tiles[bordertile].status()
	#find tile left of target
	bordertile = tileLoc-1
	if !((bordertile+1)%Global.BOARDWIDTH==0):
		tiledata = (tiledata << 2) | tiles[bordertile].status()
	tiles[tileLoc].setTile(tiledata)
	
func SetDoortile(tileLoc):
	var bordertile = tileLoc-Global.BOARDWIDTH
	if(!(bordertile<0) && tiles[bordertile].wall):
		tiles[tileLoc].frame = 20

func SetWalltile(tileLoc,tiledata):
	var bordertile = tileLoc-Global.BOARDWIDTH-1
	for _y in range(3):
		for _x in range(3):
			if(bordertile>=0 && (bordertile+1)%Global.BOARDWIDTH != 0 && bordertile<tiles.size()):
				if(bordertile!=tileLoc):
					tiledata = (tiledata << 2) | tiles[bordertile].status(true)
			else:
				if(bordertile!=tileLoc):
					tiledata = (tiledata << 2) | 3
			bordertile += 1
		bordertile += (Global.BOARDWIDTH - 3)
	tiles[tileLoc].setTile(tiledata)
	
func ValidMove(tileLoc,finalMove=false):
	var validMove = tiles[tileLoc].MovementTile()
	if(finalMove && validMove):
		for piece in pieces:
			if piece.boardpos == tileLoc:
				validMove = false
				break
	return validMove
	
func attackHit(tileLocs,attacker):
	var stopSearch = false
	for piece in pieces:
		if !piece.alive:
			continue
		for loc in tileLocs:
			if loc == piece.boardpos:
				if attacker.classType != Global.Class.Ghost:
					if piece.facing * -1 != attacker.facing:
						print("assassinated")
						piece.Killed()
						stopSearch = true
						break 
				else:
					piece.killed()

func NextSelect(current,direction):
	var selection = current
	for piece in pieces:
		if !piece.alive:
			continue
		if piece.get_parent().name == current.get_parent().name:
			if direction==Global.UP:
				if piece.position.y < current.position.y && (selection==current || piece.position.y >= selection.position.y):
					if piece.position.y == selection.position.y:
						var pieceDist = abs(current.position.x - piece.position.x)
						var selectDist = abs(current.position.x - selection.position.x)
						if pieceDist < selectDist:
							selection = piece
						elif pieceDist == selectDist && piece.position.x > selection.position.x:
							selection = piece
					else:
						selection = piece
			elif direction==Global.DOWN:
				if piece.position.y > current.position.y && (selection==current || piece.position.y <= selection.position.y):
					if piece.position.y == selection.position.y:
						var pieceDist = abs(current.position.x - piece.position.x)
						var selectDist = abs(current.position.x - selection.position.x)
						if pieceDist < selectDist:
							selection = piece
						elif pieceDist == selectDist && piece.position.x < selection.position.x:
							selection = piece
					else:
						selection = piece
			elif direction==Global.LEFT:
				if piece.position.y == current.position.y && piece.position.x < current.position.x && \
				(selection==current || piece.position.x > selection.position.x):
					selection = piece
			elif direction==Global.RIGHT:
				if piece.position.y == current.position.y && piece.position.x > current.position.x && \
				(selection==current || piece.position.x < selection.position.x):
					selection = piece
			else:
				print("Invalid direction sent: ", direction)
	return selection

