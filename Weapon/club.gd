extends Node2D
class_name Weapon

@export_group("Componenets")
@export var holder:Node2D=null
@onready var hit_box:Area2D = $HitBox
@export var mouseControlled:bool=false
@onready var spri = $Sprite
@onready var pick_up_range:Area2D = $PickUpRange

const CLUB = preload("res://Weapon/club.tres")
const CLUB_GROUND = preload("res://Weapon/clubGround.tres")

@export_group("Weapon")
@export var maxSpeed:float=40
@export var acc:float=110
@export var pushForce:float=300
var rSpeed:float=0.0



func _ready():
	if(holder!=null): 
		pickUp(holder)
		setForEnemy()
	pass

func update(delta:float):
	rotateWeapon(delta)
	if(rotation>0):z_index=11
	else:z_index=9
	#print(rSpeed)
	global_position=holder.hands.global_position
	pass
	
func rotateWeapon(delta:float):
	if(mouseControlled && holder.get_local_mouse_position().length()<20):
		return
		
	var rotationalDifference	
	if(mouseControlled):
		rotationalDifference=-get_local_mouse_position().angle_to(Vector2(1,0))
	else:
		rotationalDifference=holder.hands.rotation-rotation
	
	if(abs(rotationalDifference)<=0.1):
		rSpeed=move_toward(rSpeed,0,acc*delta*4)
	else:	
		if(rSpeed>=0.):
			if(rotationalDifference>0. || (rSpeed>3*maxSpeed/4 &&rotationalDifference>-1.6 && mouseControlled)):
				if(rSpeed<maxSpeed/2):
					rSpeed=move_toward(rSpeed,maxSpeed,acc*delta*2)
				else:
					rSpeed=move_toward(rSpeed,maxSpeed,acc*delta)
			else:
				rSpeed=move_toward(rSpeed,-maxSpeed,acc*delta*4)
		else:
			if(rotationalDifference<0. || (rSpeed<-3*maxSpeed/4 && rotationalDifference<1.6 && mouseControlled)):
				if(rSpeed>-maxSpeed/2):
					rSpeed=move_toward(rSpeed,-maxSpeed,acc*delta*2)
				else:
					rSpeed=move_toward(rSpeed,-maxSpeed,acc*delta)
			else:
				rSpeed=move_toward(rSpeed,maxSpeed,acc*delta*4)
	rotation+=rSpeed*delta
	if(rotation>3.14):
		rotation-=6.26
	elif(rotation<-3.14):
		rotation+=6.28
	
func pickUp(holderOfWeapon:Node2D):
	spri.texture=CLUB
	holder=holderOfWeapon
	setForPlayer()
	pick_up_range.set_collision_mask_value(2,false)
	pass
	
func setForPlayer():
	mouseControlled=true
	hit_box.set_collision_layer_value(5,false)
	hit_box.set_collision_mask_value(2,false)
	
	hit_box.set_collision_layer_value(4,true)
	hit_box.set_collision_mask_value(3,true)
	pass

func setForEnemy():
	mouseControlled=false
	hit_box.set_collision_layer_value(4,false)
	hit_box.set_collision_mask_value(3,false)
	
	
	hit_box.set_collision_layer_value(5,true)
	hit_box.set_collision_mask_value(2,true)
	pass


func equipRangeEntered(body):
	body=body.get_parent()
	print("Club: " + str(body))
	if(body.has_method("equip")):
		if(body.equip(self)):
			print("Club: Yay")
			pickUp(body)
			
	pass # Replace with function body.
	
func hitSomething(body):
	body=body.get_parent()
	if(body==null):return
	if(body.has_method("getHit")):
		if(body.isDead): return
		var direction:Vector2 = (body.global_position-global_position).normalized()
		var factor:float=(abs(rSpeed)-10)/4
		if(rSpeed<-10):
			direction=direction.rotated(deg_to_rad(-45))
			body.getHit(direction,pushForce*factor,factor)
		elif(rSpeed>10):
			direction=direction.rotated(deg_to_rad(45))
			body.getHit(direction,pushForce*factor,factor)
		rSpeed=rSpeed*1/2
	
	pass
