extends CharacterBody2D
class_name Doctor

@export_group("Components")
@onready var feet:CollisionShape2D = $Feet
@onready var health:HealthBar = $HealthComponent

@onready var hands:Node2D = $Hands
@onready var rotation_point = $RotationPoint
@onready var stun_timer:Timer = $StunTimer

@onready var spri:Sprite2D = $Sprite
const DOCTOR_BOTTOM_LEFT = preload("res://Doctor/DoctorBottomLeft.tres")
const DOCTOR_TOP_RIGHT = preload("res://Doctor/DoctorTopRight.tres")
const DOCTOR_RIP = preload("res://Doctor/DoctorRIP.png")
@onready var spriDebug = $SpriteDebug
@onready var anim = $AnimationPlayer
@onready var hit_box:Area2D = $HitBox

@export_group("Doctor")
@export var weapon:Weapon=null
@export var target:Node2D
@export var isInfected:bool=false
@export var isDead:bool=false


@export_group("Movement")
@export var lookingDirection:float=0
@export var maxSpeed:float=140
@export var dec:float=1500
@export var maxMousePos:float=60
@export var minMousePos:float=15
@export var minMouseChange:float=5
@onready var ai:AI = $AI

#States
@onready var idle = $States/Idle
@onready var chase = $States/Chase
@onready var controlled = $States/Controlled
@onready var not_so_dead = $States/NotSoDead

var currentState:Node

func _ready():
	currentState=chase
	currentState.start()

func _process(delta):
	currentState.update(delta)
	if(!isDead):
		updateSprite()
	
	if(weapon!=null):
		weapon.update(delta)
		
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
	
func attached(parasite:Parasite)->bool:
	if(isDead&&isInfected):
		return false
		
	
	if(health.HP<=health.threshold || isInfected):
		currentState.stop()
		currentState=controlled
		currentState.start()
		hit_box.set_collision_layer_value(3,false)
		hit_box.set_collision_layer_value(2,true)
		
		if(weapon!=null):
			weapon.setForPlayer()
	
		return true
	else:
		parasite.velocity=parasite.velocity.normalized().rotated(deg_to_rad(180))*parasite.maxSpeed/2
		return false
	
func detached():
	currentState.stop()
	if(isInfected):
		currentState=idle
	else:
		currentState=chase
	currentState.start()
	hit_box.set_collision_layer_value(3,true)
	hit_box.set_collision_layer_value(2,false)
	if(weapon!=null):
		weapon.setForEnemy()
	pass
	
func equip(weaponToEquip:Weapon)->bool:
	if(weapon==null):
		print("Equiping..")
		weapon=weaponToEquip
		return true
	else:
		return false
	
func getHit(dir:Vector2,pushForce:float,damage:int):
	velocity+=dir*pushForce
	stunned(damage/4)
	health.takeDamage(damage)
	pass
	
	
var stateBeforeStun
func stunned(duration):
	stun_timer.wait_time=duration
	stateBeforeStun=currentState
	currentState=idle
	stun_timer.start()
	pass
func unstunned():
	currentState=stateBeforeStun
	pass

func die():
	currentState.stop()
	currentState=not_so_dead
	currentState.start()
