extends HSlider

var AudioNode

func _ready():
	min_value = 0.0005
	step = 0.0001
	AudioNode = get_tree().get_root().find_node("Music",true,false)
	if(AudioNode):
		value = pow(10,AudioNode.volume_db/20)
	pass




# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_HSlider_value_changed(value):
	if(!AudioNode):
		AudioNode = get_tree().get_root().find_node("Music",true,false)
	var decibel = log(value)/log(10) *20
	print("value: ", value)
	print("decibel: ", decibel)
	AudioNode.volume_db = decibel
