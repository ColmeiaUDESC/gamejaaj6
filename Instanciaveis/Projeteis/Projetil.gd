extends Area2D

export var forca_empurrao := 3000.0
export var alcance := 10.0
export var velocidade := 1.0
var atirador: Node2D
var direcao := Vector2.RIGHT
var dano := 1.0

signal acertou_inimigo(inimigo)

func _ready() -> void:
	var deslocamento_sprite := $DeslocamentoSprite
	var sprite := $DeslocamentoSprite/Sprite
	
	var flipar = abs(direcao.angle()) >= PI * .5
	deslocamento_sprite.rotation = direcao.angle() + (PI * .5 if flipar else .0)
	sprite.flip_h = flipar

	sprite.play("default")


func _process(delta: float) -> void:
	var deslocamento := direcao * velocidade * delta
	position += direcao * velocidade * delta
	alcance -= deslocamento.length()

	if alcance <= 0:
		queue_free()


func _ao_colidir(colisor: CollisionObject2D) -> void:
	if "personagem" in colisor:
		var personagem = colisor.personagem
		emit_signal("acertou_inimigo", personagem)
		personagem.inflige_dano(dano, atirador)
		personagem.inflingir_empurrao(global_position.direction_to(personagem.global_position) * forca_empurrao)
	queue_free()
