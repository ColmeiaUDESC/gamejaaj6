extends Area2D

export var alcance := 10.0
export var velocidade := 1.0
var direcao := Vector2.RIGHT
var dano := 1.0

func _ready() -> void:
	rotation = direcao.angle()


func _process(delta: float) -> void:
	var deslocamento := direcao * velocidade * delta
	position += direcao * velocidade * delta
	alcance -= deslocamento.length()

	if alcance <= 0:
		queue_free()


func _on_Projetil_body_entered(body: PhysicsBody2D):
	if body.has_method("inflige_dano"):
		body.inflige_dano(dano)
	queue_free()
