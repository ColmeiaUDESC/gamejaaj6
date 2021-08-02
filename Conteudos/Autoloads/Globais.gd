extends Node

const RAZAO_PUREZA_PURO = 0.2
const RAZAO_PUREZA_IMPURO = 0.2
const STATUS_PUREZA_IMPURO = -1
const STATUS_PUREZA_NEUTRO = 0
const STATUS_PUREZA_PURO = 1
const PUREZA_MAXIMA = 40
const PUREZA_MINIMA = 0

var container_projeteis: Node


func porcentagem_puro(pureza: float) -> float:
	return (pureza - PUREZA_MINIMA) / float(PUREZA_MAXIMA - PUREZA_MINIMA)

# -1 impuro; 0 puro; 1 puro
func status_pureza(pureza: float) -> int:
	var porcentagem_pureza := porcentagem_puro(pureza)
	if porcentagem_pureza <= RAZAO_PUREZA_IMPURO:
		return STATUS_PUREZA_IMPURO
	elif porcentagem_pureza >= 1 - RAZAO_PUREZA_PURO:
		return STATUS_PUREZA_PURO

	return STATUS_PUREZA_NEUTRO
