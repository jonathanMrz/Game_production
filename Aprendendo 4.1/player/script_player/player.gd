class_name Player extends CharacterBody3D
#Int/Float Values
var respawning = false
var animation_step = false
var damege_count = 0
var disable_slide = false
var volume = 1
var floor_sliding = false
var running = false
var preserved_speed = Vector3.ZERO
var dash_count = 1
var wall_jump = 4
var weapon_select = 0
var ms = 0
var rewind_duraction = 99
var sensitive = 0.005
var speed = 10
var jump_strength = 5
var gravity = 14
#Bool Values True/False
var sound_floor_sliding = true
var sound_wall_sliding = true
var crouching = false
var crouch = false
var sliding = false
var big_jump = false
var dash = false
var abilit_select = 0
var fordward = false
@export var rewind = false
var rewindvalue = {"position":[],"velocity":[],"rotation_x":[],"rotation_y":[]}
#Objects
var direction = Vector3.ZERO
@onready var rewind_effect = $HUD/Effects/Rewind_effect
@onready var fordward_effect = $HUD/Effects/Fordward_effect
@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var default_body = $Default_colision
@onready var head_check = $Head_check
@onready var lifebar = $HUD/Life/Lifebar
@onready var skeleton = $HUD/Life/Skeleton
@onready var numvaluelifebar = $HUD/Life/Label
#Timers
@onready var big_jump_moment = $Timers/Big_jump_moment
@onready var big_jump_strenght = $Timers/Big_jump_strenght
#Others
const player_freq = 3
const player_amp = 0.1
var t_player = 0.0
const base_fov = 100.0
const fov_change = 2
#ability
@onready var fordward_bar = $HUD/Control/Fordward_bar 
var regen_ability1 = false
var wait1 = true
@onready var rewind_bar = $HUD/Control/Rewind_bar
var regen_ability2 = false
var wait2 = true

#Event funcs
func _ready():
	global.player = self
	damege_count = lifebar.value
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$HUD/AnimationPlayer.play("fadin")

func _unhandled_input(event):
	if event is InputEventMouseMotion and !rewind and Engine.time_scale !=0:
		head.rotate_y(-event.relative.x * sensitive)
		camera.rotate_x(-event.relative.y * sensitive)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-45), deg_to_rad(45))
		default_body.rotate_y(-event.relative.x * sensitive)
		rewindvalue["rotation_y"].append(event.relative.y/2 * sensitive)
		rewindvalue["rotation_x"].append(event.relative.x * sensitive)

func _input(event):
	#ability selection
	if Input.is_action_just_pressed("Q"):
		if abilit_select == 0:
			abilit_select = 1
		elif abilit_select == 1:
			abilit_select =0
	
	#abilitys event
	if Input.is_action_pressed("M2") and !respawning:
		if abilit_select == 1 and rewindvalue["rotation_x"] != null and rewind_bar.value != 0:
			rewind = true
			fordward = false
		if abilit_select == 0 and fordward_bar.value != 0:
			rewind = false
			fordward = true
	else:
		if !respawning:
			rewind = false;
		fordward = false
		music_controller.music_pitch(1.00)

