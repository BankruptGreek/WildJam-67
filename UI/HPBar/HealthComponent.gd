extends Control
class_name HealthBar

@onready var parent = $".."

@export var maxHP:float=15
var startOffset=2
var step=4
@export var HP:int=0
@export var threshold:int=3
@onready var hpBar = $HPbar
@onready var timer = $Timer

var healTemp:int=0

func _ready():
	heal(maxHP)

func takeDamage(damage:int):
	if(damage==0):
		return
	
	HP-=damage
	hpBar.set_value_no_signal(2+HP*step)
	
	if(HP<=0):
		parent.die()
		pass
	



func heal(amount:int):
		healTemp=amount
		HP+=1
		healTemp-=1
		hpBar.set_value_no_signal(2+HP*step)
		timer.start()


func healTimer():
	while(healTemp>0):
			HP+=1
			healTemp-=1
			hpBar.set_value_no_signal(2+HP*step)
			timer.start()
