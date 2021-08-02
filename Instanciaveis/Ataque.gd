extends Area2D

export(bool) var restringir_ataque := true
var atacando := false

signal atacou

func atacar(dir: Vector2) -> void:
	if not atacando:
		emit_signal("atacou")
		atacando = true
		rotation = round(dir.angle() / (PI / 2)) * PI / 2 if restringir_ataque else dir.angle()
		$Sprite.visible = true
		$Sprite.play("default")


func _on_Sprite_animation_finished():
	atacando = false
	$Sprite.stop()
	$Sprite.hide()
	$Sprite.flip_v = not $Sprite.flip_v
