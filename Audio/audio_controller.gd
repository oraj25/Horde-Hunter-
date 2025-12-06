extends Node2D

@export var mute: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not mute:
		main()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func Click():
	if not mute:
		
		$click.play()

func main():
	if not mute:
		$gameBg.stop()
		$main.play()

func start():
	if not mute:
		$bossMusic.stop()
		if not $start.playing:
			$start.play()
		

func gameBg():
	if not mute:
		$main.stop()
		$gameBg.play()
func Zidol():
	if not mute:
		$Zidol.play()

func Zboss():
	if not mute:
		$Zboss.play()

func Zdamage():
	if not mute:
		$Zdamage.play()

func Zbossdead():
	if not mute:
		$Zbossdead.play()

func Zdead():
	if not mute:
		$Zdead.play()
func powerup():
	if not mute:
		$powerup.play()

func powerdown():
	if not mute:
		$powerdown.play()
func healthup():
	if not mute:
		$healthup.play()
func Pdamage():
	if not mute:
		$Pdamage.play()

func Pdead():
	if not mute:
		$Pdead.play()

func coin():
	if not mute:
		$coin.play()

func newwepon():
	if not mute:
		$newwepon.play()
func Sward():
	if not mute:
		$Sward.play()

func pBullet():
	if not mute:
		$pBullet.play()

func pBullet2():
	if not mute:
		$pBullet2.play()

func pBullet3():
	if not mute:
		$pBullet3.play()

func ZBullet():
	if not mute:
		$ZBullet.play()

func minion():
	if not mute:
		$minion.play()

func Zbossbigdead():
	if not mute:
		$Zbossbigdead.play()

func loot():
	if not mute:
		$loot.play()
func save():
	if not mute:
		var sounds = [
			$save, $save2, $save3, $save4, $save5, 
			$save6, $save7, $save8, $save9, $save10
		]
		var random_sound = sounds.pick_random()
		random_sound.play()
func levelup():
	if not mute:
		$levelup.play()

func wallpickup():
	if not mute:
		$wallpickup.play()

func wallPlace():
	if not mute:
		$wallPlace.play()
func bossMusic():
	if not mute:
		$start.stop()
		$bossMusic.play()
