extends Node2D
const MAX_MOVES = 30
export var player = 0

const pathTiles = preload("res://Objects/path.tscn")
var selector
var turn = true
onready var mapNode = $"../"
onready var selection = get_child(1)


func _ready():
	
	selector = pathTiles.instance() 
	selector.frame = 5
	selector.z_index = 30
	selector.centered = false
	SetSelection()
	add_child(selector)
	
func _process(_delta):
	if(turn):
		PieceSelect()

func PieceSelect():
	if Input.is_action_just_pressed("ui_accept"):
		selection._activate()
	elif Input.is_action_just_pressed("ui_right"):
		selection = mapNode.NextSelect(selection,Global.RIGHT)
		SetSelection()
	elif Input.is_action_just_pressed("ui_left"):
		selection = mapNode.NextSelect(selection,Global.LEFT)
		SetSelection()
	elif Input.is_action_just_pressed("ui_up"):
		selection = mapNode.NextSelect(selection,Global.UP)
		SetSelection()
	elif Input.is_action_just_pressed("ui_down"):
		selection = mapNode.NextSelect(selection,Global.DOWN)
		SetSelection()

func SetSelection():
	selector.position = selection.position
