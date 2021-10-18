extends Area2D

export var forca_empurrao := 3000.0
export var alcance := 10.0
export var velocidade := 1.0
var atirador: Node2D
var direcao := Vector2.RIGHT
var dano := 1.0

signal acertou_inimigo(inimigo)

func _ready() -> void:
	rotation = direcao.angle()
	if abs(rotation) < PI * .5:
		$AnimatedSprite.flip_v = false
		$AnimatedSprite.rotation = PI * 0.25
	else:
		$AnimatedSprite.flip_v = true
		$AnimatedSprite.rotation = -PI * 0.25

	$AnimatedSprite.play("default")


func _process(delta: float) -> void:
	var deslocamento := direcao * velocidade * delta
	position += direcao * velocidade * delta
	alcance -= deslocamento.length()

	if alcance <= 0:
		queue_free()


func _on_Projetil_body_entered(body: PhysicsBody2D):
	if body.has_method("inflige_dano"):
		emit_signal("acertou_inimigo", body)
		body.inflige_dano(dano, atirador)
		if body.has_method("inflingir_empurrao"):
			body.inflingir_empurrao(global_position.direction_to(body.global_position) * forca_empurrao)
	queue_free()
