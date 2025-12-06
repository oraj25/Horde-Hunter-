extends Area2D

const BULLET = preload("res://Sceans/zbullet.tscn")

@onready var shoot_point = $Pivot/gun/ShootPoint
@onready var fire_timer = $Timer

@export var spread_angle : float = 15.0

var shoot_cd := false

func _ready():
	reset_timer()

func _physics_process(delta: float):
	var enemies_in_range = get_overlapping_bodies()
	var target_player = null
	for body in enemies_in_range:
		if body.name == "Player" or body.is_in_group("player") or body.is_in_group("players"):
			target_player = body
			break
		
	if target_player:
		look_at(target_player.global_position)

func shoot ():
	
	for i in range(3):
		var new_bullet = BULLET.instantiate()
		get_tree().root.add_child(new_bullet)
		new_bullet.global_position = shoot_point.global_position
		AudioController.ZBullet()
		# i = 0 -> Multiplier is -1 (Left)
		# i = 1 -> Multiplier is 0 (Center)
		# i = 2 -> Multiplier is 1 (Right)
		var angle_multiplier = i - 1
		var offset = deg_to_rad(spread_angle * angle_multiplier)
		new_bullet.global_rotation = shoot_point.global_rotation + offset

func _on_timer_timeout():
	shoot()
	reset_timer()
	shoot ()
func reset_timer():
	fire_timer.wait_time = randf_range(1.0, 3.0) 
	fire_timer.start()


func _on_spawner_timeout() -> void:
	pass # Replace with function body.
