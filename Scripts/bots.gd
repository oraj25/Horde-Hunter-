extends Area2D

const BULLET = preload("res://Sceans/botbullet.tscn")

@onready var shootpoint1 = $Pivot/gun/ShootPoint
@onready var shootpoint2 = $Pivot/gun2/ShootPoint

@onready var gun_sprite1 = $Pivot/gun
@onready var gun_sprite2 = $Pivot/gun2
@onready var pivot = $Pivot

var spin_speed = 0.3
var fireDelay = 1.0  
var shoot_cd := false


func _physics_process(delta: float):
	if get_parent().get("dead") == true:
		return
	rotation += spin_speed * delta
	gun_sprite1.global_rotation = 0
	gun_sprite2.global_rotation = 0

func _process(delta):
	if !shoot_cd:
		shoot_cd = true
		shoot_all_guns() # Fire both guns at once
		await get_tree().create_timer(fireDelay).timeout
		shoot_cd = false

func shoot_all_guns():
	create_bullet(shootpoint1, 0)
	create_bullet(shootpoint2, PI)

func create_bullet(spawn_point, extra_rotation):
	var new_bullet = BULLET.instantiate()
	AudioController.pBullet3()
	new_bullet.global_position = spawn_point.global_position
	new_bullet.global_rotation = rotation + extra_rotation
	get_tree().root.add_child(new_bullet)
