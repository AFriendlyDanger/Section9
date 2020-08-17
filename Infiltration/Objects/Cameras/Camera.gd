extends CollisionShape2D

#const scan = preload("res://Objects/Scan.tscn")
const scan2 = preload("res://Objects/Scan2.tscn")
const scan2_sprite = preload("res://Sprites/scan2.png")
var turn_hacked=-10
func _ready():
	#var scanInstance = scan.instance()
	#self.add_child_below_node(self,scanInstance,true)
	#var scanNode = get_node("Scan")
	#scanNode.region_rect =  Rect2(position,shape.extents*2)
	#scanNode.z_index = 1
	self.add_child(scan2.instance(),true)
	var scanNode = get_node("Scan2")
	scanNode.region_rect =  Rect2(position,shape.extents*2)
	scanNode.z_index = 0
	#scanNode.material.set_shader_param("VectorUniform",Vector2(0,0.2))
	#scanNode.material.set_shader_param("TextureUniform",scan2_sprite)
	#scanNode.frame = 1
	
func ValidHack(turn):
	var valid = turn_hacked<=turn-2
	if valid:
		turn_hacked = turn
	return valid
		
		
