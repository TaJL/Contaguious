extends CanvasLayer

export var costEventInFood = 5

const PATHEVENTS = "res://Data/Events.json"
const PATHNAMES = "res://Data/Names.json"
const PATHTAGS = "res://Data/Tags.json"

const STATECHOOSINGEVENT = 1
const STATEREADINGEVENT = 2
const STATECHOOSINGRESULT = 3
const STATEREADINGRESULT = 4
const StatsNumToStr = {0:"Health", 1:"Happiness", 2:"Cleaness", 
						3:"Food", 4:"Social", 5:"Money"}
onready var desktop = $Desktop
onready var mainContainer = $MainContainer
onready var topBar = $MainContainer/TopBar
onready var statsMenu = $MainContainer/StatsMenu
onready var information = $MainContainer/Information
onready var optionsButtoms = $MainContainer/Buttons/Options
onready var continueButtoms = $MainContainer/Buttons/Continue
onready var transition = $Transition
onready var bgMusic = $BGMusic
onready var animPlayer = $AnimPlayer

var concequenses = []
var playerState = STATECHOOSINGEVENT

# Days
var days = 0
var daysOfQuarentine = 0
var eventsThisDay = 0
var eventsPerDay = 3
var todayEvents = []
# Event Creation
var totalEvents = 1
var numberOfRepetitions = {}
var maxEventRepetitions = 6
var numberOfNames = 15
# Event
var eventText = ""
var optionsText = ["",""]
var statsResults =[[0,0,0,0,0,0],
					[0,0,0,0,0,0]]
var resultsText = ["",""]
var resultsPopulation = [0,0]
var personsInvolvedList = []
var personsInvolvedText = ""
#Stats
var healthyPopulation = 100
var stats = [100,40,80,100,35,0]
var statsMax = [100,100,100,100,2000,1000000]

func _ready():
	randomize()
	
	daysOfQuarentine = Global.daysOfQuarentine
	ChangePopulation(0)
	stats = Global.initialStats.duplicate()
	statsMax = Global.statsMax.duplicate()
	SetStats(stats)
	
	optionsButtoms.ConnectSignals(self, "OptionChosen", "OptionCheck", "OptionHide")
	continueButtoms.ConnectSignals(self, "ContinuePressed")
	
	playerState = STATECHOOSINGEVENT
	StartState()
	
	transition.PlayTransition(5,"fadeOut")
	yield (transition, "finished")

func PickRandomEvent(index):
	var json = File.new()
	json.open(PATHEVENTS, File.READ)
	var listOfEvents = parse_json(json.get_as_text())
	json.close()
	var eventNumber = GetEventNumber(index, listOfEvents)
	var event = listOfEvents[eventNumber]
	listOfEvents = {}
	
	GetNamesForThisEvent(event["numberPersonsInvolved"])
	
	eventText = FormatingText(event["eventText"])
	
	var optionsVariables
	
	if IsDesperateTriggered(event["desperateTrigger"]):
		optionsVariables =[event["optionsText"][1],
							event["optionsText"][2]]
	else:
		optionsVariables = [event["optionsText"][0],
							event["optionsText"][1]]
	
	if rand_range(0,1) < 0.5:
		optionsVariables = [optionsVariables[1],optionsVariables[0]]
	
	optionsText =  FormatingText([optionsVariables[0][0],optionsVariables[1][0]])
	resultsText =  FormatingText([optionsVariables[0][1],optionsVariables[1][1]])
	statsResults = [[optionsVariables[0][2],optionsVariables[0][3],
				optionsVariables[0][4],optionsVariables[0][5],
				optionsVariables[0][6],optionsVariables[0][7]],
				[optionsVariables[1][2],optionsVariables[1][3],
				optionsVariables[1][4],optionsVariables[1][5],
				optionsVariables[1][6],optionsVariables[1][7]]]
	resultsPopulation = [optionsVariables[0][8],optionsVariables[1][8]]
	
	desktop.SetScreen(event["tag"][randi() % event["tag"].size()])
	NextState()

func IsDesperateTriggered(desperateTrigger):
	for statNumber in range(stats.size()):
		if stats[statNumber] <= desperateTrigger[statNumber]:
			return true
	
	return false

func GetEventNumber(index, listOfEvents):
	var json = File.new()
	json.open(PATHTAGS, File.READ)
	var listOfTags = parse_json(json.get_as_text())
	json.close()
	var validTags = listOfTags[StatsNumToStr[index]]
	
	var eventNumber
	
	var condition = true
	while condition:
		eventNumber = GenerateRandomEventNumber()
		if not numberOfRepetitions.has(eventNumber):
			numberOfRepetitions[eventNumber] = 0
		
		condition = (numberOfRepetitions[eventNumber] >= maxEventRepetitions
					or todayEvents.has(eventNumber))
		
		if not condition:
			var tagCondition = true
			var thisEventTags = listOfEvents[eventNumber]["tag"]
			for tag in validTags:
				if thisEventTags.has(tag):
					tagCondition = false
					break
			condition = condition or tagCondition
	todayEvents.append(eventNumber)
	numberOfRepetitions[eventNumber] += 1
	
	$Label.text = "Evento: " + str(eventNumber)
	
	return eventNumber

