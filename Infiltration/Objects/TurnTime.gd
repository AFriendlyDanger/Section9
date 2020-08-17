extends Panel


onready var TimerNode = $Timer
onready var TimerText = $TimerText
var player
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func SetTimer(current_player):
	player = current_player
	TimerNode.start(180)
	
func _process(_delta):
	if(!TimerNode.is_stopped()):
		var time = int(TimerNode.time_left)
		TimerText.text = str(time/60) + ":" + ("" if time%60>9 else "0") + str(time%60)
		#print(TimerNode.time_left)


func _on_Timer_timeout():
	player.TimeUp()
