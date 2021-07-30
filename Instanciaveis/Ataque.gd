extends Area2D

var atacando := false

func atacar(dir: Vector2) -> void:
	if not atacando:
		atacando = true
		rotation = round(dir.angle() / (PI / 2)) * PI / 2
		$Sprite.visible = true
		$Sprite.play("default")


func _on_Sprite_animation_finished():
	atacando = false
	$Sprite.stop()
	$Sprite.hide()
	$Sprite.flip_v = not $Sprite.flip_v
