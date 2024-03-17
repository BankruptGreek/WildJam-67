extends CharacterBody2D
class_name Parasite

@export_group("Components")
@onready var feet:CollisionShape2D = $FeetCollision
@onready var spri:Sprite2D = $Sprite
@onready var spriDebug = $SpriteDebug
@onready var anim = $AnimationPlayer
@export var camera:Camera2D
@export var pointLight:PointLight2D

@onready var agro_range:Area2D = $AgroRange
@onready var attach_range:Area2D = $AttachRange
@onready var hit_box:Area2D = $HitBox


@export_group("Parasite")
@export var orbitSize:int = 16
@export var orbitOffset:Vector2=Vector2.ZERO
var attaching:bool=false
var controlledBody:CharacterBody2D
@onready var health:HealthBar = $HealthComponent



@export_group("Movement")
@export var lookingDirection:float=0
@export var maxSpeed:float=700
@export var dec:float=1500
@export var maxMousePos:float=60
@export var minMousePos:float=15
@export var minMouseChange:float=5

#States
@onready var ground = $States/Ground
const PARASITE_GROUND = preload("res://Parasite/parasiteGround.png")
@onready var attached = $States/Attached
const PARASITE_ATTACHED = preload("res://Parasite/parasiteAttached.png")
var currentState:Node

func _ready():
	motion_mode=CharacterBody2D.MOTION_MODE_FLOATING
	currentState=ground
	currentState.start()

func _process(delta):
	if(isDead):
		return
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
	body=body.get_parent().get_parent().get_parent()
	if(body==null): return
	#print("body detected = " + str(body))
	if(!attaching || body==ignoreBody || !body.has_method("attached")):
		return
	
	if(body.attached(self)):
		controlledBody=body
		currentState.stop()
		currentState=attached
		attached.start()
		#print(str(temp))
	
	
	pass # Replace with function body.
	
@onready var clearIgnoreBodyTimer:Timer = $clearIgnoreBody
func clearIgnoreBody():
	ignoreBody=null
	for body in attach_range.get_overlapping_areas():
		attach_to(body)
	pass # Replace with function body.


func getHit(source:Node2D,pushForce:float,damage:int):
	if(currentState==attached):
		controlledBody.detached()
		currentState.stop()
		currentState=ground
		currentState.start()
	velocity+=pushForce*source.global_position.direction_to(global_position)
		




func _on_agro_range_area_entered(area):
	var body:Node2D = area.get_parent().get_parent().get_parent()
	if(body == null):
		return
	if(body.has_method("trigger")):
		body.trigger(self)
	
	pass # Replace with function body.
	
var isDead:bool=false

func die():
	isDead=true
	modulate=Color(1,1,1,0)
	var tween:Tween
	tween = get_tree().create_tween()
	tween.tween_property(pointLight,"color",Color(1,1,1,0.2),1.5)
	get_parent().restart()
	print("GameOver")
	pass
	
