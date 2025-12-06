extends Area2D

const BULLET = preload("res://Sceans/smallbullet.tscn")

@onready var shootpoint = $Pivot/gun/ShootPoint

var fireDelay = 2
var shoot_cd := false


func _physics_process(delta: float):
	if get_parent().get("dead") == true:
		return
	var enemies_in_range = get_overlapping_bodies()
	if enemies_in_range.size() > 0:
		var target_enemy = enemies_in_range.front()
		look_at(target_enemy.global_position)
		if !shoot_cd:
			shoot_cd = true
			shoot()
			await get_tree().create_timer(fireDelay).timeout
			shoot_cd = false

func shoot ():
	var new_bullet = BULLET.instantiate()
	AudioController.pBullet2()
	new_bullet.global_position = shootpoint.global_position
	new_bullet.global_rotation = shootpoint.global_rotation
	shootpoint.add_child(new_bullet)

func _on_timer_timeout():
	pass
	#shoot()