#Process funcs
func _process(delta):
	if abilit_select == 0:
		$HUD/Control/Rewind_bar/underrewind.visible = false
		$HUD/Control/Fordward_bar/underford.visible = true
	elif abilit_select == 1:
		$HUD/Control/Rewind_bar/underrewind.visible = true
		$HUD/Control/Fordward_bar/underford.visible = false
	
	numvaluelifebar.text = "%s"%(lifebar.value)
	if lifebar.value > lifebar.max_value*0.75:
		if damege_count > lifebar.value:
			skeleton.play("fulllife_damege")
			if skeleton.frame==4:
				damege_count = lifebar.value
		else:
			skeleton.play("fulllife_default")
	elif lifebar.value <= lifebar.max_value*0.75 and lifebar.value >= lifebar.max_value*0.45:
		if damege_count > lifebar.value:
			skeleton.play("midlife_damege")
			if skeleton.frame==4:
				damege_count = lifebar.value
		else:
			skeleton.play("midlife_default")
	elif lifebar.value < lifebar.max_value*0.45 and lifebar.value >0:
		if damege_count > lifebar.value:
			skeleton.play("lowlife_damege")
			if skeleton.frame==4:
				damege_count = lifebar.value
		else:
			skeleton.play("lowlife_default")
	
	
	if fordward_bar.value == 0:
		fordward = false
	if regen_ability1:
		await get_tree().create_timer(0.1).timeout
		fordward_bar.value += 0.5
		if fordward_bar.value >= fordward_bar.max_value:
			regen_ability1 = false
			$SFX/alert2.set_pitch_scale(1)
			$SFX/alert2.play()
	if rewind_bar.value == 0 and !respawning:
		rewind = false
	if regen_ability2:
		await get_tree().create_timer(0.1).timeout
		rewind_bar.value += 0.5
		if rewind_bar.value >= rewind_bar.max_value:
			regen_ability2 = false
			$SFX/alert2.set_pitch_scale(0.7)
			$SFX/alert2.play()
	
	#rewind process
	if rewind :
		rewind_process(delta)
	elif !rewind:
		if rewind_bar.value > 0:
			if rewind_bar.value < rewind_bar.max_value:
				regen_ability2 = true
			elif rewind_bar.value >= rewind_bar.max_value: 
				regen_ability2 = false
		elif rewind_bar.value == 0 and wait2:
			$SFX/alert.set_pitch_scale(0.7)
			$SFX/alert.play()
			wait2 = false
			$Timers/Wait_Timer_rewind.start()
		elif $Timers/Wait_Timer_rewind.time_left <= 0:
			wait2 = true
			regen_ability2 = true
		
		if 999 * Engine.get_frames_per_second() == rewindvalue["position"].size():
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
		if fordward_bar.value != 0:
			if fordward_bar.value <fordward_bar.max_value:
				regen_ability1 = true
			elif fordward_bar.value >= fordward_bar.max_value:
				regen_ability1 = false
		elif fordward_bar.value == 0 and wait1:
			wait1 = false
			$SFX/alert.set_pitch_scale(1)
			$SFX/alert.play()
			$Timers/Wait_Timer_fordward.start()
		elif $Timers/Wait_Timer_fordward.time_left <= 0:
			wait1 = true
			regen_ability1 = true
		$Timers/Stap_timer.set_wait_time(0.35)
		$HUD/Crossair/Fordward_crossair_icon.call_deferred("set_visible",false)
		fordward_effect.call_deferred("set_visible",false)
		speed = 10
		jump_strength = 6

