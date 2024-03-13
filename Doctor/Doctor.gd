extends CharacterBody2D
class_name Doctor

@export_group("Components")
@onready var feet:CollisionShape2D = $Feet
@onready var hands:Node2D = $Hands
@onready var rotation_point = $RotationPoint

@onready var spri:Sprite2D = $Sprite
const DOCTOR_BOTTOM_LEFT = preload("res://Doctor/DoctorBottomLeft.tres")
const DOCTOR_TOP_RIGHT = preload("res://Doctor/DoctorTopRight.tres")
@onready var spriDebug = $SpriteDebug
@onready var anim = $AnimationPlayer
@onready var hit_box:Area2D = $HitBox

@export_group("Doctor")
@export var weapon:CharacterBody2D=null


@export_group("Movement")
@export var lookingDirection:float=0
@export var maxSpeed:float=700
@export var dec:float=1500
@export var maxMousePos:float=60
@export var minMousePos:float=15
@export var minMouseChange:float=5

#States
@onready var idle = $States/Idle
@onready var chase = $States/Chase
@onready var controlled = $States/Controlled
var currentState:Node

func _ready():
	currentState=idle

func _process(delta):
	currentState.update(delta)
	updateSprite()
	
	move_and_slide()
	
func updateSprite():
	if(lookingDirection>0.):
		spri.texture=DOCTOR_BOTTOM_LEFT
		if(lookingDirection>1.5): spri.flip_h=true
		else: spri.flip_h=false
	else:
		spri.texture=DOCTOR_TOP_RIGHT
		if(lookingDirection<-1.5): spri.flip_h=true
		else: spri.flip_h=false
	
func attached()->bool:
	currentState=controlled
	hit_box.set_collision_layer_value(3,false)
	hit_box.set_collision_layer_value(2,true)
	
	if(weapon!=null):
		weapon.setForPlayer()
	
	return true
	
func detached():
	currentState=idle
	hit_box.set_collision_layer_value(3,true)
	hit_box.set_collision_layer_value(2,false)
	if(weapon!=null):
		weapon.setForEnemy()
	pass
