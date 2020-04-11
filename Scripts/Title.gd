extends CanvasLayer

const COLOR_ENABLED = "#f8eebf"
var TEXTURE_CHECKED = load("res://Visuales/Check.png")
var TEXTURE_UNCHECKED = load("res://Visuales/Uncheck.png")
const defaultStats = [100,100,100,100,100,20000]

export var statsMax = [100,100,100,100,100,100000]

onready var thanksMenu = $Thanks
onready var mainMenu = $Main
onready var tutorial1Menu = $Tutorial1
onready var tutorial2Menu = $Tutorial2
onready var gameConfigMenu = $GameConfig
onready var transition = $Transition
onready var anim = $AnimationPlayer
onready var labels = $Tutorial2/Labels
onready var bgMusic = $BGMusic
onready var infectedChecker = $GameConfig/Config/Infected/Checker
onready var gameModes = $GameConfig/GameModes

var stats = []
var statsGameMode = [[20,100,60,100,60,1000],
					[30,100,100,100,100,50000],
					[100,100,100,100,100,0]]

func _ready():
	# sacar luego
	HabilitateStartButtom()
	#
	$Thanks/Options/Exit.disabled = OS.get_name() == "HTML5"
	
	if not Global.cameFromGame:
		Global.initialStats = defaultStats.duplicate()
	else:
		stats = Global.initialStats.duplicate()
	
	if Global.startInfected:
		infectedChecker.texture_normal = TEXTURE_CHECKED
	else:
		infectedChecker.texture_normal = TEXTURE_UNCHECKED
	
	stats = Global.initialStats.duplicate()
	ActualizeStats()
	
	yield(get_tree().create_timer(0.5), "timeout")
	transition.PlayTransition(1, "fadeOut")

func Transitionate(fromMenu, toMenu):
	transition.PlayTransition(2,"complete")
	yield (transition, "allBlack")
	fromMenu.visible = false
	toMenu.visible = true
	yield (transition, "finished")

func StartNewGame():
	transition.PlayTransition(5,"complete")
	yield (transition, "allBlack")
	
	Global.initialStats = stats.duplicate()
	Global.statsMax = statsMax.duplicate()
	Global.NewGame()
	get_tree().change_scene("res://Screens/Game.tscn")

# THANKS

func ThanksBackPressed():
	Transitionate(thanksMenu, mainMenu)

func ThanksExitPressed():
	get_tree().quit()

#   MAIN

func MainStartPressed():
	Transitionate(mainMenu, gameConfigMenu)

func MainContextPressed():
	Transitionate(mainMenu, tutorial1Menu)

func MainExitPressed():
	Transitionate(mainMenu, thanksMenu)

func HabilitateStartButtom():
	if not get_node("Main/Start").disabled:
		return
	get_node("Main/Start").disabled = false
	get_node("Main/Start/Label").modulate = Color("#f8eebf")

#   TUTORIAL 1

func Tutorial1VolverPressed():
	SetVisibleText("Instruction")
	Transitionate(tutorial1Menu, mainMenu)

func Tutorial1SiguientePressed():
	SetVisibleText("Instruction")
	Transitionate(tutorial1Menu, tutorial2Menu)

#   TUTORIAL 2

func Tutorial2AnteriorPressed():
	HabilitateStartButtom()
	Transitionate(tutorial2Menu, tutorial1Menu)

func Tutorial2VolverPressed():
	HabilitateStartButtom()
	Transitionate(tutorial2Menu, mainMenu)

func SetVisibleText(label_name):
	for label in labels.get_children():
		if label.name == label_name:
			label.visible = true
		else:
			label.visible = false

func HealthPressed():
	SetVisibleText("Health")

func HappinessPressed():
	SetVisibleText("Happiness")

func SocialPressed():
	SetVisibleText("Social")

func CleanessPressed():
	SetVisibleText("Cleaness")

func FoodPressed():
	SetVisibleText("Food")

func MoneyPressed():
	SetVisibleText("Money")

# Game Config

func GameConfigBackPressed():
	Transitionate(gameConfigMenu, mainMenu)

func GameConfigDefaultPressed():
	Global.infected = false
	infectedChecker.texture_normal = TEXTURE_UNCHECKED
	
	stats = defaultStats.duplicate()
	GameModepressed(-1)

func GameConfigStartPressed():
	StartNewGame()

func InfectedCheckerPressed():
	Global.startInfected = !Global.startInfected
	if Global.startInfected:
		infectedChecker.texture_normal = TEXTURE_CHECKED
		stats[0] = 0
		statsMax[0] = 0
		get_node("GameConfig/Config/Stat0").ChangeValue(stats[0])
	else:
		infectedChecker.texture_normal = TEXTURE_UNCHECKED
		stats[0] = 5
		statsMax[0] = 100
		get_node("GameConfig/Config/Stat0").ChangeValue(stats[0])
	GameModepressed(-1)

func StatValueChange(value, number, emitter):
	stats[number] += value
	if number == 0:
		if not Global.startInfected:
			stats[0] = clamp(stats[0], 5, statsMax[0])
		else:
			stats[0] = 0
	else:
		stats[number] = clamp(stats[number], 0, statsMax[number])
	
	emitter.ChangeValue(stats[number])
	GameModepressed(-1)

func ActualizeStats():
	for i in range(stats.size()):
		get_node("GameConfig/Config/Stat" + str(i)).ChangeValue(stats[i])


func GameModepressed(gameModeNumber):
	for i in range(gameModes.get_children().size()):
		if i == gameModeNumber:
			gameModes.get_node("Mode" + str(i)).disabled = true
			stats = statsGameMode[i].duplicate()
		else:
			gameModes.get_node("Mode" + str(i)).disabled = false
	ActualizeStats()