func GenerateRandomEventNumber():
	var number = str(1 + randi() % totalEvents)
	
	match (number.length()):
		1:
			number = "00" + number
		2:
			number = "0" + number
		3:
			pass

	return number

func GetNamesForThisEvent(number = 0):
	personsInvolvedList = []
	personsInvolvedText = ""
	
	var json = File.new()
	json.open(PATHNAMES, File.READ)
	var listOfNames = parse_json(json.get_as_text())
	json.close()
	
	var name = listOfNames[randi() % numberOfNames]
	
	for i in range(number):
		while personsInvolvedList.has(name):
			name = listOfNames[randi() % numberOfNames]
		
		personsInvolvedList.append(name)
		
		personsInvolvedText += name
		if i < number - 1:
			if i == number - 2:
				personsInvolvedText += " y "
			else:
				personsInvolvedText += ", "

func FormatingText(textToEdit = []):
	var infectedText = ""
	if Global.infected:
		infectedText = "Estas infectado"
	else:
		infectedText = "Estas sano"
	
	var newText = []
	
	if typeof(textToEdit) == TYPE_STRING:
		newText = textToEdit.format({"nombre": personsInvolvedText}, {"infectado" : infectedText})
	elif typeof(textToEdit) == TYPE_ARRAY:
		for i in range(textToEdit.size()):
			newText.append(textToEdit[i].format({"nombre": personsInvolvedText, "infectado" : infectedText}))
	return newText

func StartState():
	match playerState:
		STATECHOOSINGEVENT:
			optionsButtoms.visible = false
			continueButtoms.visible = false
			information.ShowText("Toca un stat para empezar un evento relacionado a este")
		STATEREADINGEVENT:
			ShowEvent()
			ShowContinue()
		STATECHOOSINGRESULT:
			optionsButtoms.visible = true
			continueButtoms.visible = false
		STATEREADINGRESULT:
			ShowContinue()

func NextState():
	match playerState:
		STATECHOOSINGEVENT:
			pass
		STATEREADINGEVENT:
			pass
		STATECHOOSINGRESULT:
			pass
		STATEREADINGRESULT:
			eventsThisDay += 1
			if eventsThisDay == eventsPerDay:
				days += 1
				if days == daysOfQuarentine:
					GameOver()
				else:
					Nextday()
	
	playerState += 1
	if playerState == 5:
		playerState = 1
	StartState()

func GameOver():
	transition.PlayTransition(3, "fadeIn")
	yield( transition, "allBlack" )
	get_tree().change_scene("res://Screens/GameOver.tscn")

# TopBar

func ChangePopulation(deltaValue):
	topBar.ActualizarPoblacion(healthyPopulation + deltaValue)

# Stats

func SetStats(newValues = [0,0,0,0,0,0]):
	for i in range(stats.size()):
		stats[i] = clamp(newValues[i],0,statsMax[i])
	statsMenu.SetStatsText(stats)
	
func ChangeStats(deltaValues = [0,0,0,0,0,0]):
	stats[0] = 1 + floor(stats[0] * (100 - deltaValues[0])/100)
	stats[0] = clamp(stats[0],0,statsMax[0])
	
	stats[3] -= costEventInFood
	
	for i in range(1,stats.size()):
		stats[i] += deltaValues[i]
		stats[i] = clamp(stats[i],0,statsMax[i])
	statsMenu.SetStatsText(stats)
	
	if not Global.infected:
		return
	
	if stats[0] > randi()%statsMax[0]:
		Global.infected = true

func EventChoosen(index):
	if playerState != STATECHOOSINGEVENT:
		return
	
	PickRandomEvent(index)

func CheckInfections():
	for person in personsInvolvedList:
		if Global.infected:
			if randi() % 100 < 20:
				Global.infectedByYou.append(person)
		else:
			if randi() % 101 > stats[0]:
				Global.infected = true
				Global.infectedBy = person

# Information

func ShowEvent():
	information.ShowText(eventText)
	ShowContinue()

# Options

func ShowOptions():
	optionsButtoms.visible = true
	continueButtoms.visible = false

func ShowContinue():
	optionsButtoms.visible = false
	continueButtoms.visible = true

func OptionChosen(number):
	number -= 1
	CheckInfections()
	ChangePopulation(resultsPopulation[number])
	ChangeStats(statsResults[number])
	information.ShowText(resultsText[number])
	
	NextState()

func OptionCheck(number):
	number -= 1
	information.ShowResult(optionsText[number], statsResults[number])

func OptionHide():
	information.ShowText(eventText)

func ContinuePressed():
	NextState()

# NewDayScreen

func Nextday():
	animPlayer.play("ChangeSong")
	eventsThisDay = 0
	todayEvents = []
	transition.PlayTransition(3)
	yield( transition, "allBlack" )
	bgMusic.stream = load("res://Audio/Music/Day0" + str(days+1) + "Music.ogg")
	bgMusic.play()
	desktop.ShowDay(days)

# Music

func BGMusicFinished():
	bgMusic.play()
