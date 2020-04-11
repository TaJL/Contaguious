extends HBoxContainer

func ConnectSignals(target, clicMethod, mouseEnterMethod="", mouseExitedMethod=""):
	if get_children().size() == 1:
		get_node("Button").connect("pressed",target,clicMethod)
	elif get_children().size() == 2:
		for i in range(2):
			var value = str(i + 1)
			get_node("Option"+value).connect("pressed",target,clicMethod,[i+1])
			get_node("Option"+value).connect("mouse_entered",target,mouseEnterMethod,[i+1])
			get_node("Option"+value).connect("mouse_exited",target,mouseExitedMethod)
