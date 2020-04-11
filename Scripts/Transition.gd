extends ColorRect

signal finished
signal allBlack

onready var animPlayer = $AnimationPlayer
onready var timer = $Timer

func _ready():
	randomize()

func PlayTransition(transitionNumber = null, type = "complete"):
	visible = true
	if transitionNumber != null:
		if transitionNumber < 10:
			transitionNumber = "0" + str(transitionNumber)
		else:
			transitionNumber = str(transitionNumber)
		material.set_shader_param("mask",load("res://Visuales/Transitions/Transition" + transitionNumber + ".png"))
	else:
		material.set_shader_param("mask",GetRandomTransition())
	match type:
		"complete":
			animPlayer.play("FadeIn")
			yield( animPlayer, "animation_finished" )
			emit_signal("allBlack")
			timer.start()
			yield( timer, "timeout" )
			animPlayer.play_backwards("FadeIn")
			yield( animPlayer, "animation_finished" )
		"fadeIn":
			animPlayer.play("FadeIn")
			yield( animPlayer, "animation_finished" )
			emit_signal("allBlack")
			timer.start()
			yield( timer, "timeout" )
		"fadeOut":
			animPlayer.play_backwards("FadeIn")
			yield( animPlayer, "animation_finished" )
	emit_signal("finished")
	visible = false

func GetRandomTransition():
	var randomNumber = 1 + randi() % 6
	if randomNumber < 10:
		randomNumber = "0" + str(randomNumber)
	else:
		randomNumber = str(randomNumber)
	return load("res://Visuales/Transitions/Transition" + randomNumber + ".png")