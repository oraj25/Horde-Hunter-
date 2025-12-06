extends Area2D

const BULLET = preload("res://Sceans/bullet.tscn")

@onready var shootpoint = $Pivot/gun/ShootPoint

var fireDelay = 1.50
var shoot_cd := false

func _physics_process(delta: float):
	if get_parent().get("dead") == true:
		return
	look_at(get_global_mouse_position())

func _process(delta):
	if Input.is_action_pressed("shoot"):
		if !shoot_cd:
			shoot_cd = true
			shoot()
			await get_tree().create_timer(fireDelay).timeout
			shoot_cd = false
func shoot ():
	var new_bullet = BULLET.instantiate()
	AudioController.pBullet()
	new_bullet.global_position = shootpoint.global_position
	new_bullet.global_rotation = shootpoint.global_rotation
	shootpoint.add_child(new_bullet)

func _on_timer_timeout():
	pass
	#shoot()
