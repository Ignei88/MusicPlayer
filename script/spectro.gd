extends Node2D

@onready var spec = AudioServer.get_bus_effect_instance(0,0)

var listSongRoute=[]
var listSongName=[]

var def = 20

var total_w = 300
var total_h = 500

var min_frec = 20
var max_frec = 1000

var MIN_DB = 60

var songCar = 0

var histogram = []

var minute: float=0.0
var hour=0 

func _ready():
	dir_contents("res://music/")#Se cargan las canciones .pm3 en la ruta escogida
	for i in  range(def):#inicializa el histograma
		histogram.append(0)

@warning_ignore("unused_parameter")
func _process(delta):
	var freq = min_frec
	@warning_ignore("integer_division")
	var interval = (max_frec -min_frec) / def
	for i in range(def):
		var mag = spec.get_magnitude_for_frequency_range(freq, freq+interval)
		mag = linear_to_db(mag.length())
		histogram[i] = mag
		freq += interval
		queue_redraw()

func secTranform(time:int)->String:#Transformaciones para segundos y minutos
	var sec = time % 60
	@warning_ignore("integer_division", "shadowed_variable")
	var minute = (time / 60) % 60
	if sec >= 60:
		@warning_ignore("integer_division")
		minute += sec / 60
		sec %= 60
	return str(int(minute)).pad_zeros(2) + ":" + str(sec).pad_zeros(2)

func _draw():
	var sec_inSound = $AudioStreamPlayer.get_playback_position()
	$LblTime.text = secTranform(int(sec_inSound))
	if $AudioStreamPlayer.playing== true: $HSlider.value = sec_inSound
	var draw_pos = Vector2(0,0)
	@warning_ignore("integer_division")
	var w_interval = total_w / def
	if $AudioStreamPlayer.stream_paused == false:
		draw_line(Vector2(0, -total_h), Vector2(0, -total_h), Color.CRIMSON, 12.0,true)
		for i in range(def):
			if i> 4 and i<=14:
				draw_line(draw_pos, draw_pos+ Vector2(0, histogram[i]), Color.AQUA,12.0,true)
				draw_pos.x += w_interval
			elif  i>14:
				draw_line(draw_pos, draw_pos+ Vector2(0, histogram[i]), Color.DARK_BLUE,12.0,true)
				draw_pos.x += w_interval
			else :
				draw_line(draw_pos, draw_pos+ Vector2(0, histogram[i]), Color.DEEP_PINK,12.0,true)
				draw_pos.x += w_interval
	else:
		pass

func preloadSong(i):#Carga las canciones al programa
	var song
	var songSeconds
	if i <= listSongRoute.size()-1:
		var songPath = listSongRoute[i]
		$LblName.text = listSongName[i]
		song = load(songPath)
		songSeconds = song.get_length()
		$HSlider.max_value = int(songSeconds)
	return song


func _on_button_pressed():
	$AudioStreamPlayer.play()

func _on_btn_pause_pressed():
	if $AudioStreamPlayer.stream_paused == false:
		$AudioStreamPlayer.stream_paused = true
		$BtnPause.text = ">"
	else :
		$AudioStreamPlayer.stream_paused = false
		$BtnPause.text = "||"


func nextSong():
	if songCar <= listSongRoute.size():
		songCar += 1 
		if songCar> listSongRoute.size()-1: songCar = listSongRoute.size()-1
		$AudioStreamPlayer.stream = preloadSong(songCar)
		$AudioStreamPlayer.play()
		for i in  range(def):
			histogram.append(0)

func _on_btn_next_pressed():
	nextSong()

func dir_contents(path):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				print("Found directory: " + file_name.get_base_dir())
			else:
				print("Found file: " + file_name)
				var ext = file_name.get_extension()
				if str(ext) == "mp3": 
					listSongRoute.append("res://music/"+file_name)
					listSongName.append(file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")

func anterior():
	if songCar >= 0:
		songCar += -1
		if songCar<0: songCar =0
		$AudioStreamPlayer.stream = preloadSong(songCar)
		$AudioStreamPlayer.play()

func _on_btn_ret_pressed():
	anterior()
