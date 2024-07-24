class_name Player extends CharacterBody3D
#Int/Float Values
var dash_count = 1
var wall_jump = 4
var weapon_select = 0
var ms = 0
var rewind_duraction = 999
var sensitive = 0.005
var speed = 10
var jump_strength = 5
var gravity = 9.8
#Bool Values True/False
var sliding = false
var big_jump = false
var dash = false
var abilit_select = false
var fordward = false
@export var rewind = false
var rewindvalue = {"position":[],"velocity":[],"rotation_x":[],"rotation_y":[]}
#Objects
var direction = Vector3.ZERO
@onready var rewind_effect = $HUD/Rewind_effect
@onready var fordward_effect = $HUD/Fordward_effect
@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var default_body = $Default_colision
#Timers
@onready var big_jump_moment = $Timers/Big_jump_moment
@onready var big_jump_strenght = $Timers/Big_jump_strenght
#Others
const player_freq = 3
const player_amp = 0.1
var t_player = 0.0
const base_fov = 100.0
const fov_change = 2

#Event funcs
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
		

func _unhandled_input(event):
	if event is InputEventMouseMotion and !rewind:
		head.rotate_y(-event.relative.x * sensitive)
		camera.rotate_x(-event.relative.y * sensitive)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-45), deg_to_rad(45))
		default_body.rotate_y(-event.relative.x * sensitive)
		rewindvalue["rotation_y"].append(event.relative.y * sensitive)
		rewindvalue["rotation_x"].append(event.relative.x * sensitive)

func _input(event):
	#ability selection
	if Input.is_action_just_pressed("Q"):
		if !abilit_select:
			abilit_select = true
		elif abilit_select:
			abilit_select = false
	
	#abilitys event
	if Input.is_action_pressed("M2"):
		if abilit_select and rewindvalue["rotation_x"] != null:
			rewind = true
			fordward = false
		if !abilit_select:
			rewind = false
			fordward = true
	elif Input.is_action_just_released("M2"):
		rewind = false;
		fordward = false
		music_controller.music_pitch(1.00)

#Process funcs
func _process(delta):
	#rewind process
	if rewind :
		rewind_process(delta)
	elif !rewind:
		if 99 * Engine.get_frames_per_second() == rewindvalue["position"].size():
			for key in rewindvalue.keys():
				rewindvalue[key].pop_front()
		rewindvalue["position"].append(global_position)
		rewindvalue["velocity"].append(velocity)
		default_body.call_deferred("set_disabled",false)
		rewind_effect.call_deferred("set_visible",false)
		$HUD/Crossair/Rewind_crossair_icon.call_deferred("set_visible",false)
	
	#fordward process
	if fordward:
		fordward_process(delta)
	elif !fordward:
		$Timers/Stap_timer.set_wait_time(0.35)
		$HUD/Crossair/Fordward_crossair_icon.call_deferred("set_visible",false)
		fordward_effect.call_deferred("set_visible",false)
		speed = 10
		jump_strength = 5

func _physics_process(delta):
	
	#gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# wall_sliding and wall_jumP
	if Input.is_action_pressed("Space") and is_on_wall_only():
		velocity.y=- 2
		velocity.x = 0
		velocity.z = 0
		sliding = true
		big_jump_strenght.stop()
	else:
		sliding = false
	if Input.is_action_just_released("Space") and is_on_wall_only() and wall_jump > 0:
		velocity = clamp(get_wall_normal(),Vector3(-1,0,-1),Vector3(1,0,1)) * jump_strength * 2
		velocity.y += jump_strength + 1.5
		sliding = false
		wall_jump -=1
	
	#fast_fall and big_jump_moment
	if Input.is_action_just_pressed("Ctrl") and not is_on_floor() and !sliding:
		big_jump_strenght.start()
		ms = 0 
		big_jump = true
		velocity.y -= 40
	elif big_jump and is_on_floor():
		camera.fov = 97.5
		velocity.x = 0
		velocity.z = 0
		big_jump_moment.start()
		big_jump=false
		$SFX/big_fall_sound.play()
		camera.transform.origin = _headplayer(t_player)
	
	#jump and big_jump
	if Input.is_action_pressed("Space") and is_on_floor(): 
		if big_jump_moment.time_left> 0:
			velocity.y = clamp(jump_strength + ms, jump_strength+1, 20) 
			$SFX/big_jump_sound.play()
		else:
			velocity.y = clamp(jump_strength, jump_strength, 10)
			$SFX/jump_sound.play()
	
	#dash
	if Input.is_action_just_pressed("Shift") and dash_count > 0 and not is_on_floor() and not is_on_wall() and (direction.x!=0 or direction.z!=0):
		$SFX/dash_sound.play()
		dash_count -=1
		dash = true
		velocity.x = lerp(velocity.x, direction.x, delta * 10) * 2
		velocity.z = lerp(velocity.z, direction.z, delta * 10) * 2
		if big_jump_moment.time_left> 0:
			velocity.x = lerp(velocity.x, direction.x, delta * 0)  * (ms/3 +2)
			velocity.z = lerp(velocity.z, direction.z, delta * 0)  * (ms/3 +2)
			$SFX/big_dash_sound.play()
	elif dash and is_on_floor() or dash and is_on_wall():
		dash_count = 1
		fordward = false
		dash = false
		music_controller.music_pitch(1.00)
	
	# basic moviment and direction
	var input_dir = Input.get_vector("A", "D", "W", "S")
	direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		var stap = 0
		if (direction.z !=0 or direction.x !=0) and $Timers/Stap_timer.time_left <= 0:
			$SFX/walking_sound.play()
			$Timers/Stap_timer.start()
			stap+=1
		wall_jump = 4
		big_jump_strenght.stop()
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 10)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 10)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 4)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 4)
	
	# head player
	t_player += delta * velocity.length() * float(is_on_floor()) 
	camera.transform.origin = _headplayer(t_player)
	# fov
	var velocity_clamped = clamp(velocity.length(), 0.5, speed )
	var target_fov = base_fov + fov_change * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	move_and_slide()

#Other funcs
func rewind_process(_delta: float):
	var pos = rewindvalue["position"].pop_back()
	var vel = rewindvalue["velocity"].pop_back()
	var rot_x = rewindvalue["rotation_x"].pop_back()
	var rot_y = rewindvalue["rotation_y"].pop_back()
	default_body.call_deferred("set_disabled",true)
	if rewindvalue["position"].is_empty():
		rewind = false
		return
	if rot_x != null or rot_y != null: 
		head.rotate_y(rot_x)
		camera.rotate_x(rot_y)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-45), deg_to_rad(45))
	global_position = pos
	velocity = vel
	rewind_effect.call_deferred("set_visible",true)
	$HUD/Crossair/Rewind_crossair_icon.call_deferred("set_visible",true)
	velocity.y = 0
	ms = 0
	big_jump_strenght.stop()
	music_controller.music_pitch(0.95)


func fordward_process(delta):
	music_controller.music_pitch(1.05)
	$HUD/Crossair/Fordward_crossair_icon.call_deferred("set_visible",true)
	fordward_effect.call_deferred("set_visible",true)
	jump_strength = 6
	speed = 14
	$Timers/Stap_timer.set_wait_time(0.2)

func _on_big_jump_strenght_timeout():
	ms +=1.5


func _headplayer(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * player_freq) * player_amp
	pos.x = sin(time * player_freq/2) * player_amp/2
	return pos#camera values
	move_and_slide()
