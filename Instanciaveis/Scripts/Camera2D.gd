extends Camera2D

# https://kidscancode.org/godot_recipes/2d/screen_shake/

export(float) var estabilizacao: float
export(Vector2) var deslocamento_maximo: Vector2 = Vector2.ZERO
export(float) var rolamento_maximo: float = 0.1

var trauma := 0.0
var expoente_trauma := 2.0

func adicionar_trauma(quantidade: float) -> void:
	trauma = min(1.0, max(trauma, quantidade))


func _process(delta: float) -> void:
	if trauma > 0:
		trauma = max(0, trauma - estabilizacao * delta)
		_balancar()


func _balancar() -> void:
	var qnt := pow(trauma, expoente_trauma)
	rotation = rolamento_maximo * qnt * rand_range(-1, 1)
	offset.x = deslocamento_maximo.x * qnt * rand_range(-1, 1)
	offset.y = deslocamento_maximo.y * qnt * rand_range(-1, 1)
