extends Control

class_name HealthBar

@export var parent:Node2D

@export var maxHP:float=15
var startOffset=2
var step=4
@export var HP:int=0
@export var startInvisible:bool=false
@export var threshold:int=3
@onready var hpBar = $HPbar
@onready var timer = $Timer

var healTemp:int=0

func _ready():
	if(parent.isDead):
		HP=0
		position.y-=10
		modulate.a=0.
		hpBar.set_value_no_signal(2)
		return
	elif(startInvisible):
		HP=maxHP
		position.y-=10
		hpBar.set_value_no_signal(2+HP+step)
		modulate.a=0.
	else:
		heal(maxHP)

func takeDamage(damage:int):
	if(damage==0):
		return
	if(HP==maxHP):
		unfade()
	HP-=damage
	hpBar.set_value_no_signal(2+HP*step)
	
	if(HP<=0):
		fade()
		HP=0
		parent.die()
	



func heal(amount:int):
		if(HP==0):
			unfade()
		healTemp=amount
		HP+=1
		healTemp-=1
		hpBar.set_value_no_signal(2+HP*step)
		timer.start()


func healTimer():
	if(healTemp>0 && !parent.isDead):
			HP+=1
			healTemp-=1
			hpBar.set_value_no_signal(2+HP*step)
			timer.start()
			if(HP==maxHP):
				fade()
				
	else:
		healTemp=0
		
func fade():
	var tween:Tween
	tween = get_tree().create_tween()
	tween.tween_property(self,"modulate",Color(1,1,1,0),0.5)
	tween = get_tree().create_tween()
	tween.tween_property(self,"position",Vector2(position.x,position.y-10),0.3).set_delay(0.2)
	
func unfade():
	var tween:Tween
	tween = get_tree().create_tween()
	tween.tween_property(self,"modulate",Color(1,1,1,1),0.5)
	tween = get_tree().create_tween()
	tween.tween_property(self,"position",Vector2(position.x,position.y+10),0.3).set_delay(0.2)
