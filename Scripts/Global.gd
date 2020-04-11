extends Node

var statEditorEnabled = false
var cameFromGame = false

var daysOfQuarentine = 5
var infected = false
var infectedBy = ""
var infectedByYou = []

var startInfected = false
var initialStats = []
var statsMax = []

func NewGame():
	infected = startInfected
	if infected:
		infectedBy = "?"
	else:
		infectedBy = ""
	infectedByYou = []
