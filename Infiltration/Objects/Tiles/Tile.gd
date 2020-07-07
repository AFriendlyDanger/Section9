extends Sprite
#tool

export var wall = true
export var intact = true
export var console = false
export var mainframe = false
export var door = false
var open = false
const UPLOAD_TIME = 3
var upload_turns = 0
var uploading = false

const TILE_MASK = -4
const WALL_MASK = -2

func status(wallcheck = false):
	if(!wallcheck || !console):
		return ((int(wall) << 0) | (int(intact) << 1))
	else:
		return ((int(intact) << 1))

func MovementTile():
	return !(wall && !open && intact)
	
func OpenDoor():
	if door && intact:
		if open:
			open = false
			if(frame == 13):
				frame = 12
			else:
				frame = 20
		else:
			open = true
			if frame == 12:
				frame = 13
			else:
				frame = 21
		return true
	else:
		return false
		
func StartUpload(uploader,team):
	var changed = false
	if team == 0:
		if !uploading:
			if uploader == Global.Class.Hacker:
				upload_turns=UPLOAD_TIME
			elif uploader == Global.Class.Ghost:
				upload_turns=1
			else:
				upload_turns = 0
			uploading = true
			changed = true
			print("Upload Started")
	else:
		if uploading:
			uploading = false
			changed = true
			print("Upload cancled")
	return changed

func UploadOver():
	var over = false
	upload_turns +=1
	print("Upload tick: ", upload_turns)
	if upload_turns >= UPLOAD_TIME:
		over = true
	return over
		

func setTile(data):
	#print("Data ", data)
	if(wall):
		if(!intact):
			#change to broken wall sprite
			#spawn in relative broken wall sprites
			pass
		else:
			SetWalls(data)
	else:
		#Bit order: left top topleft
		match CheckData(TILE_MASK, data, 3):
			0:
				self.frame = 0
			1:#001
				self.frame = 6
			2:#010
				self.frame = 1
			3:#011
				self.frame = 2
			4,5:#100,101
				self.frame = 4
			6,7:#110,111
				self.frame = 5
			_:
				print("Invalid result ", Expression)
				
func CheckData(MASK, data, tileAmount):
	var results = 0
	
	for _i in range(tileAmount):
		#print("Masked data ", GROUND_MASK | data)
		if(MASK | data) == (MASK | ((1 << 0) | (1 << 1))):
			results = (results << 1) | (1 << 0)
			#print ("hit")
		else:
			results = (results << 1)
			#print ("miss")
		data = data >> 2
	return results

func SetWalls(data):
	#Bit order:  dright down dleft cright cleft uright up uleft
	match CheckData(WALL_MASK, data, 8):
		0,1,4,5,32,33,36,37,128,129,132,133,160,161,164,165:
			#solitary
			self.frame = 10
		2,3,6,7,34,35,38,39,130,131,134,135,162,163,166,167:
			#up only
			self.frame = 25
		8,9,12,13,40,41,44,45,136,137,140,141,168,169,172,173:
			#left only
			self.frame = 19
		10,14,42,138,142,170:
			#left and up
			self.frame = 36
		11,15,43,46,47,139,143,171,174,175:
			#left and up (thick)
			self.frame = 15
		16,17,20,21,48,49,52,53,144,145,148,149,176,177,180,181:
			#right only
			self.frame = 16
		18,19,50,51,146,147,178,179:
			#right and up
			self.frame = 34
		22,23,54,55,150,151,182,183:
			#right and up (thick)
			self.frame = 14
		24,25,26,27,28,29,30,31,56,57,58,59,60,61,62,63,152,153,154,155,156,\
		157,158,159,184,185,186,187,188,189,190,191:
			#right and left/up
			self.frame = 18
		64,65,68,69,96,97,100,101,192,193,196,197,224,225,228,229:
			#down only
			self.frame = 1
		66,67,70,71,98,99,102,103,194,195,198,199,226,227,230,231:
			#down and up
			self.frame = 9
		72,73,76,77,74,78,75,79,110,200,201,\
		202,203,204,205,206,207,238:
			#down and left/up
			self.frame = 28
		104,105,108,109,232,233,236,237:
			#down and left (thick)
			self.frame = 7
		80,81,84,85,112,113,116,117,118,119,82,83,114,115,86,87,210,211,\
		242,243:
			#down and right/up
			self.frame = 26
		208,209,212,213,240,241,244,245:
			#down and right (thick)
			self.frame = 6
		88,89,90,91,92,93,94,95:
			#down left and right/up
			self.frame = 27
		106,107,111,234,235,239:
			#down left and up (thick)
			self.frame = 5
		214,215,246,247:
			#down right and up (thick)
			self.frame = 2
		120,121,122,123,124,125,126,127:
			#down left and right/up(left thick)
			self.frame = 29
		216,217,218,219,220,221,222,223:
			#down left and right/up(right thick)
			self.frame = 30
		248,249,250,251,252,253,254,255:
			#down left and right/up(box)
			self.frame = 3
