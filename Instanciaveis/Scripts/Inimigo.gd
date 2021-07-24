extends KinematicBody2D

const VELOCIDADE = 1000
var jogador = null
var direcao = Vector2.ZERO
var movimento = Vector2.ZERO

func _ready():
	$GerenciadorEstados.iniciar(self)


func _physics_process(delta):
	$GerenciadorEstados.executar(delta)
	movimento = direcao * VELOCIDADE * delta
	movimento = move_and_slide(movimento)


func _on_Visao_body_entered(body):
	if body.name == "Jogador":
		jogador = body
		$GerenciadorEstados.mudar_estado("Seguir")


func _on_Visao_body_exited(body):
	if body == jogador:
		$GerenciadorEstados.mudar_estado("Aguardo")
		jogador = null


func _on_Area_de_ataque_body_entered(body):
	if body == jogador:
		$GerenciadorEstados.mudar_estado("Atacar")


func _on_Area_de_ataque_body_exited(body):
	if body == jogador:
		$GerenciadorEstados.mudar_estado("Seguir")
