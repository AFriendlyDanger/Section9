extends AudioStreamPlayer


var track4 = preload("res://Audio/Ambient_4.ogg")
func _ready():
	pass # Replace with function body.

func switchTrack(track_num):
	var new_track
	match track_num:
		4:
			new_track = track4
	if new_track!=null:
		stream = new_track
		play()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
