extends CharacterBody2D
class_name Doctor

@export_group("Components")
@onready var feet:CollisionShape2D = $Feet
@onready var health:HealthBar = $RelativePos/NotRelativeRotation/HealthComponent

@onready var hands:Node2D = $RelativePos/Hands
@onready var rotation_point = $RelativePos/RotationPoint
@onready var stun_timer:Timer = $StunTimer

@onready var spri:Sprite2D = $RelativePos/NotRelativeRotation/Sprite

@onready var spriDebug = $RelativePos/NotRelativeRotation/SpriteDebug
@onready var anim = $AnimationPlayer
@onready var hit_box:Area2D = $RelativePos/NotRelativeRotation/HitBox
@onready var relative_pos = $RelativePos
@onready var not_relative_rotation = $RelativePos/NotRelativeRotation
@onready var eyes:RayCast2D = $eyes


@export_group("Doctor")
@export var weapon:Weapon=null
@export var target:Node2D
@export var isControlled:bool=false
@export var isInfected:bool=false
@export var isDead:bool=false
@export var isStunned:bool=false
@export var isChasing:bool=false
@export var isAttacking:bool=false
@export var isTutorial:bool=false


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
@onready var attack = $States/Attack
@onready var stunnedState = $States/Stunned


@onready var debug = $RelativePos/NotRelativeRotation/debug

var currentState:Node

func determineState() -> Object:
	if(isTutorial):
		return idle
	if(isDead):
		return not_so_dead
	elif(isStunned && !isControlled):
		return stunnedState
	elif(isChasing&&isAttacking):
		return attack
	elif(isChasing && !isInfected):
		return chase
	elif(isControlled):
		return controlled
	else:
		return idle
		
func _ready():
	isAttacking=false
	if(isTutorial):
		anim.play("tutorial")
		await(anim.animation_finished)
		queue_free()

func _process(delta):
	if(currentState==null):
		currentState=idle
	
	var temp = determineState()
	if(currentState!=temp):
		currentState.stop()
		currentState=temp
		currentState.start()
	
	
	currentState.update(delta)
	updateSprite()
	
	if(weapon!=null):
		weapon.update(delta)
		
		
	debug.text=str(currentState.name)
	move_and_slide()
	
	
@export var h:int=0
@export var v:int
func updateSprite():
	
	if(isDead):
		v=4
		if(isInfected):
			h=1
		else:
			h=0
		if(lookingDirection>=1.5): spri.flip_h=true
		else: spri.flip_h=false
	elif(lookingDirection>=0.0 && !isInfected):
		v=1
		if(lookingDirection>=1.5): spri.flip_h=true
		else: spri.flip_h=false
	elif(lookingDirection<=0.0 && !isInfected):
		v=0
		if(lookingDirection<=-1.5): spri.flip_h=true
		else: spri.flip_h=false
	elif(lookingDirection>=0.0 && isInfected):
		v=3
		if(lookingDirection>=1.5): spri.flip_h=true
		else: spri.flip_h=false
	elif(lookingDirection<0.0 && isInfected):
		v=2
		if(lookingDirection<=-1.5): spri.flip_h=true
		else: spri.flip_h=false
	spri.set_frame(2*v+h)
	
	if(velocity.length()>=0 && currentState!=not_so_dead):
		anim.speed_scale=1+velocity.length()*2/maxSpeed
	else:
		anim.speed_scale=1
	
func attached(parasite:Parasite)->bool:
	if(isDead&&isInfected):
		return false
	
	if(health.HP<=health.threshold || (isInfected&&!isDead) || (isDead&&!isInfected)):
		isStunned=false
		isChasing=false
		isDead=false
		
		#isInfected=true will be set in state
		isControlled=true
		
		if(weapon!=null):
			weapon.setForPlayer()
		return true
	else:
		parasite.velocity=parasite.velocity.normalized().rotated(deg_to_rad(180))*parasite.maxSpeed/2
		return false
	
func detached():
	if(isStunned):
		unstunned()
	isControlled=false
	if(weapon!=null):
		weapon.setNeutral()
		weapon.mouseControlled=false
	
func equip(weaponToEquip:Weapon)->bool:
	if(weapon==null):
		print("Equiping..")
		weapon=weaponToEquip
		weapon.visible=true
		return true
	else:
		return false
	
func getHit(source:Node2D,pushForce:float,damage:int):
	position+=source.global_position.direction_to(source.global_position)*pushForce
	stunned(damage/4)
	health.takeDamage(damage)


var stunDuration:float
var tween:Tween
func stunned(duration):
	if(isDead):
		return
	if(weapon!=null):
		weapon.rSpeed=0
	
	stunDuration+=stunDuration
	isStunned=true
	
	spri.modulate = Color.DARK_RED
	if(tween!=null):
		tween.stop()
	tween = get_tree().create_tween()
	tween.tween_property(self.spri,"modulate",Color.WHITE,(duration+0.2)*0.4).set_delay((duration+0.2)*0.6)
	tween.set_ease(Tween.EASE_IN)
func unstunned():
	if(isDead):
		stunDuration=0
		isStunned=false
		return

	if(stunDuration<=0):
		isStunned=false
	else:
		stunDuration-=0.1

func die():
	tween.stop()
	spri.modulate = Color.WHITE
	isChasing=false
	isStunned=false
	isAttacking=false
	isControlled=false
	isDead=true
	

func trigger(givenTarget:Node2D):
	if(currentState==idle && !isInfected):
		isChasing=true
		target=givenTarget


func weaponDisable():
	if(weapon!=null):
		weapon.setNeutral()
func weaponEnable():
	if(weapon!=null):
		if(isControlled):
			weapon.setForPlayer()
		else:
			weapon.setForEnemy()
