extends TextureRect

onready var screen = $Screen
onready var dayNumber = $DayNumber

func SetScreen(tagName):
	print(tagName)
	var screenImage = File.new()
	if screenImage.file_exists("res://Visuales/Screens/" + tagName + ".png") :
		screen.visible = true
		dayNumber.visible = false
		screen.texture = load("res://Visuales/Screens/" + tagName + ".png")
	
func ShowDay(number):
	screen.visible = false
	dayNumber.visible = true
	dayNumber.text = "Día N°\n" + str(number)