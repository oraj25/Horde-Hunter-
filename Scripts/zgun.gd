extends Area2D

const BULLET = preload("res://Sceans/zbullet.tscn")

@onready var shootpoint = $pivot/Zgun/ShootPoint
@onready var fire_timer = $Timer

var fireDelay = 1.0
var shoot_cd := false

func _ready():
	if get_parent().name.begins_with("miniBossOne"):
		fire_timer.wait_time = randf_range(1.0, 5.0)
		print("I am a MiniBoss! Shooting slower.")
	else:
		fire_timer.wait_time = fireDelay
	fire_timer.one_shot = true

func _physics_process(delta: float):
	var enemies_in_range = get_overlapping_bodies()
	var target_player = null
	for body in enemies_in_range:
		if body.is_in_group("players"):
			target_player = body
			break
		
	if target_player:
		look_at(target_player.global_position)
		if fire_timer.is_stopped():
			shoot()
			fire_timer.start()

func shoot ():
	var new_bullet = BULLET.instantiate()
	AudioController.ZBullet()
	var main_level_node = get_parent().get_parent()
	main_level_node.add_child(new_bullet)
	new_bullet.global_position = shootpoint.global_position
	new_bullet.global_rotation = shootpoint.global_rotation



func _on_timer_timeout():
	pass # Replace with function body.
