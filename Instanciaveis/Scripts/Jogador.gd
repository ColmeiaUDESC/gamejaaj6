extends KinematicBody2D

const VELOCIDADE = 250
var movimento = Vector2()

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

	movimento = direcao.normalized() * VELOCIDADE
	movimento = move_and_slide(movimento)
