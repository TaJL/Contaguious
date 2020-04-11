extends HBoxContainer

signal pressed(index)

const MINVALUE = 0
const COLOR_NORMAL = "#f8eebf"
const COLOR_LOW = "#a95a3f"

export(Texture) var iconTextureNormal
export(Texture) var iconTextureHover
export(Texture) var iconTexturePressed
export var index = 0

onready var icon = $Icon
onready var label = $Label

var statIsLow = [0,50,80,0,50,0]

func _ready():
	if iconTextureNormal != null:
		icon.texture_normal = iconTextureNormal
		icon.texture_disabled = iconTextureNormal
	if iconTextureHover != null:
		icon.texture_hover = iconTextureHover
	if iconTexturePressed != null:
		icon.texture_pressed = iconTexturePressed

func NewValueLabel(value):
	if index == 5:
		label.text = "$" + str(value)
	else:
		label.text = str(value) + "%"
	
	if value <= statIsLow[index]:
		label.modulate = Color(COLOR_LOW)
	else:
		label.modulate = Color(COLOR_NORMAL)

func ButtonPressed():
	emit_signal("pressed", index)
