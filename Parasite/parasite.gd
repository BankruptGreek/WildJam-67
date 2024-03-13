extends CharacterBody2D
class_name Parasite

@export_group("Components")
@onready var feet:CollisionShape2D = $FeetCollision
@onready var spri:Sprite2D = $Sprite
@onready var spriDebug = $SpriteDebug
@onready var anim = $AnimationPlayer
@export var camera:Camera2D

@onready var agro_range:Area2D = $AgroRange
@onready var attach_range:Area2D = $AttachRange
@onready var hit_box:Area2D = $HitBox


@export_group("Parasite")
@export var orbitSize:int = 16
@export var	orbitOffset:Vector2=Vector2.ZERO
var attaching:bool=false
var controlledBody:CharacterBody2D

@export_group("Movement")
@export var lookingDirection:float=0
@export var maxSpeed:float=700
@export var dec:float=1500
@export var maxMousePos:float=60
@export var minMousePos:float=15
@export var minMouseChange:float=5

#States
@onready var ground = $States/Ground
@onready var attached = $States/Attached
var currentState:Node

func _ready():
	motion_mode=CharacterBody2D.MOTION_MODE_FLOATING
	currentState=ground
	currentState.start()

func _process(delta):
	match currentState:
		ground:
			currentState.update(delta)
			pass
			
		attached:
			currentState.update(delta)
			if(Input.is_action_just_pressed("jump")):
				attached.stop()
				ground.start()
				currentState=ground
			pass
		_:
			print("Parasite Invalid State \"" + str(currentState) + "\"")
	
	
	
	move_and_slide()

var ignoreBody:Node2D=null


func attach_to(body):
	var temp=body
	if(!body.is_class("Area2D")): return
	body=body.get_parent()
	if(body==null): return
	print("body detected = " + str(body))
	if(!attaching || body==ignoreBody || !body.has_method("attached")):
		if(!attaching):
			print("Not Attaching atm")
		elif(body==ignoreBody):
			print("Ignoring this one atm")
		elif(!body.has_method("attached")):
			print("Not suitable for me")
		return
	
	if(body.attached()):
		currentState=attached
		attached.start(body)
		print(str(temp))
	
	
	pass # Replace with function body.
	
@onready var clearIgnoreBodyTimer:Timer = $clearIgnoreBody
func clearIgnoreBody():
	ignoreBody=null
	for body in attach_range.get_overlapping_areas():
		attach_to(body)
	pass # Replace with function body.