func _physics_process(delta):
	if lifebar.value <=0:
		die()
	preserved_speed.x = velocity.x
	preserved_speed.z = velocity.z
	if velocity.y < 0:
		disable_slide = false
	#gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# wall_sliding and wall_jumP
	if Input.is_action_pressed("Space") and is_on_wall_only() and !disable_slide:
		big_jump = false
		velocity.y=- 2
		velocity.x = 0
		velocity.z = 0
		sliding = true
		big_jump_strenght.stop()
		volume = lerp(volume, volume * 1, delta * 0.5) +0.1
		$SFX/wall_slide.set_volume_db(clamp(volume-5,-3,3))
		if sound_wall_sliding:
			volume = 1
			$SFX/wall_slide.play()
			sound_wall_sliding = false
	elif Input.is_action_just_released("Space") and is_on_wall_only() and wall_jump > 0 and !disable_slide:
		velocity = clamp(get_wall_normal(),Vector3(-1,0,-1),Vector3(1,0,1)) * jump_strength * 2
		velocity.y += jump_strength + 1.5
		sliding = false
		wall_jump -=1
		$SFX/jump_sound.set_pitch_scale(2.5)
		$SFX/jump_sound.play()
	else:
		sliding = false
		sound_wall_sliding = true
		$SFX/wall_slide.stop()
	
	#crouch
	if Input.is_action_just_pressed("Ctrl") and Input.is_action_pressed("W") and is_on_floor() or head_check.is_colliding() and is_on_floor():
			velocity.y = -9
			default_body.scale.y = 0.5
			head.position.y = 0.4
			camera.position.z = 0.2
			camera.position.y = 0.2
			floor_sliding = true
			crouch = true
			crouching = false
			if head_check.is_colliding() and !Input.is_action_pressed("Ctrl"):
				crouching = true
			if sound_floor_sliding and floor_sliding:
				$SFX/floor_slide.play()
				sound_floor_sliding = false
	elif crouch and (Input.is_action_just_released("Ctrl") or Input.is_action_just_pressed("Space")) or crouch and !is_on_floor():
			crouching = true
	if crouching and !head_check.is_colliding():
		sound_floor_sliding=true
		$SFX/floor_slide.stop()
		crouch = false
		default_body.scale.y = 1
		head.position.y = 1.4
		volume = 1
		crouching = false
	#fast_fall and big_jump_moment
	if Input.is_action_just_pressed("Ctrl") and not is_on_floor() and !sliding:
		big_jump_strenght.start()
		ms = 0 
		big_jump = true
		velocity.y = -40
	elif big_jump and is_on_floor():
		camera.fov = 97.5
		big_jump_moment.start()
		big_jump=false
		$SFX/big_fall_sound.play()
		camera.transform.origin = _headplayer(t_player)
	
	#jump and big_jump
	if is_on_floor():
		$Timers/Jump_air.start()
	if Input.is_action_just_pressed("Space") and $Timers/Jump_air.time_left and !head_check.is_colliding() and !rewind: 
		if big_jump_moment.time_left> 0:
			velocity.y = clamp(jump_strength + ms, jump_strength+1, 20)
			$SFX/jump_sound.set_pitch_scale(1.8)
			$SFX/big_jump_sound.play()
		else:
			velocity.y = clamp(jump_strength, jump_strength, 10)
			$SFX/jump_sound.play()
		$Timers/Jump_air.stop()
		disable_slide = true
	
	#dash
	if Input.is_action_just_pressed("Shift") and dash_count > 0 and not is_on_floor() and not is_on_wall() and (direction.x!=0 or direction.z!=0) and !rewind:
		if fordward:
			fordward_bar.value -= 50
		$SFX/dash_sound.play()
		dash_count -=1
		dash = true
		velocity.x = lerp(velocity.x, direction.x, delta * 10) * 2
		velocity.z = lerp(velocity.z, direction.z, delta * 10) * 2
		if big_jump_moment.time_left> 0:
			velocity.x = lerp(velocity.x, direction.x, delta * 0)  * (ms/3 +2)
			velocity.z = lerp(velocity.z, direction.z, delta * 0)  * (ms/3 +2)
			$SFX/big_dash_sound.play()
		velocity.y = 3
	elif dash and is_on_floor() or dash and is_on_wall():
		dash_count = 1
		dash = false
		music_controller.music_pitch(1.00)
	
	#running
	if Input.is_action_pressed("Shift") and is_on_floor():
		speed = speed * 1.25
		if !fordward:
			$Timers/Stap_timer.set_wait_time(0.25)
		elif fordward:
			$Timers/Stap_timer.set_wait_time(0.15)
	
	# basic moviment and direction and crouch operation
	var input_dir = Input.get_vector("A", "D", "W", "S")
	direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor() and !rewind:
		var stap = 0
		if !crouch and (direction.z !=0 or direction.x !=0) and $Timers/Stap_timer.time_left <= 0:
			$SFX/walking_sound.play()
			$Timers/Stap_timer.start()
			stap+=1
		wall_jump = 4
		big_jump_strenght.stop()
		if direction and !crouch:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		elif crouch:
			if !head_check.is_colliding():
				preserved_speed.x = lerp(preserved_speed.x, direction.x * 0, delta * 0.5)
				preserved_speed.z = lerp(preserved_speed.z, direction.z * 0, delta * 0.5)
			elif head_check.is_colliding():
				preserved_speed.x = lerp(preserved_speed.x, direction.x * 0, delta * -0.5)
				preserved_speed.z = lerp(preserved_speed.z, direction.z * 0, delta * -0.5)
			velocity.x = preserved_speed.x
			velocity.z = preserved_speed.z
			$SFX/floor_slide.set_volume_db(volume+5)
			$SFX/floor_slide.set_pitch_scale((volume/7)+1)
			volume = lerp(volume, volume * -1, delta * 0.5) -0.1
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 10)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 10)
	elif !is_on_floor():
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 4)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 4)
	
	# head player
	if !crouch:
		t_player += delta * velocity.length() * float(is_on_floor()) 
		camera.transform.origin = _headplayer(t_player)
	
	# fov
	var velocity_clamped = clamp(velocity.length(), 0.5, speed )
	var target_fov = base_fov + fov_change * velocity_clamped
	camera.fov = 100
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	move_and_slide()

#Other funcs
func rewind_process(_delta: float):
	if respawning and (is_on_floor() or sliding and wall_jump >0):
		respawning = false
		rewind = false
	regen_ability2 = false
	big_jump = false
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
	velocity = vel/2
	rewind_effect.call_deferred("set_visible",true)
	$HUD/Crossair/Rewind_crossair_icon.call_deferred("set_visible",true)
	velocity.y = 0
	ms = 0
	big_jump_strenght.stop()
	music_controller.music_pitch(0.98)
	if !respawning:
		await get_tree().create_timer(0.2).timeout
		rewind_bar.value -= 5

func fordward_process(delta):
	regen_ability1 = false
	music_controller.music_pitch(1.02)
	$HUD/Crossair/Fordward_crossair_icon.call_deferred("set_visible",true)
	fordward_effect.call_deferred("set_visible",true)
	jump_strength = 7
	speed = 15
	$Timers/Stap_timer.set_wait_time(0.2)
	await get_tree().create_timer(0.1).timeout
	fordward_bar.value -= 3.5

func _headplayer(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = (sin(time * player_freq)*0.7) * player_amp
	pos.x = sin(time * player_freq/2) * player_amp/2
	return pos#camera values
	move_and_slide()

func _on_big_jump_strenght_timeout():
	ms +=1.5

#Player world reaction
func _on_floorless_body_entered(body):
	if body is Player and !respawning:
		fordward = false
		respawning = true
		rewind = true
		lifebar.value -= 10
	pass # Replace with function body.

func die():
	get_tree().quit()

