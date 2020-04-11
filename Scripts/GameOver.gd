extends CanvasLayer

onready var anim = $AnimationPlayer

func _ready():
	anim.play_backwards("StartGame")
	$Main/Days.text += str(Global.daysOfQuarentine)
	
	if Global.infected:
		$Main/Infected.text += "Si"
		
		if Global.infectedBy == "":
			$Main/InfectedBy.text += "Nadie"
		else:
			$Main/InfectedBy.text += Global.infectedBy
	
		if Global.infectedByYou.size() == 0:
			$Main/InfectedByYou.text += "Nadie"
		else:
			for infected in range(Global.infectedByYou.size()):
				if infected == Global.infectedByYou.size()-1:
					$Main/InfectedByYou.text += " y "
				elif infected != 0:
					$Main/InfectedByYou.text += ", "
				$Main/InfectedByYou.text += Global.infectedByYou[infected]
	else:
		$Main/Infected.text += "No"
		$Main/InfectedBy.text += "Nadie"
		$Main/InfectedByYou.text +=  "Nadie"
		
		if not Global.statEditorEnabled:
			Global.statEditorEnabled = true
			anim.play("StatEditorUnlocked")

func RetryPressed():
	anim.play("StartGame")
	Global.NewGame()
	yield( anim, "animation_finished" )
	get_tree().change_scene("res://Screens/Game.tscn")

func BackPressed():
	anim.play("BackToMenu")
	yield( anim, "animation_finished" )
	get_tree().change_scene("res://Screens/Title.tscn")
