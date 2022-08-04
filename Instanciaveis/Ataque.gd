extends Area2D

export(bool) var restringir_ataque := true
export(float) var deslocamento_ataque := 10.0
export(float) var altura_ataque:= 10.0
export(float) var multiplicador_velocidade := 1.0
var atacando := false
var angulo_ataque := 0.0

onready var colisao = $CollisionShape2D
onready var sprite_sombra := $CollisionShape2D/SombraSprite
onready var sprite := $Sprite

signal atacou
signal ataque_finalizou

func _ready():
	$CollisionShape2D/SombraSprite.speed_scale = multiplicador_velocidade
	$Sprite.speed_scale = multiplicador_velocidade


func atacar(dir: Vector2) -> void:
	if not atacando:
		atacando = true
		emit_signal("atacou")
		angulo_ataque = round(dir.angle() / (PI * .5)) * PI * .5 if restringir_ataque else dir.angle()
		colisao.rotation = angulo_ataque
		colisao.position = Vector2(cos(angulo_ataque), sin(angulo_ataque)) * deslocamento_ataque
		sprite.position = colisao.position + Vector2.UP * altura_ataque
		sprite.rotation = colisao.rotation
		
		sprite_sombra.visible = true
		sprite_sombra.play("default")
		sprite.visible = true
		sprite.play("default")


func _parar_sprite(s: AnimatedSprite):
	s.stop()
	s.hide()
	s.frame = 0
	s.flip_v = not s.flip_v

func _on_Sprite_animation_finished():
	atacando = false
	emit_signal("ataque_finalizou")
	_parar_sprite(sprite)
	_parar_sprite(sprite_sombra)
