extends KinematicBody2D

export var velocidade = 250
var movimento = Vector2()
var vida_max = 12.0
var vida_atual = 12.0
var regeneracao = 0.5
var depois_do_ataque = false
onready var tween_transicao := $TweenCamera
onready var player_animacao := $AnimationPlayer

const VELOCIDADE_BASE := 250
var velocidade := VELOCIDADE_BASE
var movimento := Vector2()

func _process(_delta):
	# Everything works like you're used to in a top-down game
	var direcao = Vector2()

	if Input.is_action_pressed("ui_up"):
		direcao += Vector2(0, -1)
		
	elif Input.is_action_pressed("ui_down"):
		direcao += Vector2(0, 1)

	if Input.is_action_pressed("ui_left"):
		direcao += Vector2(-1, 0)
		
	elif Input.is_action_pressed("ui_right"):
		direcao += Vector2(1, 0)

	movimento = direcao.normalized() * velocidade
	movimento = move_and_slide(movimento)
	
	# Debug
	if Input.is_action_just_pressed("ui_select"):
		vida_atual -= 1



func inflinge_dano(dano):
	if !depois_do_ataque:
			vida_atual -= dano
			intangivel() 


func _on_Regen_HP_timeout():
	if (vida_atual + regeneracao) < vida_max:
		vida_atual += regeneracao
	
	elif (vida_atual + regeneracao) >= vida_max:
		vida_atual = vida_max


func intangivel():
	depois_do_ataque = true
	$Intangibilidade.start()

func _on_Intangibilidade_timeout():
	depois_do_ataque = false


func transicionar_camera(nova_pos_global: Vector2) -> void:
	tween_transicao.interpolate_property($Camera2D, "global_position", global_position, nova_pos_global, 0.25, Tween.TRANS_QUAD)
	tween_transicao.start()
	yield(tween_transicao, "tween_completed")
	position = Vector2.ZERO
