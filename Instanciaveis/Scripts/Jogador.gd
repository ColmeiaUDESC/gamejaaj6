extends KinematicBody2D

export var velocidade = 250
var movimento = Vector2()
var vida_max = 12.0
var vida_atual = 12.0
var regeneracao = 0.5

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


func _on_Regen_HP_timeout():
	if (vida_atual + regeneracao) < vida_max:
		vida_atual += regeneracao
	
	elif (vida_atual + regeneracao) >= vida_max:
		vida_atual = vida_max
