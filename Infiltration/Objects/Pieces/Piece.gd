extends Node2D

const pathTiles = preload("res://Objects/path.tscn")
const MAX_MOVES = 10
var total_moves = 0
var action_taken = false
export var team = 0
var alive = true
var facing = Global.DOWN
var boardpos = 0
var charSprite
var directionTile
var moving = false
var classType = Global.Class.Demoman
onready var mapNode = $"../../"
onready var playerNode = $"../"
#var directionTile

func _ready():
	charSprite = get_child(0)
	boardpos=position.x/16 + position.y/16*Global.BOARDWIDTH
	directionTile = pathTiles.instance()
	directionTile.frame = 2
	point()
	add_child(directionTile)
	set_process(false)
	SpriteLayer()

func _activate(status = true):
	playerNode.selector.visible = !status
	playerNode.set_process(!status)
	set_process(status)
	if !status:
		playerNode.SetSelection()
	
func _process(_delta):
	if(!moving):
		inputCheck()

func inputCheck():
	if Input.is_action_just_pressed("attack"):
		Attack()
	elif Input.is_action_just_pressed("interact"):
		Interact()
	elif Input.is_action_just_pressed("ui_cancel"):
		_activate(false)
	elif Input.is_action_just_pressed("ui_right"):
		if not facing == Global.RIGHT:
			facing = Global.RIGHT
		else:
			move(boardpos+Global.RIGHT,Vector2.RIGHT*16)
		point()
	elif Input.is_action_just_pressed("ui_left"):
		if not facing == Global.LEFT:
			facing = Global.LEFT
		else:
			move(boardpos+Global.LEFT,Vector2.LEFT*16)
		point()
	elif Input.is_action_just_pressed("ui_up"):
		if not facing == Global.UP:
			facing = Global.UP
		else:
			move(boardpos+Global.UP,Vector2.UP*16)
		point()
	elif Input.is_action_just_pressed("ui_down"):
		if not facing == Global.DOWN:
			facing = Global.DOWN
		else:
			move(boardpos+Global.DOWN,Vector2.DOWN*16)
		point()

func move(destination,movement):
	if(mapNode.ValidMove(destination,MAX_MOVES-total_moves==1)&& total_moves < MAX_MOVES):
		position += movement
		boardpos = destination
		SpriteLayer()
		total_moves += 1

func point():
	if facing==Global.UP:
		directionTile.position = Vector2(8,-8)
		directionTile.rotation_degrees = 0
	elif facing==Global.DOWN:
		directionTile.position = Vector2(8,24)
		directionTile.rotation_degrees = 180
	elif facing==Global.LEFT:
		directionTile.position = Vector2(-8,8)
		directionTile.rotation_degrees = -90
	elif facing==Global.RIGHT:
		directionTile.position = Vector2(24,8)
		directionTile.rotation_degrees = 90

func SpriteLayer():
	charSprite.z_index = int(boardpos/Global.BOARDWIDTH)+3

func Attack():
	#Virtual function
	pass

func Killed():
	alive = false
	visible = false

func Interact():
	#Virtual function
	pass
