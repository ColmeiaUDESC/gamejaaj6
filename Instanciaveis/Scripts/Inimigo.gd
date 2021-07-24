extends KinematicBody2D

var random = RandomNumberGenerator.new()
enum {
	AGUARDO,
	ATAQUE,
	SEGUIR
}

const VELOCIDADE = 20
var jogador = null
onready var state = AGUARDO

var timer = 0
var timer_limit = 1000
var movimento = Vector2.ZERO

func _physics_process(delta):		
	var movimento = Vector2.ZERO
	if state == SEGUIR:
		movimento = position.direction_to(jogador.position) * VELOCIDADE
		
	move_and_slide(movimento)

func _on_Visao_body_entered(body):
	if body.name == "Jogador": 
		jogador = body
		state = SEGUIR
		
func _on_Visao_body_exited(_body):
	state = AGUARDO

func _on_Area_de_ataque_body_entered(body):
	if body.name == "Jogador": 
		jogador = body
		state = ATAQUE
		
func _on_Area_de_ataque_body_exited(_body):
	state = SEGUIR
	



